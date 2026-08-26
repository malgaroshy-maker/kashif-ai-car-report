@echo off
title Kashif AI Development Server
echo ======================================================
echo   كاشف — Kashif AI Car Diagnostic Report Assistant   
echo ======================================================
echo.

:: Check Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed or not in PATH.
    pause
    exit /b 1
)

:: Check dependencies
if not exist "node_modules\" (
    echo [INFO] Installing node dependencies...
    call npm install
)

echo [INFO] Starting Next.js development server...
echo [INFO] Open http://localhost:3000 in your browser.
echo.
call npm run dev
