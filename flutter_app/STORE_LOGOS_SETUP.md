# 🏪 Store Logos Setup Guide

## ✅ What I've Done:

1. ✅ Created `assets/images/stores/` directory
2. ✅ Updated `pubspec.yaml` to include store logo assets
3. ✅ Updated home screen code to use local logo images
4. ✅ Added support for 5 stores: Lotus, JayaGrocer, Mydin, NSK, AEON

## 📁 Where to Place Your Logo Images:

Place your logo images in this directory:
```
assets/images/stores/
```

## 📝 Required Logo Files:

Save your logo images with these **exact filenames**:

1. **lotus.png** - Lotus's logo
2. **jaya_grocer.png** - Jaya Grocer logo  
3. **mydin.png** - MYDIN logo
4. **nsk_grocer.png** - NSK Grocer logo
5. **aeon.png** - AEON logo

## 🎨 Image Requirements:

- **Format:** PNG (preferred with transparent background)
- **Size:** 200x200px minimum (or higher for better quality)
- **Aspect Ratio:** Square (1:1) recommended
- **Background:** Transparent or white

## 🚀 After Adding Images:

1. **Save the images** in `assets/images/stores/` with the exact filenames above
2. **Run this command:**
   ```bash
   flutter pub get
   ```
3. **Restart your app** (full restart, not just hot reload)

## 🔍 How It Works:

- The home screen will automatically load logos from local assets
- If a logo is missing, it will show a fallback (first letter of store name)
- Logos are clickable and navigate to store websites

## 📍 Current Store List on Home Screen:

1. **Lotus** → Opens https://www.lotuss.com.my
2. **JayaGrocer** → Opens https://www.jayagrocer.com
3. **Mydin** → Opens https://www.mydin.com.my
4. **NSK** → Opens https://www.nskgrocer.com
5. **AEON** → Opens https://www.aeon.com.my

## ✅ Code Changes Made:

- ✅ `pubspec.yaml` - Added assets configuration
- ✅ `home_screen.dart` - Updated to use `Image.asset()` instead of `Image.network()`
- ✅ Added `_getStoreLogoAsset()` method to map store names to asset paths
- ✅ Updated `_buildStoreLogo()` to load from local assets

## 🎯 Next Steps:

1. **Add your logo images** to `assets/images/stores/`
2. **Run `flutter pub get`**
3. **Restart the app**
4. **Test the logos** on the home screen!

---

**Note:** If you don't have the logo images yet, the app will still work - it will just show the first letter of each store name as a fallback.


