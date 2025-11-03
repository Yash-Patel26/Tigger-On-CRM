# Wireless Debugging Setup Guide

## Why Wireless Debugging?

- ✅ **No USB cable needed** - test while device is in your pocket/hands
- ✅ **Better for call testing** - phone can move naturally during calls
- ✅ **Multiple devices** - connect multiple devices simultaneously
- ✅ **Same functionality** - all ADB commands work the same

## Prerequisites

- Android 11+ (API level 30+) device
- Phone and computer on **same WiFi network**
- Developer Options enabled

## Step-by-Step Setup

### 1. Enable Developer Options

1. Go to **Settings** → **About Phone**
2. Find **Build Number**
3. Tap **Build Number 7 times** until you see "You are now a developer!"
4. Go back to Settings → **Developer Options** should now be visible

### 2. Enable Wireless Debugging

1. Open **Settings** → **Developer Options**
2. Scroll down to **Wireless debugging**
3. Toggle **Wireless debugging** ON
4. Accept the warning prompt

### 3. Pair Device (First Time Only)

**On Your Android Device:**
1. Tap **"Pair device with pairing code"**
2. Note down:
   - **IP Address and Port** (e.g., `192.168.1.100:37000`)
   - **Pairing Code** (6-digit number, e.g., `123456`)

**On Your Computer (PowerShell/CMD):**
```powershell
adb pair 192.168.1.100:37000 123456
```

You should see:
```
Successfully paired to 192.168.1.100:37000
```

### 4. Connect to Device

**On Your Android Device:**
- Check the **IP address and port** shown under "IP address" (e.g., `192.168.1.100:37001`)

**On Your Computer:**
```powershell
adb connect 192.168.1.100:37001
```

You should see:
```
connected to 192.168.1.100:37001
```

### 5. Verify Connection

```powershell
adb devices
```

You should see:
```
List of devices attached
192.168.1.100:37001    device
```

## Quick Connection Script

Save this as `connect_wireless.ps1`:

```powershell
# Wireless Debugging Quick Connect Script
# Usage: .\connect_wireless.ps1 <IP>:<PORT> <PAIRING_CODE>

param(
    [Parameter(Mandatory=$true)]
    [string]$PairingAddress,
    
    [Parameter(Mandatory=$true)]
    [string]$PairingCode
)

Write-Host "Pairing device..." -ForegroundColor Yellow
adb pair $PairingAddress $PairingCode

Write-Host "`nPlease check your device for the connection IP and port" -ForegroundColor Cyan
Write-Host "Then run: adb connect <IP>:<PORT>" -ForegroundColor Cyan

# Try to get connection address (may vary)
$connectionPort = ($PairingAddress -split ':')[1]
$connectionPort = ([int]$connectionPort + 1).ToString()
$connectionIP = ($PairingAddress -split ':')[0]
$connectionAddress = "$connectionIP`:$connectionPort"

Write-Host "`nAttempting to connect to: $connectionAddress" -ForegroundColor Yellow
adb connect $connectionAddress

Write-Host "`nVerifying connection..." -ForegroundColor Yellow
adb devices
```

## Automatic Connection (Advanced)

For faster reconnection, you can save your device's IP address:

```powershell
# Save your device IP (run once after pairing)
$deviceIP = "192.168.1.100:37001"
echo $deviceIP > .device_ip.txt

# Quick reconnect script (connect_wireless_quick.ps1)
$deviceIP = Get-Content .device_ip.txt
adb connect $deviceIP
adb devices
```

## Troubleshooting

### Issue: "Unable to connect"

**Solutions:**
1. **Check WiFi**: Ensure phone and computer are on same network
2. **Check IP address**: IP might change if you reconnect to WiFi
3. **Restart wireless debugging**: Toggle OFF and ON in Developer Options
4. **Firewall**: Allow ADB through Windows Firewall

### Issue: "Device unauthorized"

**Solutions:**
1. Check phone for USB debugging authorization prompt
2. Tap "Always allow from this computer" and "Allow"

### Issue: Connection drops frequently

**Solutions:**
1. Keep phone screen on during testing
2. Disable battery optimization for Developer Options
3. Keep phone within WiFi range

### Issue: Can't find pairing code

**If pairing screen disappeared:**
1. Go to Settings → Developer Options → Wireless debugging
2. Tap the **gear icon** (⚙️) next to "Wireless debugging"
3. Tap "Pair device with pairing code" again

## Testing Call Recording Wirelessly

Once connected wirelessly, all commands work the same:

```powershell
# Grant permissions
adb shell pm grant com.example.tigger android.permission.CALL_PHONE
adb shell pm grant com.example.tigger android.permission.RECORD_AUDIO

# Monitor logs
adb logcat | findstr /i "CallRecorderService recording"

# Install app
flutter install

# Check files
adb shell ls -lh /storage/emulated/0/Android/data/com.example.tigger/files/Music/calls/
```

## Advantages for Call Recording Testing

✅ **Natural testing** - Make calls while device is in your hand  
✅ **Better mobility** - Walk around during testing  
✅ **Real-world scenarios** - Test in different locations/positions  
✅ **No cable interference** - Phone can move freely during calls  
✅ **Multiple testers** - Multiple developers can connect simultaneously  

## Reconnecting After Disconnect

If connection drops:

1. **Quick reconnect** (if IP hasn't changed):
   ```powershell
   adb connect 192.168.1.100:37001
   ```

2. **If IP changed**:
   - Check new IP in Wireless debugging settings
   - Reconnect using new IP
   - No need to pair again (pairing is one-time)

3. **Full reset**:
   - Toggle Wireless debugging OFF and ON
   - Pair again (if needed)

## Security Notes

⚠️ **Important:**
- Only use on trusted networks (your home/work WiFi)
- Wireless debugging exposes your device - use carefully
- Disable when not testing
- Don't use on public WiFi networks

## Platform-Specific Commands

### Windows PowerShell
```powershell
adb pair <IP>:<PORT> <CODE>
adb connect <IP>:<PORT>
adb devices
```

### Windows CMD
```cmd
adb pair <IP>:<PORT> <CODE>
adb connect <IP>:<PORT>
adb devices
```

### Linux/Mac
```bash
adb pair <IP>:<PORT> <CODE>
adb connect <IP>:<PORT>
adb devices
```

## Quick Reference Card

```
1. Settings → Developer Options → Wireless debugging → ON
2. Tap "Pair device with pairing code"
3. Note: IP:PORT and 6-digit code
4. Run: adb pair <IP>:<PORT> <CODE>
5. Check device for connection IP:PORT
6. Run: adb connect <IP>:<PORT>
7. Verify: adb devices
```

## Testing Checklist with Wireless Debugging

- [ ] Developer Options enabled
- [ ] Wireless debugging enabled
- [ ] Phone and computer on same WiFi
- [ ] Device paired (one-time)
- [ ] Device connected (`adb devices` shows device)
- [ ] Permissions granted
- [ ] Logs monitoring active
- [ ] Ready to test call recording!

