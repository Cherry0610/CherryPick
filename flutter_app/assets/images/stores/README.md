# Store Logos

Place your store logo images in this directory with the following filenames:

## Required Logo Files:

1. **lotus.png** - Lotus's logo
2. **jaya_grocer.png** - Jaya Grocer logo
3. **mydin.png** - MYDIN logo
4. **nsk_grocer.png** - NSK Grocer logo
5. **aeon.png** - AEON logo

## Image Requirements:

- **Format:** PNG (with transparent background recommended)
- **Size:** 200x200px minimum (or higher resolution for better quality)
- **Aspect Ratio:** Square (1:1) recommended
- **Background:** Transparent or white background

## How to Add Images:

1. Save your logo images with the exact filenames listed above
2. Place them in this directory: `assets/images/stores/`
3. Run `flutter pub get` to refresh assets
4. Restart your app

## File Structure:

```
assets/
  images/
    stores/
      ├── lotus.png
      ├── jaya_grocer.png
      ├── mydin.png
      ├── nsk_grocer.png
      └── aeon.png
```

## Notes:

- If a logo file is missing, the app will show a fallback (first letter of store name)
- Make sure the filenames match exactly (case-sensitive)
- After adding images, you may need to do a full app restart (not just hot reload)


