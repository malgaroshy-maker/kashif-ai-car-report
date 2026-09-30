@echo off
chcp 65001 >nul
title Flow Cars - تشغيل تطبيق الهاتف على الكمبيوتر

:: إعداد مسارات Flutter والبرامج
if exist "F:\flutter\bin" set "PATH=F:\flutter\bin;%PATH%"
if exist "C:\flutter\bin" set "PATH=C:\flutter\bin;%PATH%"
if exist "D:\flutter\bin" set "PATH=D:\flutter\bin;%PATH%"
set "PATH=%PATH%;C:\Program Files\Git\cmd;C:\platform-tools;C:\Program Files\Google\Chrome\Application"

:: التحويل إلى المسار المختصر (8.3 Short Path) لتفادي بطأ وتوقف أدوات Flutter مع المسارات العربية
for %%I in ("%~dp0.") do set "APP_DIR=%%~sI"
cd /d "%APP_DIR%"

cls
echo ====================================================================
echo         Flow Cars - تشغيل تطبيق الهاتف على الكمبيوتر
echo ====================================================================
echo مسار المشروع: %APP_DIR%
echo.
echo اختر طريقة التشغيل:
echo.
echo   [1] تشغيل فوري وسريع جداً (في ثانية واحدة بدون انتظار) [موصى به] ⚡
echo   [2] تشغيل وضع التطوير والمزامنة الحية (Hot Reload) 🔄
echo   [3] إعادة بناء وتحديث النسخة السريعة (Rebuild Web) 🔨
echo.
echo ====================================================================
echo.

choice /c 123 /t 4 /d 1 /m "يرجى الاختيار (سيتم تشغيل الخيار 1 الفوري تلقائياً خلال 4 ثوانٍ): "
set CHOICE_VAL=%errorlevel%

if "%CHOICE_VAL%"=="1" goto INSTANT_RUN
if "%CHOICE_VAL%"=="2" goto DEV_RUN
if "%CHOICE_VAL%"=="3" goto REBUILD_RUN

:INSTANT_RUN
if not exist "build\web\index.html" (
    echo.
    echo [تنبيه] النسخة السريعة غير مبنية بعد، جاري بناؤها لمرة واحدة فقط...
    call flutter build web --no-pub --no-wasm-dry-run --no-tree-shake-icons
)
echo.
echo [1/2] جاري تشغيل الخادم المحلي...
start /b "" python -m http.server 7357 --bind 127.0.0.1 --directory "build\web" >nul 2>&1
timeout /t 1 /nobreak >nul

echo [2/2] جاري فتح شاشة الهاتف في المتصفح...
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    start "" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" --app="http://127.0.0.1:7357" --window-size=420,880 --window-position=60,60
) else (
    start "" "http://127.0.0.1:7357"
)
echo.
echo ====================================================================
echo تم فتح التطبيق بنجاح كشاشة هاتف مخصصة!
echo اضغط أي زر لإغلاق هذه النافذة.
echo ====================================================================
pause >nul
exit /b 0

:DEV_RUN
echo.
echo ====================================================================
echo  [أزرار التحكم أثناء العمل]:
echo   - احفظ أي ملف في المحرر (Ctrl + S)
echo   - اضغط [ r ] هنا للتحديث الفوري (Hot Reload)
echo   - اضغط [ R ] للتحديث الكامل (Hot Restart)
echo   - اضغط [ q ] لإيقاف التشغيل
echo ====================================================================
echo.
echo جاري تشغيل المعاينة الحية بأقصى سرعة...
flutter run -d chrome --no-pub --no-wasm-dry-run --no-tree-shake-icons --web-port=7357 --web-hostname=127.0.0.1 --web-browser-flag "--window-size=420,880" --web-browser-flag "--window-position=60,60" --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=%USERPROFILE%\.flutter_chrome_dev"
pause
exit /b 0

:REBUILD_RUN
echo.
echo جاري تجميع نسخة الويب السريعة بأقصى سرعة...
call flutter build web --no-pub --no-wasm-dry-run --no-tree-shake-icons
echo.
echo تم التجميع بنجاح! جاري تشغيل التطبيق...
goto INSTANT_RUN
