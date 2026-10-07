# Kashif APK Builder for Poco X7 Pro (ARM64-v8a)
$ErrorActionPreference = "Stop"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "          Kashif AI - Poco X7 Pro APK Builder" -ForegroundColor Green
Write-Host "          Architecture: ARM64-v8a [64-bit]" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan

Set-Location -Path $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Flutter SDK is not found in PATH!" -ForegroundColor Red
    exit 1
}

Write-Host "`n[1/3] Getting dependencies..." -ForegroundColor Gray
flutter pub get

Write-Host "`n[2/3] Compiling optimized ARM64 release for Poco X7 Pro..." -ForegroundColor Yellow
flutter build apk --release --target-platform android-arm64

$apkSrc = "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
if (-not (Test-Path $apkSrc)) {
    $apkSrc = "build\app\outputs\flutter-apk\app-release.apk"
}

if (Test-Path $apkSrc) {
    $destDir = Join-Path (Split-Path $PSScriptRoot -Parent) "APK_OUTPUT"
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir | Out-Null
    }
    
    $destFile = Join-Path $destDir "kashif_poco_x7_pro.apk"
    Copy-Item -Path $apkSrc -Destination $destFile -Force
    
    $fileSizeMB = [math]::Round(((Get-Item $destFile).Length / 1MB), 2)
    
    Write-Host "`n======================================================================" -ForegroundColor Green
    Write-Host " SUCCESS: APK is built successfully!" -ForegroundColor Green
    Write-Host " File: $destFile" -ForegroundColor Cyan
    Write-Host " Size: $fileSizeMB MB" -ForegroundColor Yellow
    Write-Host "======================================================================`n" -ForegroundColor Green
    
    Invoke-Item $destDir
} else {
    Write-Host "`n[ERROR] APK build output was not found." -ForegroundColor Red
    exit 1
}
