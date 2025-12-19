# App Logo Setup Guide

## Where to Place Your Logo

Your app logo should be placed at:
```
assets/images/logo.png
```

## Logo Requirements

- **File format**: PNG (recommended) or JPG
- **Recommended size**: 512x512 pixels or higher (for best quality)
- **Aspect ratio**: 1:1 (square)
- **Background**: Transparent background recommended

## Current Status

✅ **Code is ready**: Both sign-in and sign-up screens are configured to display your logo.

⚠️ **Logo file missing**: The logo file `assets/images/logo.png` is currently missing.

## What Happens Now

- If the logo file exists: It will be displayed on the login and sign-up screens
- If the logo file is missing: A shopping cart icon will be shown as a fallback

## How to Add Your Logo

1. Create or obtain your app logo image
2. Save it as `logo.png`
3. Place it in the `assets/images/` folder
4. Restart your Flutter app

The logo will automatically appear on:
- Sign In Screen (top left, next to "SmartPrice" text)
- Sign Up Screen (top left, next to "SmartPrice" text)

## Notes

- The logo is displayed in a 56x56 pixel container with rounded corners
- The logo has a red background container (`#D94C4C`)
- The logo will automatically scale to fit the container while maintaining aspect ratio


