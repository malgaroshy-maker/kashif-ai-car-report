# Kashif APK Builder for Poco X7 Pro (ARM64-v8a)
$ErrorActionPreference = "Stop"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "          🚗 Kashif AI - Poco X7 Pro APK Builder" -ForegroundColor Green
Write-Host "          📱 Architecture: ARM64-v8a (Dimensity 8400-Ultra / 64-bit)" -ForegroundColor Yellow
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
    Write-Host "`n[ERROR] Flutter SDK was not found in PATH or standard directories!" -ForegroundColor Red
    exit 1
}

$buildDir = $projectRoot
$junctionPath = "C:\kashif_build"

try {
    if (Test-Path "C:\") {
        if (Test-Path $junctionPath) {
            $currentTarget = (Get-Item $junctionPath -ErrorAction SilentlyContinue).Target
            if ($currentTarget -ne $projectRoot) {
                Remove-Item $junctionPath -Force -ErrorAction SilentlyContinue
            }
        }
        if (-not (Test-Path $junctionPath)) {
            New-Item -ItemType Junction -Path $junctionPath -Target $projectRoot -Force -ErrorAction SilentlyContinue | Out-Null
        }
        if (Test-Path (Join-Path $junctionPath "pubspec.yaml")) {
            $buildDir = $junctionPath
        }
    }
} catch {
    $buildDir = $projectRoot
}

Set-Location -Path $buildDir

Write-Host "`n[1/3] Fetching dependencies..." -ForegroundColor Gray
flutter pub get

Write-Host "`n[2/3] Compiling optimized ARM64 release for Poco X7 Pro..." -ForegroundColor Yellow
flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons --android-skip-build-dependency-validation

$apkCandidates = @(
    (Join-Path $buildDir "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"),
    (Join-Path $buildDir "build\app\outputs\flutter-apk\app-release.apk"),
    (Join-Path $projectRoot "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"),
    (Join-Path $projectRoot "build\app\outputs\flutter-apk\app-release.apk")
)

$apkSrc = $null
foreach ($c in $apkCandidates) {
    if (Test-Path $c) {
        $apkSrc = $c
        break
    }
}

if ($apkSrc) {
    $destDir = Join-Path (Split-Path $projectRoot -Parent) "APK_OUTPUT"
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir | Out-Null
    }
    
    $destFile = Join-Path $destDir "kashif_poco_x7_pro.apk"
    Copy-Item -Path $apkSrc -Destination $destFile -Force
    
    $fileSizeMB = [math]::Round(((Get-Item $destFile).Length / 1MB), 2)
    
    Write-Host "`n======================================================================" -ForegroundColor Green
    Write-Host " ✅ تم بناء تطبيق كاشف بنجاح لجهاز Poco X7 Pro!" -ForegroundColor Green
    Write-Host " SUCCESS: APK is built successfully!" -ForegroundColor Green
    Write-Host " File: $destFile" -ForegroundColor Cyan
    Write-Host " Size: $fileSizeMB MB" -ForegroundColor Yellow
    Write-Host "======================================================================`n" -ForegroundColor Green
    
    Invoke-Item $destDir
} else {
    Write-Host "`n[ERROR] APK build output was not found." -ForegroundColor Red
    exit 1
}
