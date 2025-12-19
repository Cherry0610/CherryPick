# 📱 App Icon Setup Guide

## Overview

This guide will help you change the app icon from the default Flutter icon to your custom CherryPick app icon.

## Step 1: Prepare Your Icon Image

1. **Create or obtain your app icon image**
   - Recommended size: **1024x1024 pixels** (square)
   - Format: **PNG** (with transparent background if needed)
   - The icon should be clear and recognizable at small sizes

2. **Save the icon as `app_icon.png`**
   - Place it in: `assets/images/app_icon.png`

## Step 2: Generate App Icons

Once you've placed your `app_icon.png` file in `assets/images/`, run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically:
- ✅ Generate all required icon sizes for Android
- ✅ Generate all required icon sizes for iOS
- ✅ Generate icons for web, Windows, and macOS (if configured)
- ✅ Update all necessary configuration files

## Step 3: Verify the Icons

### For Android:
- Icons will be generated in:
  - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

### For iOS:
- Icons will be generated in:
  - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - All required sizes (20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024)

## Step 4: Test the Icon

1. **For Android:**
   ```bash
   flutter run
   ```
   - Uninstall the app from your device/emulator first
   - Reinstall to see the new icon

2. **For iOS:**
   ```bash
   flutter run
   ```
   - Clean build folder: `flutter clean`
   - Rebuild: `flutter build ios`
   - Or use Xcode to rebuild

## Current Configuration

The `pubspec.yaml` is already configured with:
- ✅ Android icon generation enabled
- ✅ iOS icon generation enabled
- ✅ Web icon generation enabled
- ✅ Windows icon generation enabled
- ✅ macOS icon generation enabled
- ✅ Icon path: `assets/images/app_icon.png`

## Troubleshooting

### Icon not updating?
1. **Clean the build:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **For Android:**
   - Uninstall the app completely
   - Rebuild and reinstall

3. **For iOS:**
   - Clean Xcode build folder (Product → Clean Build Folder)
   - Delete derived data
   - Rebuild

### Icon looks blurry?
- Make sure your source image is at least 1024x1024 pixels
- Use PNG format for best quality
- Avoid using JPG (can cause compression artifacts)

### Icon has wrong background?
- Use PNG with transparent background
- Or ensure the background color matches your design

## Icon Design Tips

1. **Keep it simple**: Icons are displayed at small sizes
2. **Use high contrast**: Make sure it's visible on different backgrounds
3. **Test at small sizes**: Preview your icon at 48x48 and 96x96 pixels
4. **Follow platform guidelines:**
   - [Android Icon Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design)
   - [iOS Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)

## Next Steps

1. ✅ Place your `app_icon.png` in `assets/images/`
2. ✅ Run `flutter pub get`
3. ✅ Run `flutter pub run flutter_launcher_icons`
4. ✅ Test on your device/emulator

## Notes

- The icon generation tool automatically creates all required sizes
- You only need to provide one high-resolution image (1024x1024)
- The tool handles all platform-specific requirements
- Icons are generated once - you don't need to regenerate unless you change the source image


