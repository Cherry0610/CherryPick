# 🔧 Troubleshooting: Can't Launch on Phone

## ✅ Fixed Issues
- ✅ Fixed import paths in `main.dart` (changed `General` to `general`)
- ✅ Dependencies are installed
- ✅ No code errors found

## 📱 Steps to Launch on Your Phone

### For iOS (iPhone):

1. **Connect Your iPhone via USB Cable**
   ```bash
   # Make sure your phone is unlocked and connected
   flutter devices
   ```

2. **Trust Your Computer**
   - When you connect, your iPhone will ask "Trust This Computer?"
   - Tap "Trust" and enter your passcode

3. **Enable Developer Mode** (iOS 16+)
   - Go to: Settings → Privacy & Security → Developer Mode
   - Toggle it ON
   - Restart your iPhone

4. **Trust Developer Certificate**
   - First time: Settings → General → VPN & Device Management
   - Tap on your developer certificate
   - Tap "Trust"

5. **Build and Run**
   ```bash
   cd flutter_app
   flutter run
   ```

### For Android:

1. **Enable Developer Options**
   - Go to: Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options

2. **Enable USB Debugging**
   - In Developer Options, enable "USB Debugging"
   - Connect phone via USB

3. **Authorize Computer**
   - When connected, phone will show "Allow USB Debugging?"
   - Check "Always allow from this computer"
   - Tap "OK"

4. **Build and Run**
   ```bash
   cd flutter_app
   flutter run
   ```

## 🔍 Check Device Connection

```bash
# List all connected devices
flutter devices

# If your phone doesn't show up:
# 1. Make sure USB cable is connected
# 2. Unlock your phone
# 3. Check if USB debugging is enabled (Android)
# 4. Check if Developer Mode is enabled (iOS)
```

## 🚨 Common Issues & Solutions

### Issue 1: "No devices found"
**Solution:**
- Unplug and replug USB cable
- Unlock your phone
- Restart your phone
- Try a different USB cable/port

### Issue 2: "Device not authorized" (Android)
**Solution:**
- Revoke USB debugging authorizations
- Settings → Developer Options → Revoke USB debugging authorizations
- Reconnect and authorize again

### Issue 3: "Developer Mode required" (iOS)
**Solution:**
- Settings → Privacy & Security → Developer Mode → ON
- Restart iPhone
- Reconnect

### Issue 4: Build fails with "code signing" error (iOS)
**Solution:**
```bash
# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select your team in Signing & Capabilities
# 2. Make sure "Automatically manage signing" is checked
```

### Issue 5: "Waiting for another flutter command"
**Solution:**
```bash
# Kill any running Flutter processes
killall -9 dart
killall -9 flutter

# Try again
flutter run
```

## 🎯 Quick Test Commands

```bash
# 1. Check Flutter setup
flutter doctor

# 2. Check connected devices
flutter devices

# 3. Clean and rebuild
flutter clean
flutter pub get
flutter run

# 4. Run on specific device
flutter run -d <device-id>
```

## 📲 Alternative: Use Simulator/Emulator

If physical device doesn't work, use simulator:

### iOS Simulator:
```bash
# List available simulators
xcrun simctl list devices

# Open iOS Simulator
open -a Simulator

# Run on simulator
flutter run
```

### Android Emulator:
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>

# Run on emulator
flutter run
```

## ✅ Verification Checklist

Before running, make sure:
- [ ] Phone is unlocked
- [ ] USB cable is connected
- [ ] Developer Mode enabled (iOS) or USB Debugging enabled (Android)
- [ ] Computer is trusted on phone
- [ ] Flutter doctor shows no critical issues
- [ ] `flutter devices` shows your phone
- [ ] No other Flutter processes running

## 🆘 Still Not Working?

1. **Check Flutter Doctor:**
   ```bash
   flutter doctor -v
   ```

2. **Check Device Logs:**
   ```bash
   # iOS
   flutter logs

   # Android
   adb logcat
   ```

3. **Try Building First:**
   ```bash
   # iOS
   flutter build ios --debug --no-codesign

   # Android
   flutter build apk --debug
   ```

4. **Check Xcode/Android Studio:**
   - Make sure Xcode is properly configured (iOS)
   - Make sure Android SDK is installed (Android)

## 📞 Next Steps

Once your device is connected:
```bash
cd flutter_app
flutter run
```

The app should launch on your phone! 🎉
