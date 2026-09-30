# -*- coding: utf-8 -*-
"""
Flow Cars - Mobile Preview Launcher
Runs a lightweight local HTTP server and opens a dedicated phone-sized browser window.
"""
import sys
import os
import subprocess
import time
import socket
import threading
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

# Reconfigure stdout/stderr to UTF-8 to prevent CP1252 charmap crashes on Windows
try:
    if sys.stdout:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    if sys.stderr:
        sys.stderr.reconfigure(encoding='utf-8', errors='replace')
except Exception:
    pass

PORT = 7357
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
APP_DIR = os.path.join(SCRIPT_DIR, "kashif_mobile")
if not os.path.exists(os.path.join(APP_DIR, "pubspec.yaml")):
    APP_DIR = SCRIPT_DIR
WEB_DIR = os.path.join(APP_DIR, "build", "web")

# Ensure Flutter & Chrome are in PATH
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
        cmd = f'powershell -Command "Get-NetTCPConnection -LocalPort {port} -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object {{ Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }}"'
        subprocess.run(cmd, shell=True, capture_output=True)
        time.sleep(0.5)
    except Exception:
        pass

class CustomHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.end_headers()

    def do_POST(self):
        if self.path.startswith('/apinex-proxy'):
            import urllib.request
            import urllib.error
            import json

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
    url = f"http://127.0.0.1:{PORT}"
    if browser:
        dev_profile = os.path.expandvars(r"%TEMP%\kashif_chrome_dev")
        args = [
            browser,
            f"--app={url}",
            "--window-size=420,880",
            "--window-position=60,60",
            "--disable-web-security",
            f"--user-data-dir={dev_profile}",
            "--allow-running-insecure-content"
        ]
        subprocess.Popen(args)
    else:
        import webbrowser
        webbrowser.open(url)

def build_web():
    print("\n[🔨] جاري تجميع نسخة الويب السريعة بأقصى سرعة...")
    res = subprocess.run(
        ["flutter", "build", "web", "--no-pub", "--no-wasm-dry-run", "--no-tree-shake-icons"],
        cwd=APP_DIR,
        shell=True
    )
    if res.returncode == 0:
        print("[✓] تم التجميع بنجاح!\n")
        return True
    else:
        print("[✗] حدث خطأ أثناء التجميع.")
        return False

def run_dev():
    kill_port_owner(PORT)
    print("\n====================================================================")
    print(" [أزرار التحكم أثناء العمل في وضع التطوير]:")
    print("   - احفظ أي ملف في الكود (Ctrl + S)")
    print("   - اضغط [ r ] للتحديث الفوري (Hot Reload)")
    print("   - اضغط [ R ] للتحديث الكامل (Hot Restart)")
    print("   - اضغط [ q ] لإيقاف التشغيل والخروج")
    print("====================================================================\n")
    print("جاري تشغيل المعاينة الحية...")
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
    print("         Flow Cars - تشغيل تطبيق الهاتف على الكمبيوتر")
    print("====================================================================")
    print(f"مسار التطبيق: {APP_DIR}")
    print("\nاختر طريقة التشغيل:")
    print("  [1] تشغيل فوري وسريع جداً (في ثانية واحدة) [موصى به] ⚡")
    print("  [2] تشغيل وضع التطوير والمزامنة الحية (Hot Reload) 🔄")
    print("  [3] إعادة بناء وتحديث نسخة الويب (Rebuild Web) 🔨\n")
    print("====================================================================")

    # Prompt with timeout
    choice = "1"
    prompt = "يرجى الاختيار (سيتم تشغيل الخيار 1 تلقائياً خلال 3 ثوانٍ): "
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
        print("1 (تلقائي)")

    if choice == "3":
        if build_web():
            choice = "1"
        else:
            input("\nاضغط Enter للمتابعة...")
            return

    if choice == "2":
        run_dev()
        return

    # Option 1: Instant Run
    index_path = os.path.join(WEB_DIR, "index.html")
    if not os.path.exists(index_path):
        print("\n[⚡] نسخة الويب غير مبنية، جاري بناؤها لمرة واحدة فقط...")
        if not build_web():
            input("\nاضغط Enter للمتابعة...")
            return

    kill_port_owner(PORT)

    print("\n[1/2] تشغيل الخادم المحلي على المنفذ 7357...")
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()
    time.sleep(0.8)

    print("[2/2] فتح نافذة الهاتف الذكي في المتصفح...")
    open_mobile_window()

    print("\n====================================================================")
    print(" ✅ تم تشغيل تطبيق Flow Cars بنجاح كشاشة هاتف مستقلة!")
    print("====================================================================")
    print(f" الخادم يعمل الآن (http://127.0.0.1:{PORT})")
    print(" اضغط [Enter] أو أي زر لإغلاق هذه النافذة وإنهاء الخادم...")
    print("====================================================================")

    try:
        input()
    except (KeyboardInterrupt, EOFError):
        pass
    print("تم إغلاق الخادم بنجاح.")

if __name__ == "__main__":
    main()
