@echo off
setlocal
chcp 65001 >nul
title Flow Cars - Live Mobile Preview (Fast v2)
cd /d "%~dp0"
python "%~dp0preview_launcher_2.py" %*
if errorlevel 1 (
    echo.
    echo [ERROR] An error occurred while launching preview.
    pause
)
