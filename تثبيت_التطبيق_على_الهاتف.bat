@echo off
chcp 65001 >nul
setlocal

echo ========================================================
echo    تثبيت تطبيق كاشف (Kashif) على POCO X7 / X7 Pro
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
        echo يمكنك نقل ملف APK_OUTPUT\kashif_poco_x7_pro.apk إلى هاتفك وتثبيته مباشرة.
        pause
        exit /b 1
    )
)

set "TARGET_APK="
if exist "%~dp0APK_OUTPUT\kashif_poco_x7_pro.apk" set "TARGET_APK=%~dp0APK_OUTPUT\kashif_poco_x7_pro.apk"
if not defined TARGET_APK if exist "%~dp0kashif_mobile\APK_OUTPUT\kashif_poco_x7_pro.apk" set "TARGET_APK=%~dp0kashif_mobile\APK_OUTPUT\kashif_poco_x7_pro.apk"
if not defined TARGET_APK if exist "%~dp0flowcars_release.apk" set "TARGET_APK=%~dp0flowcars_release.apk"
if not defined TARGET_APK if exist "%~dp0kashif_mobile\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" set "TARGET_APK=%~dp0kashif_mobile\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
if not defined TARGET_APK if exist "%~dp0kashif_mobile\build\app\outputs\flutter-apk\app-release.apk" set "TARGET_APK=%~dp0kashif_mobile\build\app\outputs\flutter-apk\app-release.apk"

if not defined TARGET_APK (
    echo [!] لم يتم العثور على ملف APK جاهز للتثبيت.
    echo يرجى تشغيل سكربت "بناء_تطبيق_بوكو_Poco_X7_Pro.bat" أولاً لبناء النسخة.
    pause
    exit /b 1
)

echo [*] جاري البحث عن الأجهزة المتصلة عبر USB / Wi-Fi...
"%ADB_PATH%" devices

echo.
echo [*] جاري تثبيت التطبيق (%TARGET_APK%)...
"%ADB_PATH%" install -r "%TARGET_APK%"

if %errorlevel% equ 0 (
    echo.
    echo [✓] تم تثبيت التطبيق بنجاح على هاتفك!
    echo [*] جاري تشغيل التطبيق...
    "%ADB_PATH%" shell monkey -p ly.kashif.app.kashif_mobile -c android.intent.category.LAUNCHER 1 >nul 2>&1
) else (
    echo.
    echo [!] فشل التثبيت التلقائي عبر ADB. تأكد من تفعيل "تصحيح أخطاء USB" (USB Debugging) في إعدادات المطور، أو انسخ ملف kashif_poco_x7_pro.apk لهاتفك وثبته يدوياً.
)

echo.
pause
