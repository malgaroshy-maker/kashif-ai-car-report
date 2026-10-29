@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_poco_apk.ps1" %*
if errorlevel 1 (
    echo.
    pause
)
