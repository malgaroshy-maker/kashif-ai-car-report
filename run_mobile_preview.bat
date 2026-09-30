@echo off
setlocal
cd /d "%~dp0"
python "%~dp0preview_launcher.py" %*
if errorlevel 1 (
    echo.
    pause
)
