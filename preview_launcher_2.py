# -*- coding: utf-8 -*-
"""
Flow Cars - Mobile Preview Launcher (Fast v2 Enhanced)
Ultra-fast launcher with reliable outdated detection, automatic cache/data wiping,
hot rebuild triggers, and clean process management.
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
import atexit
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

# Ensure UTF-8 output encoding on Windows console
try:
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')
except Exception:
    pass

PORT = 7357
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
APP_DIR = os.path.join(SCRIPT_DIR, "kashif_mobile")
if not os.path.exists(os.path.join(APP_DIR, "pubspec.yaml")):
    APP_DIR = SCRIPT_DIR
WEB_DIR = os.path.join(APP_DIR, "build", "web")

# Global reference to the preview browser process
browser_process = None

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

def close_browser():
    """Immediately terminates the preview browser process if running."""
    global browser_process
    if browser_process is not None:
        try:
            subprocess.run(['taskkill', '/F', '/T', '/PID', str(browser_process.pid)], capture_output=True)
        except Exception:
            pass
        browser_process = None

def kill_stale_processes():
    """Kills any previous processes using port 7357 or the dedicated dev profile."""
    kill_port_owner(PORT)
    close_browser()
    try:
        ps_cmd = (
            "Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | "
            "Where-Object { $_.CommandLine -like '*kashif_chrome_dev*' -or $_.CommandLine -like '*127.0.0.1:7357*' } | "
            "ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
        )
        subprocess.run(["powershell", "-NoProfile", "-Command", ps_cmd], capture_output=True, timeout=5)
    except Exception:
        pass

def clear_browser_cache():
    """
    Completely wipes the dev profile directory to eliminate old Hive IndexedDB databases,
    cached reports, car inspections, and JS bytecode cache.
    """
    close_browser()
    dev_profile = os.path.expandvars(r"%TEMP%\kashif_chrome_dev")
    if os.path.exists(dev_profile):
        for _ in range(3):
            try:
                shutil.rmtree(dev_profile, ignore_errors=True)
                break
            except Exception:
                time.sleep(0.15)

class CustomHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_GET(self):
        # Strip conditional headers so server never returns 304 Not Modified
        if 'If-Modified-Since' in self.headers:
            del self.headers['If-Modified-Since']
        if 'If-None-Match' in self.headers:
            del self.headers['If-None-Match']

        # Aggressively unregister any service worker
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

        # Apinex AI Proxy to bypass browser CORS
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
        # Strict anti-caching headers so latest build is always loaded
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0, post-check=0, pre-check=0')
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
        time.sleep(0.02)
    return False

def open_mobile_window():
    global browser_process
    close_browser()
    browser = find_browser()
    cache_buster = int(time.time() * 1000)
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
            "--aggressive-cache-discard",
            "--disable-features=IsolateOrigins,site-per-process",
            "--no-first-run",
            "--no-default-browser-check"
        ]
        browser_process = subprocess.Popen(args)
    else:
        import webbrowser
        webbrowser.open(url)

def get_latest_source_info():
    """
    Finds the latest modification time and the corresponding file path across
    all project source files and assets.
    """
    latest_mtime = 0
    latest_file = ""
    check_dirs = [
        os.path.join(APP_DIR, "lib"),
        os.path.join(APP_DIR, "assets"),
        os.path.join(APP_DIR, "web"),
    ]
    valid_exts = ('.dart', '.yaml', '.json', '.png', '.ttf', '.html', '.js', '.css', '.svg')
    for cdir in check_dirs:
        if os.path.exists(cdir):
            for root, _, files in os.walk(cdir):
                for f in files:
                    if f.endswith(valid_exts):
                        p = os.path.join(root, f)
                        try:
                            m = os.path.getmtime(p)
                            if m > latest_mtime:
                                latest_mtime = m
                                latest_file = p
                        except Exception:
                            pass
    pubspec = os.path.join(APP_DIR, "pubspec.yaml")
    if os.path.exists(pubspec):
        try:
            m = os.path.getmtime(pubspec)
            if m > latest_mtime:
                latest_mtime = m
                latest_file = pubspec
        except Exception:
            pass
    return latest_mtime, latest_file

def is_web_outdated():
    """
    Reliably checks if the compiled web bundle (main.dart.js) is missing or older
    than any project source file.
    """
    main_js = os.path.join(WEB_DIR, "main.dart.js")
    index_html = os.path.join(WEB_DIR, "index.html")

    if not os.path.exists(main_js) or not os.path.exists(index_html):
        return True, "ملفات حزمة الويب غير موجودة (Web bundle files missing)"

    try:
        bundle_mtime = os.path.getmtime(main_js)
        src_mtime, src_file = get_latest_source_info()
        if src_mtime > bundle_mtime:
            rel_file = os.path.relpath(src_file, APP_DIR)
            return True, f"تم تعديل: {rel_file}"
        return False, None
    except Exception as e:
        return True, str(e)

def build_web():
    print("\n" + "=" * 68)
    print(" [*] جاري إعادة بناء حزمة الويب وتطبيق آخر التعديلات...")
    print(" [*] Building latest Flutter web bundle from source...")
    print("=" * 68)
    t0 = time.time()
    res = subprocess.run(
        ["flutter", "build", "web", "--no-pub", "--no-wasm-dry-run", "--no-tree-shake-icons"],
        cwd=APP_DIR,
        shell=True
    )
    if res.returncode == 0:
        elapsed = time.time() - t0
        print(f"\n[+] تم بناء الحزمة بنجاح خلال {elapsed:.1f} ثانية! (Built successfully)")
        clear_browser_cache()
        return True
    else:
        print("\n[-] حدث خطأ أثناء بناء الحزمة (flutter build web failed).")
        return False

def run_dev():
    kill_stale_processes()
    clear_browser_cache()
    print("\n====================================================================")
    print(" [Hot Reload Controls in Live Development Mode]:")
    print("   - احفظ أي ملف في محرر الأكواد (Ctrl + S)")
    print("   - اضغط [ r ] للتحديث السريع (Hot Reload)")
    print("   - اضغط [ R ] للتحديث الشامل (Hot Restart)")
    print("   - اضغط [ q ] للخروج")
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

def cleanup_on_exit():
    close_browser()
    try:
        dev_profile = os.path.expandvars(r"%TEMP%\kashif_chrome_dev")
        if os.path.exists(dev_profile):
            shutil.rmtree(dev_profile, ignore_errors=True)
    except Exception:
        pass

atexit.register(cleanup_on_exit)

def main():
    t_start = time.time()
    args = sys.argv[1:]

    # Clean old leftover processes and stale session data before starting
    kill_stale_processes()
    clear_browser_cache()

    if "--dev" in args or "-d" in args:
        run_dev()
        return

    force_rebuild = "--rebuild" in args or "-r" in args

    if not force_rebuild:
        print("====================================================================")
        print("         Flow Cars - سكربت تشغيل معاينة الهاتف المباشرة (v2)")
        print("====================================================================")
        print(" خيارات التشغيل (يتم البدء تلقائياً بالخيار [1] خلال ثانيتين):")
        print("   [1] تشغيل سريع ونظيف مع فحص التعديلات تلقائياً (Fast Run) *")
        print("   [2] فرض إعادة البناء من الصفر (Force Rebuild Web Bundle)")
        print("   [3] وضع التطوير الحي مع التحديث اللحظي (Live Dev Mode / Hot Reload)")
        print("====================================================================")
        print(" اختيارك: ", end="", flush=True)

        import msvcrt
        menu_choice = "1"
        start_wait = time.time()
        while time.time() - start_wait < 2.0:
            if msvcrt.kbhit():
                ch = msvcrt.getch().decode('utf-8', errors='ignore')
                if ch in ["1", "2", "3"]:
                    menu_choice = ch
                    print(ch)
                    break
            time.sleep(0.04)
        else:
            print("1 (تلقائي)")

        if menu_choice == "2":
            force_rebuild = True
        elif menu_choice == "3":
            run_dev()
            return

    if force_rebuild:
        if not build_web():
            input("\nاضغط Enter للخروج...")
            return

    # Check if web bundle exists or needs recompilation
    outdated, reason = is_web_outdated()
    if outdated:
        print(f"\n[*] تم رصد تغييرات في ملفات التطبيق: ({reason})")
        print("[*] جاري إعادة تجميع حزمة الويب لعرض التعديلات الجديدة...")
        if not build_web():
            print("[!] المتابعة بالنسخة الحالية الموجودة...")

    # Fast port ensure
    kill_port_owner(PORT)

    # Launch local HTTP server in background thread
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()

    # Wait for server to bind
    wait_for_server(PORT, timeout=1.5)

    # Launch mobile browser window with a clean fresh session
    open_mobile_window()
    elapsed = time.time() - t_start

    print("\n====================================================================")
    print("         Flow Cars - Live Mobile App Preview (v2 Enhanced)")
    print("====================================================================")
    print(f" [OK] تم تشغيل نافذة المعاينة بنجاح خلال {elapsed:.2f} ثانية!")
    print(f" الرابط المحلي: http://127.0.0.1:{PORT}")
    print()
    print(" [أوامر التحكم التفاعلي أثناء المعاينة]:")
    print("   [ r ] -> إعادة بناء التطبيق فوراً وعرض التعديلات الجديدة (Rebuild)")
    print("   [ c ] -> مسح جميع بيانات الكشف وبدء فحص سيارة جديدة نظيفة (Clear Data)")
    print("   [ o ] -> إعادة فتح نافذة المعاينة إذا أغلقتها (Re-open Window)")
    print("   [ q ] أو [Enter] -> إغلاق المعاينة ومسح بيانات الجلسة المؤقتة والخروج")
    print("====================================================================\n")

    import msvcrt
    try:
        while True:
            if msvcrt.kbhit():
                ch = msvcrt.getch()
                if ch in [b'\r', b'\n', b'q', b'Q']:
                    break
                elif ch in [b'r', b'R']:
                    print("\n[*] طلب إعادة البناء فوراً...")
                    close_browser()
                    if build_web():
                        open_mobile_window()
                        print("[+] تم تحديث المعاينة بالتعديلات الجديدة بنجاح!\n")
                elif ch in [b'c', b'C']:
                    print("\n[*] مسح بيانات الكشف والجلسة وبدء تطبيق نظيف تماماً...")
                    close_browser()
                    clear_browser_cache()
                    open_mobile_window()
                    print("[+] تم تفريغ البيانات القديمة بنجاح والمعاينة جاهزة كأنها لأول مرة!\n")
                elif ch in [b'o', b'O']:
                    print("\n[*] إعادة فتح نافذة المعاينة...")
                    open_mobile_window()
            time.sleep(0.08)
    except (KeyboardInterrupt, EOFError):
        pass

    print("\n[*] جاري إيقاف السيرفر وتنظيف بيانات المعاينة المؤقتة...")
    close_browser()
    kill_stale_processes()
    clear_browser_cache()
    print("[+] تم إغلاق المعاينة وحذف البيانات المؤقتة بنجاح.")

if __name__ == "__main__":
    main()
