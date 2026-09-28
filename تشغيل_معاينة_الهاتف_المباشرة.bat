@echo off
set "PATH=C:\flutter\bin;C:\platform-tools;C:\Program Files\Git\cmd;%PATH%"

cd /d "%~dp0"
if exist "kashif_mobile\pubspec.yaml" cd /d "%~dp0kashif_mobile"

cls
echo ====================================================================
echo         KASHIF AI - Flutter Live Preview (Web Mobile View)
echo ====================================================================
echo Project Directory: %cd%
echo.
echo ====================================================================
echo  [HOT RELOAD CONTROLS]:
echo   - Save your Dart file in the editor (Ctrl + S)
echo   - Press [ r ] here for Instant Hot Reload (1 second update)
echo   - Press [ R ] here for Full Hot Restart
echo   - Press [ q ] here to Stop
echo ====================================================================
echo.
echo Launching Chrome in Mobile Dimensions (420 x 880)...
echo.
flutter run -d chrome --web-browser-flag "--window-size=420,880" --web-browser-flag "--window-position=50,50" --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=C:\Users\Administrator\.flutter_chrome_dev"
pause
