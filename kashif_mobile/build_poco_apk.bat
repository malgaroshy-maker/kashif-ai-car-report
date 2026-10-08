@echo off
title Kashif APK Builder - Poco X7 Pro
color 0B

echo ======================================================================
echo           [Kashif AI] Poco X7 Pro APK Builder
echo           Target: ARM64-v8a (MediaTek Dimensity 8400-Ultra / 64-bit)
echo ======================================================================
echo.

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "PROJECT_ROOT=%SCRIPT_DIR%"

for %%I in ("%PROJECT_ROOT%\..") do set "WORKSPACE_ROOT=%%~fI"
set "OUTPUT_DIR=%WORKSPACE_ROOT%\APK_OUTPUT"

echo [1/4] Checking Flutter environment...
where flutter >nul 2>nul
if not errorlevel 1 goto FLUTTER_FOUND

if exist "F:\flutter\bin\flutter.bat" set "PATH=F:\flutter\bin;%PATH%"
if exist "C:\flutter\bin\flutter.bat" set "PATH=C:\flutter\bin;%PATH%"
if exist "D:\flutter\bin\flutter.bat" set "PATH=D:\flutter\bin;%PATH%"
if exist "%LOCALAPPDATA%\flutter\bin\flutter.bat" set "PATH=%LOCALAPPDATA%\flutter\bin;%PATH%"
if exist "%USERPROFILE%\flutter\bin\flutter.bat" set "PATH=%USERPROFILE%\flutter\bin;%PATH%"
if exist "%USERPROFILE%\fvm\default\bin\flutter.bat" set "PATH=%USERPROFILE%\fvm\default\bin;%PATH%"

where flutter >nul 2>nul
if errorlevel 1 goto NO_FLUTTER

:FLUTTER_FOUND
echo [2/4] Preparing build directory...
set "BUILD_DIR=%PROJECT_ROOT%"

if not exist "C:\" goto SETUP_DIR_DONE
if exist "C:\kashif_build\pubspec.yaml" goto USE_JUNCTION

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { New-Item -ItemType Junction -Path 'C:\kashif_build' -Target '%PROJECT_ROOT%' -Force -ErrorAction SilentlyContinue | Out-Null } catch {}" >nul 2>nul
if exist "C:\kashif_build\pubspec.yaml" goto USE_JUNCTION
goto SETUP_DIR_DONE

:USE_JUNCTION
set "BUILD_DIR=C:\kashif_build"

:SETUP_DIR_DONE
cd /d "%BUILD_DIR%"

set "CHOICE=%~1"
if "%CHOICE%"=="--arm64" set CHOICE=1
if "%CHOICE%"=="--universal" set CHOICE=2
if "%CHOICE%"=="--install" set CHOICE=3
if not "%CHOICE%"=="" goto PROCESS_CHOICE

echo.
echo Choose build mode:
echo [1] ARM64-v8a Optimized for Poco X7 Pro (Fast and Lightweight - Recommended)
echo [2] Universal APK (All Android Devices)
echo [3] Direct Install via USB (ADB)
echo.
set "CHOICE=1"
set /p CHOICE="Enter choice [1, 2, or 3, default is 1]: "

:PROCESS_CHOICE
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
if errorlevel 1 goto BUILD_ERROR
goto FIND_APK

:BUILD_UNIVERSAL
echo Compiling universal release APK...
call flutter build apk --release --no-tree-shake-icons --android-skip-build-dependency-validation
if errorlevel 1 goto BUILD_ERROR
goto FIND_APK

:BUILD_INSTALL
echo Installing directly to connected phone...
call flutter install --release
if errorlevel 1 goto INSTALL_FAILED
echo.
echo ======================================================================
echo  SUCCESS: Kashif has been installed on your phone!
echo ======================================================================
if not "%NON_INTERACTIVE%"=="1" pause
exit /b 0

:INSTALL_FAILED
echo [Notice] No USB device detected with debugging enabled. Building ARM64 APK file instead...
goto BUILD_ARM64

:FIND_APK
set "APK_FILE="
if exist "%BUILD_DIR%\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" set "APK_FILE=%BUILD_DIR%\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
if not defined APK_FILE if exist "%BUILD_DIR%\build\app\outputs\flutter-apk\app-release.apk" set "APK_FILE=%BUILD_DIR%\build\app\outputs\flutter-apk\app-release.apk"
if not defined APK_FILE if exist "%PROJECT_ROOT%\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" set "APK_FILE=%PROJECT_ROOT%\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
if not defined APK_FILE if exist "%PROJECT_ROOT%\build\app\outputs\flutter-apk\app-release.apk" set "APK_FILE=%PROJECT_ROOT%\build\app\outputs\flutter-apk\app-release.apk"

if not defined APK_FILE goto BUILD_ERROR
if not exist "%APK_FILE%" goto BUILD_ERROR

:COPY_OUTPUT
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
copy /y "%APK_FILE%" "%OUTPUT_DIR%\kashif_poco_x7_pro.apk" > nul
if errorlevel 1 goto COPY_ERROR
if not exist "%OUTPUT_DIR%\kashif_poco_x7_pro.apk" goto COPY_ERROR

set "APK_SIZE_MB=0"
for %%F in ("%OUTPUT_DIR%\kashif_poco_x7_pro.apk") do (
    set /a APK_SIZE_MB=%%~zF/1048576
)

echo.
echo ======================================================================
echo  [SUCCESS] Kashif APK built successfully for Poco X7 Pro!
echo ======================================================================
echo  Output Location : %OUTPUT_DIR%\kashif_poco_x7_pro.apk
echo  File Size       : ~%APK_SIZE_MB% MB
echo.
echo  Installation steps on Poco X7 Pro (Xiaomi HyperOS):
echo  1. Transfer kashif_poco_x7_pro.apk to your phone (USB / Telegram / WhatsApp).
echo  2. Tap the file and select "Install".
echo  3. If HyperOS warns about unknown source, allow installation.
echo ======================================================================
echo.

if not "%NON_INTERACTIVE%"=="1" (
    explorer.exe "%OUTPUT_DIR%"
)
exit /b 0

:NO_FLUTTER
echo.
echo ======================================================================
echo  [ERROR] Flutter SDK is not found in system PATH!
echo  Please ensure Flutter SDK is installed and added to your PATH.
echo ======================================================================
if not "%NON_INTERACTIVE%"=="1" pause
exit /b 1

:COPY_ERROR
echo.
echo ======================================================================
echo  [ERROR] Failed to copy APK to destination folder:
echo  %OUTPUT_DIR%
echo ======================================================================
if not "%NON_INTERACTIVE%"=="1" pause
exit /b 1

:BUILD_ERROR
echo.
echo ======================================================================
echo  [ERROR] Build failed! Check the Gradle/Flutter error messages above.
echo ======================================================================
if not "%NON_INTERACTIVE%"=="1" pause
exit /b 1
