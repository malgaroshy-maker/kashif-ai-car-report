@echo off
chcp 65001 >nul
setlocal

echo ========================================================
echo    تثبيت تطبيق كاشف (Kashif) على POCO F5 Pro
echo ========================================================
echo.

set "ADB_PATH=adb"
where adb >nul 2>&1
if %errorlevel% neq 0 (
    if exist "F:\Android-studio\sdk\platform-tools\adb.exe" (
        set "ADB_PATH=F:\Android-studio\sdk\platform-tools\adb.exe"
    ) else if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
        set "ADB_PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
    ) else (
        echo [!] تعذر العثور على أداة adb تلقائياً.
        echo يمكنك نقل ملف kashif-poco-f5-pro.apk إلى هاتفك وتثبيته مباشرة.
        pause
        exit /b 1
    )
)

echo [*] جاري البحث عن الأجهزة المتصلة عبر USB / Wi-Fi...
"%ADB_PATH%" devices

echo.
echo [*] جاري تثبيت التطبيق على الهاتف...
"%ADB_PATH%" install -r "%~dp0kashif-poco-f5-pro.apk"

if %errorlevel% equ 0 (
    echo.
    echo [✓] تم تثبيت التطبيق بنجاح على هاتفك!
    echo [*] جاري تشغيل التطبيق...
    "%ADB_PATH%" shell monkey -p ly.kashif.app.kashif_mobile -c android.intent.category.LAUNCHER 1 >nul 2>&1
) else (
    echo.
    echo [!] فشل التثبيت التلقائي عبر ADB. تأكد من تفعيل "تصحيح أخطاء USB" (USB Debugging) في إعدادات المطور، أو انسخ ملف kashif-poco-f5-pro.apk لهاتفك وثبته يدوياً.
)

echo.
pause
