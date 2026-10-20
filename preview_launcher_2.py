# -*- coding: utf-8 -*-
"""
Flow Cars - Mobile Preview Launcher (Fast v2)
Ultra-fast launcher with optimized socket checks, warm browser profile, zero delay, and direct launch.
"""
import sys
import os
import subprocess
import time
import socket
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
        s.settimeout(0.05)
        return s.connect_ex(('127.0.0.1', port)) == 0

def kill_port_owner(port):
    if not is_port_in_use(port):
        return
    try:
        output = subprocess.check_output('netstat -ano -p tcp', shell=True, text=True, stderr=subprocess.DEVNULL)
        target = f':{port}'
        for line in output.strip().splitlines():
            parts = line.strip().split()
            if len(parts) >= 5 and target in parts[1] and parts[3].upper() == 'LISTENING':
                pid = parts[-1]
                if pid.isdigit() and int(pid) > 4:
                    subprocess.run(['taskkill', '/F', '/PID', pid], capture_output=True)
    except Exception:
        pass

class CustomHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_GET(self):
        if self.path.startswith('/flutter_service_worker.js'):
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

        if self.path.startswith('/apinex-proxy'):
            sub_path = self.path[len('/apinex-proxy'):]
            target_url = f"https://api.apinex.bond/v1{sub_path}"
            auth_header = self.headers.get('Authorization', '')
            req_headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            }
            if auth_header:
                req_headers['Authorization'] = auth_header

            req = urllib.request.Request(
                target_url,
                headers=req_headers,
                method='GET'
            )
            try:
                with urllib.request.urlopen(req, timeout=300) as resp:
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

        super().do_GET()

    def end_headers(self):
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
                with urllib.request.urlopen(req, timeout=300) as resp:
                    self.send_response(resp.status)
                    content_type = resp.headers.get('Content-Type', 'application/json; charset=utf-8')
                    self.send_header('Content-Type', content_type)
                    self.send_header('Access-Control-Allow-Origin', '*')
                    self.end_headers()
                    while True:
                        chunk = resp.read(1024)
                        if not chunk:
                            break
                        self.wfile.write(chunk)
                        self.wfile.flush()
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
        pass

def run_server():
    server = ThreadingHTTPServer(('127.0.0.1', PORT), CustomHandler)
    server.serve_forever()

def wait_for_server(port, timeout=2.0):
    start = time.time()
    while time.time() - start < timeout:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(0.05)
            if s.connect_ex(('127.0.0.1', port)) == 0:
                return True
        time.sleep(0.01)
    return False

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
        return True
    else:
        print("[-] Error compiling web bundle.")
        return False

def run_dev():
    kill_port_owner(PORT)
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
    t_start = time.time()
    args = sys.argv[1:]

    if "--dev" in args or "-d" in args:
        run_dev()
        return

    if "--rebuild" in args or "-r" in args:
        if build_web():
            pass
        else:
            input("\nPress Enter to exit...")
            return

    # Check if web bundle exists
    index_path = os.path.join(WEB_DIR, "index.html")
    if not os.path.exists(index_path):
        print("[*] Web bundle not found. Compiling for the first time...")
        if not build_web():
            input("\nPress Enter to exit...")
            return
    elif is_web_outdated():
        print("[*] Newer source code changes detected. Updating web bundle...")
        if not build_web():
            print("[!] Continuing with existing build...")

    # Fast port check & kill only if active
    kill_port_owner(PORT)

    # Launch local HTTP server in background thread
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()

    # Wait for server to bind (typically 20-50ms)
    wait_for_server(PORT, timeout=1.5)

    # Launch mobile browser window immediately
    open_mobile_window()
    elapsed = time.time() - t_start

    print("====================================================================")
    print("       Flow Cars - Live Mobile App Preview (Fast Mode v2)")
    print("====================================================================")
    print(f" [OK] Preview window opened in {elapsed:.2f} seconds!")
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
