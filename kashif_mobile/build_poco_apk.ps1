# Kashif APK Builder for Poco X7 Pro (ARM64-v8a)
$ErrorActionPreference = "Stop"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "          [Kashif AI] - Poco X7 Pro APK Builder" -ForegroundColor Green
Write-Host "          Architecture: ARM64-v8a (Dimensity 8400-Ultra / 64-bit)" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan

$projectRoot = $PSScriptRoot

# Check Flutter command, probe well-known installation paths if missing
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    $flutterPaths = @(
        "F:\flutter\bin",
        "C:\flutter\bin",
        "D:\flutter\bin",
        "$env:LOCALAPPDATA\flutter\bin",
        "$env:USERPROFILE\flutter\bin",
        "$env:USERPROFILE\fvm\default\bin"
    )
    foreach ($p in $flutterPaths) {
        if (Test-Path (Join-Path $p "flutter.bat")) {
            $env:PATH = "$p;" + $env:PATH
            break
        }
    }
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Flutter SDK was not found in PATH or standard directories!" -ForegroundColor Red
    exit 1
}

$buildDir = $projectRoot
Set-Location -Path $buildDir

Write-Host "[1/3] Fetching dependencies..." -ForegroundColor Gray
flutter pub get

Write-Host "Cleaning previous APK build outputs to prevent stale version copying..." -ForegroundColor Gray
Remove-Item -Path (Join-Path $buildDir "build\app\outputs\flutter-apk\*.apk") -Force -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path $projectRoot "build\app\outputs\flutter-apk\*.apk") -Force -ErrorAction SilentlyContinue
$destDir = Join-Path (Split-Path $projectRoot -Parent) "APK_OUTPUT"
Remove-Item -Path (Join-Path $destDir "kashif_poco_x7_pro.apk") -Force -ErrorAction SilentlyContinue

Write-Host "[2/3] Compiling optimized ARM64 release for Poco X7 Pro..." -ForegroundColor Yellow
flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons --android-skip-build-dependency-validation

$standardApk = Join-Path $buildDir "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $standardApk) {
    $apkSrc = $standardApk
} else {
    $newestApk = Get-ChildItem -Path @(
        (Join-Path $buildDir "build\app\outputs\flutter-apk\*.apk"),
        (Join-Path $projectRoot "build\app\outputs\flutter-apk\*.apk")
    ) -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch "unaligned" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($newestApk) {
        $apkSrc = $newestApk.FullName
    }
}

if ($apkSrc) {
    $destDir = Join-Path (Split-Path $projectRoot -Parent) "APK_OUTPUT"
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir | Out-Null
    }
    
    $destFile = Join-Path $destDir "kashif_poco_x7_pro.apk"
    Copy-Item -Path $apkSrc -Destination $destFile -Force

    # Also sync root and mobile helper copies to eliminate stale APK confusion
    $workspaceRoot = Split-Path $projectRoot -Parent
    Copy-Item -Path $apkSrc -Destination (Join-Path $workspaceRoot "flowcars_release.apk") -Force -ErrorAction SilentlyContinue
    Copy-Item -Path $apkSrc -Destination (Join-Path $projectRoot "kashif-poco-arm64.apk") -Force -ErrorAction SilentlyContinue
    
    $fileSizeMB = [math]::Round(((Get-Item $destFile).Length / 1MB), 2)
    
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host " SUCCESS: Kashif APK built successfully for Poco X7 Pro!" -ForegroundColor Green
    Write-Host " File: $destFile" -ForegroundColor Cyan
    Write-Host " Size: $fileSizeMB MB" -ForegroundColor Yellow
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host ""
    
    if (-not $env:CI -and -not $env:NON_INTERACTIVE) {
        try { Invoke-Item $destDir } catch {}
    }
} else {
    Write-Host ""
    Write-Host "[ERROR] APK build output was not found." -ForegroundColor Red
    exit 1
}
