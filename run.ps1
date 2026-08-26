<#
.SYNOPSIS
    Kashif AI (كاشف) — Local Development Runner Script
.DESCRIPTION
    Checks local prerequisites (Node.js, agy CLI, environment) and starts the Next.js development server.
#>

$ErrorActionPreference = "Stop"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  كاشف — Kashif AI Car Diagnostic Report Assistant   " -ForegroundColor Yellow
Write-Host "======================================================" -ForegroundColor Cyan

# 1. Check Node.js
try {
    $nodeVersion = node -v
    Write-Host "[✓] Node.js detected: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "[✗] Error: Node.js is not installed or not in PATH." -ForegroundColor Red
    exit 1
}

# 2. Check Antigravity CLI (agy)
$agyPath = Get-Command "agy" -ErrorAction SilentlyContinue
if ($agyPath) {
    Write-Host "[✓] Local agy CLI detected: $($agyPath.Source)" -ForegroundColor Green
} else {
    Write-Host "[i] agy CLI not found in PATH (Google Gemini Cloud API will be used)." -ForegroundColor DarkGray
}

# 3. Check dependencies
if (-not (Test-Path "node_modules")) {
    Write-Host "[i] Installing dependencies..." -ForegroundColor Yellow
    npm install
}

# 4. Check .env.local
if (-not (Test-Path ".env.local") -and -not (Test-Path ".env")) {
    Write-Host "[i] Notice: No .env.local found. You can set GEMINI_API_KEY or enter your key in the app Settings." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Starting development server on http://localhost:3000 ..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop." -ForegroundColor DarkGray
Write-Host "------------------------------------------------------" -ForegroundColor DarkGray

npm run dev
