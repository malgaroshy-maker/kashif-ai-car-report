@echo off
chcp 65001 > nul
setlocal

cd /d "%~dp0kashif_mobile"
call build_poco_apk.bat %*
if errorlevel 1 (
    echo.
    echo ======================================================================
    echo  [خطأ] فشلت عملية البناء. يرجى مراجعة التعليمات أعلاه.
    echo ======================================================================
    pause
    exit /b 1
)

exit /b 0
