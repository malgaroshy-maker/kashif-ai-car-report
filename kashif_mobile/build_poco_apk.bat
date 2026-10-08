@echo off
chcp 65001 > nul
title Kashif APK Builder - Poco X7 Pro
color 0B

echo ======================================================================
echo           🚗 Kashif AI - Poco X7 Pro APK Builder
echo           📱 Target: ARM64-v8a (Dimensity 8400-Ultra / 64-bit)
echo ======================================================================
echo.

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR:~0,-1%"

echo [1/4] Checking Flutter environment...
where flutter >nul 2>nul
if errorlevel 1 goto NO_FLUTTER

echo [2/4] Setting up clean ASCII build junction at C:\kashif_build...
if not exist "C:\kashif_build" (
    powershell -NoProfile -Command "New-Item -ItemType Junction -Path 'C:\kashif_build' -Target '%PROJECT_ROOT%' -Force" >nul 2>nul
)

cd /d "C:\kashif_build"

echo.
echo Choose build mode:
echo [1] ARM64-v8a Optimized for Poco X7 Pro (Fast and Lightweight - Recommended)
echo [2] Universal APK (All Android Devices)
echo [3] Direct Install via USB (ADB)
echo.
set /p CHOICE="Enter choice [1, 2, or 3, default is 1]: "
if "%CHOICE%"=="" set CHOICE=1

echo.
echo [3/4] Fetching dependencies...
call flutter pub get
if errorlevel 1 goto BUILD_ERROR

echo.
echo [4/4] Compiling APK (this may take a few minutes)...
if "%CHOICE%"=="2" goto BUILD_UNIVERSAL
if "%CHOICE%"=="3" goto BUILD_INSTALL

:BUILD_ARM64
echo Compiling optimized ARM64 release for Poco X7 Pro...
call flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons --android-skip-build-dependency-validation
set APK_FILE=build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
if not exist "%APK_FILE%" set APK_FILE=build\app\outputs\flutter-apk\app-release.apk
goto COPY_OUTPUT

:BUILD_UNIVERSAL
echo Compiling universal release APK...
call flutter build apk --release --no-tree-shake-icons --android-skip-build-dependency-validation
set APK_FILE=build\app\outputs\flutter-apk\app-release.apk
goto COPY_OUTPUT

:BUILD_INSTALL
echo Installing directly to connected phone...
call flutter install --release
if errorlevel 1 goto INSTALL_FAILED
echo.
echo ======================================================================
echo  SUCCESS: Kashif has been installed on your phone!
echo ======================================================================
pause
exit /b 0

:INSTALL_FAILED
echo [Notice] No USB device detected with debugging enabled. Building APK file instead...
goto BUILD_ARM64

:COPY_OUTPUT
if not exist "%APK_FILE%" goto BUILD_ERROR

if not exist "%PROJECT_ROOT%\..\APK_OUTPUT" mkdir "%PROJECT_ROOT%\..\APK_OUTPUT"
copy /y "%APK_FILE%" "%PROJECT_ROOT%\..\APK_OUTPUT\kashif_poco_x7_pro.apk" > nul

echo.
echo ======================================================================
echo  SUCCESS: APK is ready for your Poco X7 Pro!
echo ======================================================================
echo  Output Location:
echo  APK_OUTPUT\kashif_poco_x7_pro.apk
echo.
echo  Installation steps on Poco X7 Pro (Xiaomi HyperOS):
echo  1. Transfer kashif_poco_x7_pro.apk to your phone (USB / Telegram / WhatsApp).
echo  2. Tap the file and select "Install".
echo  3. If HyperOS warns about unknown source, allow installation.
echo ======================================================================
echo.

explorer.exe "%PROJECT_ROOT%\..\APK_OUTPUT"
pause
exit /b 0

:NO_FLUTTER
echo.
echo [ERROR] Flutter is not found in your system PATH!
echo Please ensure Flutter SDK is installed and configured.
pause
exit /b 1

:BUILD_ERROR
echo.
echo [ERROR] Build failed! Check the Gradle error messages above.
pause
exit /b 1
