# 📸 Product Images Import Guide

## ✅ Current Product Images (7 images)

All product images are located in: `assets/images/products/`

1. ✅ `anchor_butter.png` - Anchor Butter
2. ✅ `ayam_brand_canned_tuna.png` - Ayam Brand Canned Tuna
3. ✅ `ayam_brand_whole_chicken.png` - Whole Chicken
4. ✅ `fresh_ikan_kembung.png` - Fresh Ikan Kembung
5. ✅ `kellogg's_cornflakes.png` - Kellogg's Cornflakes
6. ✅ `maggi_instant_noodle.png` - Maggi Instant Noodles
7. ✅ `minced_beef.png` - Minced Beef

## 🔧 How Product Images Work

### Automatic Matching
The app automatically matches product images based on:
- **Product Name** (case-insensitive)
- **Brand Name** (when available)

### Current Product Mappings

| Product Name | Brand | Image File |
|-------------|-------|------------|
| Minced Beef | (any) | `minced_beef.png` |
| Butter | Anchor | `anchor_butter.png` |
| Cornflakes | Kellogg's | `kellogg's_cornflakes.png` |
| Fresh Ikan Kembung | (any) | `fresh_ikan_kembung.png` |
| Canned Tuna | Ayam Brand | `ayam_brand_canned_tuna.png` |
| Whole Chicken | (any) | `ayam_brand_whole_chicken.png` |
| Instant Noodles | Maggi | `maggi_instant_noodle.png` |

## 📥 How to Add New Product Images

### Step 1: Add Image File
1. Save your product image as PNG format
2. Use lowercase with underscores: `product_name_brand.png`
   - Example: `coca_cola_soft_drink.png`
3. Place it in: `assets/images/products/`

### Step 2: Update the Mapping Function
Edit: `lib/frontend/widgets/product_image_widget.dart`

Find the `_getProductImageAsset()` function and add your mapping:

```dart
// Example: Adding Coca-Cola Soft Drink
if (normalizedName.contains('soft drink') && 
    normalizedBrand.contains('coca cola')) {
  return 'assets/images/products/coca_cola_soft_drink.png';
}
```

### Step 3: Verify Asset Declaration
Check `pubspec.yaml` - it should have:
```yaml
flutter:
  assets:
    - assets/images/
```

This includes all subfolders, so `assets/images/products/` is automatically included.

### Step 4: Restart the App
After adding new images:
1. Stop the app
2. Run `flutter clean` (optional but recommended)
3. Run `flutter pub get`
4. Restart the app

## 🎯 Image Naming Best Practices

### Good Names:
- ✅ `coca_cola_soft_drink.png`
- ✅ `ayam_brand_canned_tuna.png`
- ✅ `kellogg's_cornflakes.png`
- ✅ `fresh_ikan_kembung.png`

### Bad Names:
- ❌ `Coca Cola.png` (spaces, uppercase)
- ❌ `coca-cola.png` (hyphens)
- ❌ `product1.png` (not descriptive)

## 🔍 Troubleshooting

### Images Not Showing?

1. **Check file exists:**
   ```bash
   ls -la assets/images/products/your_image.png
   ```

2. **Check asset path in code:**
   - Should be: `assets/images/products/your_image.png`
   - NOT: `assets/images/products/Your_Image.png` (case-sensitive)

3. **Verify pubspec.yaml:**
   - Should have: `- assets/images/`
   - Run: `flutter pub get`

4. **Check product name matching:**
   - Product name matching is case-insensitive
   - But must contain the keywords you specified

5. **Restart the app:**
   - Hot reload might not pick up new assets
   - Do a full restart

### Common Issues:

**Issue:** Image shows fallback icon
- **Solution:** Check product name/brand matches your mapping exactly

**Issue:** Image not found error
- **Solution:** Verify file name matches exactly (case-sensitive for file system)

**Issue:** Image appears after restart but not hot reload
- **Solution:** This is normal - new assets require full restart

## 📋 Quick Reference

### Where to Edit:
- **Mapping Logic:** `lib/frontend/widgets/product_image_widget.dart`
- **Product Data:** `lib/frontend/screens/general/home_screen.dart` (in `_forYouProductData`)

### Image Requirements:
- **Format:** PNG (recommended) or JPG
- **Size:** 400x400px or larger (for best quality)
- **Location:** `assets/images/products/`
- **Naming:** lowercase_with_underscores.png

## 🚀 Example: Adding a New Product Image

Let's say you want to add an image for "Coca-Cola Soft Drink":

1. **Save image as:** `assets/images/products/coca_cola_soft_drink.png`

2. **Add to mapping in `product_image_widget.dart`:**
```dart
// Inside _getProductImageAsset() function
if ((normalizedName.contains('soft drink') || normalizedName.contains('cola')) &&
    normalizedBrand.contains('coca cola')) {
  return 'assets/images/products/coca_cola_soft_drink.png';
}
```

3. **Restart the app** - Done! ✅

The image will automatically appear for any product with:
- Product name containing "soft drink" or "cola"
- Brand containing "coca cola"


