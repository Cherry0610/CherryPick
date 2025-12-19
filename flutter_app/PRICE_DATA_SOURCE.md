# 💰 Price Data Source Explanation

## Current Status

### ❌ **Hardcoded Prices (Current Implementation)**
The product details screen currently uses **hardcoded prices** stored directly in the code:
- Location: `lib/frontend/screens/price_comparison/product_details_screen.dart`
- Method: `_getStorePrices()` function with hardcoded price maps
- Example: `'RM9.90'`, `'RM4.99'`, etc. are written directly in the code

**Why this is a problem:**
- Prices are not real/current
- Prices don't update automatically
- Limited to products we manually add
- Not scalable

---

### ✅ **Real Price Services (Available but Not Connected)**

Your app has **real price fetching services** ready, but they're not being used in the product details screen:

#### 1. **PriceComparisonService**
- Location: `lib/backend/services/price_comparison_service.dart`
- Fetches prices from:
  - **Firestore database** (your local price database)
  - **GroceryStoreApiService** (online stores)

#### 2. **GroceryStoreApiService**
- Location: `lib/backend/services/grocery_store_api_service.dart`
- Fetches real prices from:
  - ✅ **Shopee Malaysia** - Real API (working)
  - ⚠️ **Lazada Malaysia** - Web scraping (needs HTML parsing)
  - ⚠️ **GrabMart** - Web scraping (needs HTML parsing)
  - ⚠️ **Tesco, Giant, AEON, NSK, Village Grocer, Jaya Grocer** - Web scraping (needs HTML parsing)

#### 3. **GroceryWebScraper**
- Location: `lib/backend/services/grocery_web_scraper.dart`
- Handles web scraping for stores without APIs
- Currently has Shopee working, others need HTML parsing implementation

---

## 🔧 How to Get Real Prices

### Option 1: Use Real Services (Recommended)
I've updated the product details screen to fetch real prices from:
1. **Firestore** - Your local price database
2. **Shopee API** - Real-time prices from Shopee Malaysia
3. **Other stores** - Once HTML parsing is implemented

### Option 2: Manual Price Entry
You can manually add prices to Firestore:
- Collection: `prices`
- Fields: `productId`, `storeId`, `price`, `validFrom`, etc.

### Option 3: Receipt OCR
When users upload receipts, prices are automatically extracted and added to the database.

---

## 📊 Current Price Sources

### Working Now:
- ✅ **Shopee Malaysia** - Real API prices
- ✅ **Firestore** - Prices from your database

### Needs Implementation:
- ⚠️ **Lazada** - HTML parsing needed
- ⚠️ **GrabMart** - HTML parsing needed
- ⚠️ **Tesco, Giant, AEON, NSK, Village Grocer, Jaya Grocer** - HTML parsing needed

---

## 🚀 Next Steps

1. **Test Real Prices**: The product details screen now tries to fetch real prices first
2. **Complete HTML Parsing**: Implement parsing for other stores (see `REAL_DATA_INTEGRATION.md`)
3. **Add More Products**: Add products to Firestore or let users add via receipts
4. **Monitor Prices**: Set up background jobs to update prices regularly

---

## 💡 Summary

**Where prices come from:**
- Currently: Hardcoded in the code (not real)
- Available: Real services that fetch from Shopee and Firestore
- Future: All stores once HTML parsing is complete

The app is now updated to use real prices when available, with fallback to hardcoded prices if real data isn't found.



