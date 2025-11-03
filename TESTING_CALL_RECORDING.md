# Testing Call Recording Upload on Android Device

## Prerequisites

1. **Physical Android device** (with SIM card and phone service)
2. **Enable Developer Options** on your device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Developer Options will appear in Settings

3. **Connect Device (Choose one method):**

   **Option A: USB Debugging (Traditional)**
   - Settings → Developer Options → Enable USB Debugging
   - Connect device via USB cable
   
   **Option B: Wireless Debugging (Recommended for Testing)**
   - Settings → Developer Options → Wireless debugging
   - Enable "Wireless debugging"
   - Tap "Pair device with pairing code"
   - Note the **IP address and port** (e.g., 192.168.1.100:37000)
   - On your computer, run:
     ```bash
     adb pair <IP>:<PORT> <PAIRING_CODE>
     ```
   - Then connect:
     ```bash
     adb connect <IP>:<PORT>
     ```
   - Verify connection:
     ```bash
     adb devices
     ```

## Step-by-Step Testing Guide

### 1. Build and Install the App

```bash
# Connect your Android device via USB
# Verify device is connected
adb devices

# Build and install release APK (with all optimizations)
flutter build apk --release
flutter install

# OR build and install debug APK (easier for testing)
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### 2. Grant Required Permissions

The app needs these permissions for call recording:

**Manual Grant (via Settings):**
- Settings → Apps → TiggerOn → Permissions
- Grant:
  - ✅ **Phone** (for making calls)
  - ✅ **Microphone** (for recording)
  - ✅ **Storage** (for saving recordings)

**Or via ADB (faster):**
```bash
adb shell pm grant com.example.tigger android.permission.CALL_PHONE
adb shell pm grant com.example.tigger android.permission.RECORD_AUDIO
adb shell pm grant com.example.tigger android.permission.WRITE_EXTERNAL_STORAGE
adb shell pm grant com.example.tigger android.permission.READ_PHONE_STATE
```

### 3. Monitor Logs in Real-Time

Open **3 terminal windows**:

**Terminal 1 - Flutter/Dart Logs:**
```bash
flutter logs
```

**Terminal 2 - Android System Logs (Filter for CallRecorderService):**
```bash
adb logcat | grep -i "CallRecorderService\|tigger"
```

**Terminal 3 - All Android Logs (for debugging):**
```bash
adb logcat
```

**Or use Android Studio Logcat** for better filtering and search.

### 4. Testing the Call Flow

#### Test Scenario 1: Complete Call with Recording

1. **Make a call from the app** (to any phone number):
   - Navigate to a lead/customer screen
   - Tap the call button
   - Select "Call" when prompted

2. **During the call**, watch Terminal 2 for:
   ```
   CallRecorderService: CALL_STATE_OFFHOOK
   CallRecorderService: Recording started: /path/to/file.m4a
   ```

3. **End the call** (hang up from dialer)

4. **Watch for these log messages** in order:
   ```
   CallRecorderService: CALL_STATE_IDLE → stopping recording and service
   CallRecorderService: Recording stopped successfully
   Waiting for call to end before uploading recording...
   Call ended detected after Xms
   Call ended. Waiting for recording to finalize...
   Starting recording upload process...
   Recording file found and ready: /path/to/file.m4a (XXXX bytes)
   Uploading recording to Supabase: /path/to/file.m4a
   Recording uploaded successfully: https://...
   Call record updated with recording URL: Yes
   ```

### 5. Verify Recording Upload

#### Option A: Check Database Directly

```bash
# Using Supabase MCP or SQL
SELECT id, phone, recording_url, created_at 
FROM calls 
ORDER BY created_at DESC 
LIMIT 5;
```

#### Option B: Check Supabase Storage Dashboard
1. Go to Supabase Dashboard
2. Navigate to **Storage** → **recordings** bucket
3. Check **calls/** folder
4. You should see files like: `1704067200000_call_XXXXXXXX_20240103_120000.m4a`

#### Option C: Check in App
- Navigate to call history/logs in the app
- Verify the recording URL appears in the call details

### 6. Test Edge Cases

#### Test 1: Quick Call (< 5 seconds)
- Make a very short call
- Verify recording still uploads (may be small file)

#### Test 2: No Network During Upload
- Make a call
- Turn off WiFi/Mobile data before call ends
- Verify error handling
- Turn data back on
- Check if retry mechanism works

#### Test 3: Call Interrupted
- Start call
- Force close the app mid-call
- Reopen app
- Check if recording still processes

### 7. Troubleshooting

#### Issue: Recording URL is NULL

**Check logs for:**
```bash
adb logcat | grep -i "recording\|upload\|supabase"
```

**Common causes:**
1. **File not found**: Check if recording file exists
   ```bash
   adb shell ls -lh /storage/emulated/0/Android/data/com.example.tigger/files/Music/calls/
   ```

2. **Upload failed**: Look for Supabase errors
   - Check network connectivity
   - Verify Supabase credentials in `constants.dart`
   - Check storage bucket permissions

3. **Call state not detected**: Check if `hasCallEnded` returns true
   ```bash
   adb logcat | grep "isCallActive\|hasCallEnded"
   ```

#### Issue: Permission Denied

**Check permissions:**
```bash
adb shell dumpsys package com.example.tigger | grep permission
```

**Re-grant permissions:**
```bash
adb shell pm grant com.example.tigger android.permission.RECORD_AUDIO
```

#### Issue: Storage Bucket Missing

**Verify bucket exists:**
```sql
SELECT name, id FROM storage.buckets WHERE name = 'recordings';
```

**Check bucket policies:**
```sql
SELECT * FROM storage.policies WHERE bucket_id = 'recordings';
```

### 8. Debug Commands

#### Check Recording File Location
```bash
adb shell find /storage -name "*.m4a" -type f 2>/dev/null | grep tigger
```

#### Check File Size
```bash
adb shell ls -lh /storage/emulated/0/Android/data/com.example.tigger/files/Music/calls/
```

#### Check App State
```bash
adb shell dumpsys activity activities | grep tigger
```

#### Clear App Data (Start Fresh)
```bash
adb shell pm clear com.example.tigger
```

### 9. Expected Behavior

✅ **Success Indicators:**
- Call connects successfully
- Recording notification appears during call
- After call ends, logs show "Recording uploaded successfully"
- Database shows non-null `recording_url`
- Storage bucket contains the recording file

❌ **Failure Indicators:**
- No recording notification
- Logs show "No recording file found"
- Database `recording_url` is NULL
- Error messages in logs

### 10. Performance Testing

**Test long calls:**
- Make a 10+ minute call
- Verify large file uploads correctly
- Check file size in storage

**Test multiple consecutive calls:**
- Make 3-5 calls in a row
- Verify each recording uploads independently
- Check no conflicts in file naming

## Quick Test Checklist

- [ ] App installed successfully
- [ ] Permissions granted
- [ ] Logs monitoring active
- [ ] Call placed successfully
- [ ] Recording notification appears
- [ ] Call ends properly
- [ ] Logs show "Call ended detected"
- [ ] Logs show "Recording uploaded successfully"
- [ ] Database has recording_url
- [ ] Storage bucket has file

## Common Log Patterns

**Successful Upload:**
```
CallRecorderService: CALL_STATE_IDLE
CallRecorderService: Recording stopped successfully
Waiting for call to end before uploading recording...
Call ended detected after Xms
Recording file found and ready: /path/file.m4a (XXXX bytes)
Uploading recording to Supabase
Recording uploaded successfully: https://...
```

**Failed Upload:**
```
Recording upload failed: [Error message]
Failed to upload recording after 3 attempts
No recording URL obtained after upload attempt
```

Use these patterns to quickly identify issues in your logs!

