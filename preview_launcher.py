# -*- coding: utf-8 -*-
"""
Flow Cars - Mobile Preview Launcher
Runs a lightweight local HTTP server and opens a dedicated phone-sized browser window.
All console output is in English to prevent Windows terminal character encoding issues.
"""
import sys
import os
import subprocess
import time
import socket
import shutil
import threading
import urllib.request
import urllib.error
import json
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

PORT = 7357
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
APP_DIR = os.path.join(SCRIPT_DIR, "kashif_mobile")
if not os.path.exists(os.path.join(APP_DIR, "pubspec.yaml")):
    APP_DIR = SCRIPT_DIR
WEB_DIR = os.path.join(APP_DIR, "build", "web")

# Ensure Flutter is in PATH
FLUTTER_DIRS = [
    r"C:\flutter\bin",
    r"F:\flutter\bin",
    r"D:\flutter\bin",
]
for fd in FLUTTER_DIRS:
    if os.path.exists(fd) and fd not in os.environ.get("PATH", ""):
        os.environ["PATH"] = fd + os.pathsep + os.environ.get("PATH", "")

CHROME_PATHS = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    os.path.expandvars(r"%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"),
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
]

def find_browser():
    for p in CHROME_PATHS:
        if os.path.exists(p):
            return p
    return None

def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('127.0.0.1', port)) == 0

def kill_port_owner(port):
    if not is_port_in_use(port):
        return
    try:
        cmd = f'powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort {port} -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object {{ Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }}"'
        subprocess.run(cmd, shell=True, capture_output=True)
        time.sleep(0.5)
    except Exception:
        pass

def kill_stale_processes():
    """Kills any previous processes using port 7357 or the dev browser profile."""
    kill_port_owner(PORT)
    try:
        cmd = (
            'powershell -NoProfile -Command "'
            'Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | '
            'Where-Object { $_.CommandLine -like \'*kashif_chrome_dev*\' -or $_.CommandLine -like \'*127.0.0.1:7357*\' } | '
            'ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"'
        )
        subprocess.run(cmd, shell=True, capture_output=True)
        time.sleep(0.5)
    except Exception:
        pass

def clear_browser_cache():
    """Wipes Chrome dev profile cache completely."""
    kill_stale_processes()
    dev_profile = os.path.expandvars(r"%TEMP%\kashif_chrome_dev")
    if os.path.exists(dev_profile):
        try:
            shutil.rmtree(dev_profile, ignore_errors=True)
        except Exception:
            pass

class CustomHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_GET(self):
        if self.path.startswith('/flutter_service_worker.js'):
            # Return immediate unregister script so browser never uses stale worker
            unregister_code = (
                b"'use strict';\n"
                b"self.addEventListener('install', () => self.skipWaiting());\n"
                b"self.addEventListener('activate', (e) => e.waitUntil(self.registration.unregister()));\n"
            )
            self.send_response(200)
            self.send_header('Content-Type', 'application/javascript; charset=utf-8')
            self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
            self.send_header('Pragma', 'no-cache')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(unregister_code)
            return

        super().do_GET()

    def end_headers(self):
        # Disable caching completely so the browser always loads the latest files
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.end_headers()

    def do_POST(self):
        if self.path.startswith('/apinex-proxy'):
            sub_path = self.path[len('/apinex-proxy'):]
            target_url = f"https://api.apinex.bond/v1{sub_path}"
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length) if content_length > 0 else b""

            auth_header = self.headers.get('Authorization', '')
            req_headers = {
                'Content-Type': 'application/json',
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            }
            if auth_header:
                req_headers['Authorization'] = auth_header

            req = urllib.request.Request(
                target_url,
                data=post_data,
                headers=req_headers,
                method='POST'
            )
            try:
                with urllib.request.urlopen(req, timeout=40) as resp:
                    resp_body = resp.read()
                    self.send_response(resp.status)
                    self.send_header('Content-Type', 'application/json; charset=utf-8')
                    self.send_header('Access-Control-Allow-Origin', '*')
                    self.end_headers()
                    self.wfile.write(resp_body)
            except urllib.error.HTTPError as e:
                err_body = e.read()
                self.send_response(e.code)
                self.send_header('Content-Type', 'application/json; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(err_body)
            except Exception as ex:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json; charset=utf-8')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'error': str(ex)}).encode('utf-8'))
            return

        super().do_POST()

    def log_message(self, format, *args):
        # Silent server logging to keep terminal clean
        pass

def run_server():
    server = ThreadingHTTPServer(('127.0.0.1', PORT), CustomHandler)
    server.serve_forever()

def open_mobile_window():
    browser = find_browser()
    cache_buster = int(time.time())
    url = f"http://127.0.0.1:{PORT}/?v={cache_buster}"
    if browser:
        dev_profile = os.path.expandvars(r"%TEMP%\kashif_chrome_dev")
        args = [
            browser,
            f"--app={url}",
            "--window-size=430,900",
            "--window-position=60,40",
            "--disable-web-security",
            f"--user-data-dir={dev_profile}",
            "--allow-running-insecure-content",
            "--disable-cache",
            "--disable-application-cache",
            "--disk-cache-size=1",
            "--media-cache-size=1",
            "--aggressive-cache-discard"
        ]
        subprocess.Popen(args)
    else:
        import webbrowser
        webbrowser.open(url)

def get_latest_source_mtime():
    """Returns the latest modification time among all source files and assets."""
    latest = 0
    check_dirs = [
        os.path.join(APP_DIR, "lib"),
        os.path.join(APP_DIR, "assets"),
        os.path.join(APP_DIR, "web"),
    ]
    for cdir in check_dirs:
        if os.path.exists(cdir):
            for root, _, files in os.walk(cdir):
                for f in files:
                    if f.endswith(('.dart', '.yaml', '.json', '.png', '.ttf', '.html', '.js')):
                        p = os.path.join(root, f)
                        try:
                            m = os.path.getmtime(p)
                            if m > latest:
                                latest = m
                        except Exception:
                            pass
    pubspec = os.path.join(APP_DIR, "pubspec.yaml")
    if os.path.exists(pubspec):
        try:
            latest = max(latest, os.path.getmtime(pubspec))
        except Exception:
            pass
    return latest

def is_web_outdated():
    index_path = os.path.join(WEB_DIR, "index.html")
    if not os.path.exists(index_path):
        return True
    try:
        build_time = os.path.getmtime(index_path)
        source_time = get_latest_source_mtime()
        return source_time > (build_time + 2)
    except Exception:
        return False

def build_web():
    print("\n[*] Building latest web release bundle...")
    res = subprocess.run(
        ["flutter", "build", "web", "--no-pub", "--no-wasm-dry-run", "--no-tree-shake-icons"],
        cwd=APP_DIR,
        shell=True
    )
    if res.returncode == 0:
        print("[+] Web bundle compiled successfully!\n")
        clear_browser_cache()
        return True
    else:
        print("[-] Error compiling web bundle.")
        return False

def run_dev():
    kill_port_owner(PORT)
    clear_browser_cache()
    print("\n====================================================================")
    print(" [Hot Reload Controls in Development Mode]:")
    print("   - Save any file in your editor (Ctrl + S)")
    print("   - Press [ r ] for Hot Reload")
    print("   - Press [ R ] for Full Hot Restart")
    print("   - Press [ q ] to Quit")
    print("====================================================================\n")
    print("[*] Launching Flutter live development server...")
    user_data = os.path.expandvars(r"%USERPROFILE%\.flutter_chrome_dev")
    cmd = [
        "flutter", "run", "-d", "chrome",
        "--no-pub", "--no-wasm-dry-run", "--no-tree-shake-icons",
        f"--web-port={PORT}", "--web-hostname=127.0.0.1",
        '--web-browser-flag=--window-size=420,880',
        '--web-browser-flag=--window-position=60,60',
        '--web-browser-flag=--disable-web-security',
        f'--web-browser-flag=--user-data-dir={user_data}'
    ]
    subprocess.run(" ".join(cmd), cwd=APP_DIR, shell=True)

def main():
    print("====================================================================")
    print("             Flow Cars - Live Mobile App Preview")
    print("====================================================================")
    print(f"App directory: {APP_DIR}")
    print("\nSelect launch mode:")
    print("  [1] Instant Run (Fastest - loads in 1 second) [Recommended] *")
    print("  [2] Live Dev Mode (Hot Reload with Flutter run)")
    print("  [3] Rebuild Web Bundle (Force recompile from source)\n")
    print("====================================================================")

    choice = "1"
    prompt = "Choice (Auto-selecting [1] in 3 seconds): "
    print(prompt, end="", flush=True)

    import msvcrt
    start_time = time.time()
    while time.time() - start_time < 3.0:
        if msvcrt.kbhit():
            ch = msvcrt.getch().decode('utf-8', errors='ignore')
            if ch in ["1", "2", "3"]:
                choice = ch
                print(ch)
                break
        time.sleep(0.05)
    else:
        print("1 (Auto)")

    if choice == "3":
        if build_web():
            choice = "1"
        else:
            input("\nPress Enter to exit...")
            return

    if choice == "2":
        run_dev()
        return

    # Option 1: Instant Run with Smart Auto-Rebuild
    index_path = os.path.join(WEB_DIR, "index.html")
    if not os.path.exists(index_path):
        print("\n[*] Web bundle not found. Compiling for the first time...")
        if not build_web():
            input("\nPress Enter to exit...")
            return
    elif is_web_outdated():
        print("\n[*] Detected newer source code changes!")
        print("[*] Automatically updating web bundle to display latest features...")
        if not build_web():
            print("[!] Continuing with existing build...")

    kill_port_owner(PORT)
    clear_browser_cache()

    print("\n[1/2] Starting local HTTP server on port 7357...")
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()
    time.sleep(0.8)

    print("[2/2] Opening dedicated phone preview window in browser...")
    open_mobile_window()

    print("\n====================================================================")
    print(" [OK] Flow Cars is running in mobile phone mode!")
    print("====================================================================")
    print(f" Local URL: http://127.0.0.1:{PORT}")
    print(" Press [Enter] to stop the server and close this window...")
    print("====================================================================")

    try:
        input()
    except (KeyboardInterrupt, EOFError):
        pass
    print("Server stopped.")

if __name__ == "__main__":
    main()
