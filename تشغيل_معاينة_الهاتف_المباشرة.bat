@echo off
setlocal
title Flow Cars - Live Mobile Preview
cd /d "%~dp0"
python "%~dp0preview_launcher.py" %*
if errorlevel 1 (
    echo.
    echo [ERROR] An error occurred while launching preview.
    pause
)
