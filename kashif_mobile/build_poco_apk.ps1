# Kashif APK Builder for Poco X7 Pro (ARM64-v8a) - Fast & Reliable
param (
    [switch]$Universal,
    [switch]$Install
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "          [Flow Cars / Kashif AI] Poco X7 Pro APK Builder" -ForegroundColor Green
Write-Host "          Architecture: ARM64-v8a (Dimensity 8400-Ultra / 64-bit)" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan

$projectRoot = $PSScriptRoot
$workspaceRoot = Split-Path $projectRoot -Parent
$rootOutputDir = Join-Path $workspaceRoot "APK_OUTPUT"
$localOutputDir = Join-Path $projectRoot "APK_OUTPUT"

# Ensure output directories exist
if (-not (Test-Path $rootOutputDir)) { New-Item -ItemType Directory -Path $rootOutputDir | Out-Null }
if (-not (Test-Path $localOutputDir)) { New-Item -ItemType Directory -Path $localOutputDir | Out-Null }

# Locate Flutter
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
    Write-Host "[ERROR] Flutter SDK not found in system PATH." -ForegroundColor Red
    exit 1
}

# Map project root to virtual drive K: to bypass Dart AOT snapshotter non-ASCII path bug
$substDrive = "K:"
try { subst $substDrive /d 2>$null } catch {}
& subst $substDrive "$projectRoot"

if (-not (Test-Path "$substDrive\pubspec.yaml")) {
    Write-Host "[ERROR] Failed to map virtual drive $substDrive to project." -ForegroundColor Red
    exit 1
}

try {
    Set-Location -Path "$substDrive\"

    Write-Host "[1/3] Checking dependencies (Fast Mode)..." -ForegroundColor Gray
    if (Test-Path "$substDrive\.dart_tool\package_config.json") {
        flutter pub get --offline 2>$null
        if ($LASTEXITCODE -ne 0) { flutter pub get }
    } else {
        flutter pub get
    }

    Write-Host "[2/3] Cleaning previous APK outputs across all folders..." -ForegroundColor Gray
    Remove-Item -Path "$substDrive\build\app\outputs\flutter-apk\*.apk" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $projectRoot "build\app\outputs\flutter-apk\*.apk") -Force -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $rootOutputDir "*.apk") -Force -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $localOutputDir "*.apk") -Force -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $workspaceRoot "flowcars_release.apk") -Force -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $projectRoot "flowcars_release.apk") -Force -ErrorAction SilentlyContinue

    Write-Host "[3/3] Compiling optimized ARM64 release APK for Poco X7 Pro..." -ForegroundColor Yellow
    flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons --android-skip-build-dependency-validation

    $apkFile = "$substDrive\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
    if (-not (Test-Path $apkFile)) {
        $apkFile = "$substDrive\build\app\outputs\flutter-apk\app-release.apk"
    }

    if (-not (Test-Path $apkFile)) {
        throw "Build finished but release APK was not found at expected path: $apkFile"
    }

    $destPocoRoot = Join-Path $rootOutputDir "kashif_poco_x7_pro.apk"
    $destVersionRoot = Join-Path $rootOutputDir "kashif_poco_v1.2.6_b9.apk"
    $destPocoLocal = Join-Path $localOutputDir "kashif_poco_x7_pro.apk"
    $destVersionLocal = Join-Path $localOutputDir "kashif_poco_v1.2.6_b9.apk"

    Copy-Item -Path $apkFile -Destination $destPocoRoot -Force
    Copy-Item -Path $apkFile -Destination $destVersionRoot -Force
    Copy-Item -Path $apkFile -Destination $destPocoLocal -Force
    Copy-Item -Path $apkFile -Destination $destVersionLocal -Force
    Copy-Item -Path $apkFile -Destination (Join-Path $workspaceRoot "flowcars_release.apk") -Force
    Copy-Item -Path $apkFile -Destination (Join-Path $projectRoot "flowcars_release.apk") -Force

    $versionInfo = @"
======================================================================
 Flow Cars / Kashif AI (Poco X7 Pro Edition)
======================================================================
 Application  : Flow Cars
 Version      : 1.2.6
 Build Number : 9
 Serial       : KASHIF-V1.2.6-B9-20261031
 Build Date   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
 Target       : ARM64-v8a (MediaTek Dimensity 8400-Ultra / 64-bit)
 Status       : FRESH BUILD COMPLETE
======================================================================
"@
    Set-Content -Path (Join-Path $rootOutputDir "VERSION_INFO.txt") -Value $versionInfo -Encoding UTF8
    Set-Content -Path (Join-Path $localOutputDir "VERSION_INFO.txt") -Value $versionInfo -Encoding UTF8

    $fileSizeMB = [math]::Round(((Get-Item $destPocoRoot).Length / 1MB), 2)

    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host " [SUCCESS] Fresh Kashif APK built successfully for Poco X7 Pro!" -ForegroundColor Green
    Write-Host " Location 1 : $destPocoRoot" -ForegroundColor Cyan
    Write-Host " Location 2 : $destPocoLocal" -ForegroundColor Cyan
    Write-Host " File Size  : $fileSizeMB MB" -ForegroundColor Yellow
    Write-Host " Version    : v1.2.6 #9 (Serial: KASHIF-V1.2.6-B9-20261031)" -ForegroundColor White
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host ""

    if ($Install) {
        Write-Host "Installing directly via ADB..." -ForegroundColor Cyan
        adb install -r "$destPocoRoot"
    }

} finally {
    Set-Location -Path $projectRoot
    try { subst $substDrive /d 2>$null } catch {}
}
