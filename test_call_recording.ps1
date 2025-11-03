# Quick Testing Script for Call Recording on Android Device (Windows PowerShell)
# Usage: .\test_call_recording.ps1

$PACKAGE_NAME = "com.example.tigger"
$APP_NAME = "TiggerOn"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Call Recording Test Helper" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if device is connected
Write-Host "Checking for connected devices..." -ForegroundColor Yellow
$devices = adb devices | Select-String "device$"
if (-not $devices) {
    Write-Host "❌ No Android device connected!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Connection options:" -ForegroundColor Yellow
    Write-Host "1. USB: Connect via USB cable and enable USB debugging" -ForegroundColor Cyan
    Write-Host "2. Wireless: Enable Wireless debugging in Developer Options" -ForegroundColor Cyan
    Write-Host "   Then run: adb pair <IP>:<PORT> <CODE>" -ForegroundColor Cyan
    Write-Host "   Then run: adb connect <IP>:<PORT>" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "See WIRELESS_DEBUGGING_SETUP.md for detailed instructions" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Device connected" -ForegroundColor Green
if ($devices -match "^\d+\.\d+\.\d+\.\d+:") {
    Write-Host "   (Wireless connection detected)" -ForegroundColor Cyan
}
Write-Host ""

# Grant permissions
Write-Host "Granting required permissions..." -ForegroundColor Yellow
adb shell pm grant $PACKAGE_NAME android.permission.CALL_PHONE
adb shell pm grant $PACKAGE_NAME android.permission.RECORD_AUDIO
adb shell pm grant $PACKAGE_NAME android.permission.WRITE_EXTERNAL_STORAGE
adb shell pm grant $PACKAGE_NAME android.permission.READ_PHONE_STATE
Write-Host "✅ Permissions granted" -ForegroundColor Green
Write-Host ""

# Check if app is installed
Write-Host "Checking if app is installed..." -ForegroundColor Yellow
$installed = adb shell pm list packages | Select-String $PACKAGE_NAME
if (-not $installed) {
    Write-Host "⚠️  App not installed. Building and installing..." -ForegroundColor Yellow
    flutter build apk --debug
    adb install build/app/outputs/flutter-apk/app-debug.apk
    Write-Host "✅ App installed" -ForegroundColor Green
} else {
    Write-Host "✅ App is installed" -ForegroundColor Green
}
Write-Host ""

# Show recording directory
Write-Host "Recording directory location:" -ForegroundColor Yellow
$recordings = adb shell "ls -lh /storage/emulated/0/Android/data/$PACKAGE_NAME/files/Music/calls/ 2>/dev/null"
if ($recordings) {
    Write-Host $recordings
} else {
    Write-Host "Directory not created yet (will be created on first call)" -ForegroundColor Gray
}
Write-Host ""

# Start log monitoring
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Starting Log Monitoring" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Watch Terminal 1: Flutter logs (flutter logs)" -ForegroundColor Yellow
Write-Host "Watch Terminal 2: CallRecorderService logs (this terminal)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Yellow
Write-Host ""

# Monitor logs
adb logcat -c  # Clear existing logs
adb logcat | Select-String -Pattern "CallRecorderService|recording|upload|supabase|tigger/recorder" -CaseSensitive:$false

