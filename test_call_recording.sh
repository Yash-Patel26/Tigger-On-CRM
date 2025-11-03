#!/bin/bash

# Quick Testing Script for Call Recording on Android Device
# Usage: ./test_call_recording.sh

PACKAGE_NAME="com.example.tigger"
APP_NAME="TiggerOn"

echo "=========================================="
echo "Call Recording Test Helper"
echo "=========================================="
echo ""

# Check if device is connected
echo "Checking for connected devices..."
DEVICES=$(adb devices | grep -v "List" | grep "device" | wc -l)
if [ $DEVICES -eq 0 ]; then
    echo "❌ No Android device connected!"
    echo "Please connect your device via USB and enable USB debugging."
    exit 1
fi
echo "✅ Device connected"
echo ""

# Grant permissions
echo "Granting required permissions..."
adb shell pm grant $PACKAGE_NAME android.permission.CALL_PHONE
adb shell pm grant $PACKAGE_NAME android.permission.RECORD_AUDIO
adb shell pm grant $PACKAGE_NAME android.permission.WRITE_EXTERNAL_STORAGE
adb shell pm grant $PACKAGE_NAME android.permission.READ_PHONE_STATE
echo "✅ Permissions granted"
echo ""

# Check if app is installed
echo "Checking if app is installed..."
INSTALLED=$(adb shell pm list packages | grep $PACKAGE_NAME)
if [ -z "$INSTALLED" ]; then
    echo "⚠️  App not installed. Building and installing..."
    flutter build apk --debug
    adb install build/app/outputs/flutter-apk/app-debug.apk
    echo "✅ App installed"
else
    echo "✅ App is installed"
fi
echo ""

# Show recording directory
echo "Recording directory location:"
adb shell "ls -lh /storage/emulated/0/Android/data/$PACKAGE_NAME/files/Music/calls/ 2>/dev/null || echo 'Directory not created yet (will be created on first call)'"
echo ""

# Start log monitoring
echo "=========================================="
echo "Starting Log Monitoring"
echo "=========================================="
echo "Watch Terminal 1: Flutter logs (flutter logs)"
echo "Watch Terminal 2: CallRecorderService logs (this terminal)"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo ""

# Monitor logs
adb logcat -c  # Clear existing logs
adb logcat | grep --line-buffered -i "CallRecorderService\|recording\|upload\|supabase\|tigger/recorder" --color=always

