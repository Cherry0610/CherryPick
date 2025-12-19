# CherryPick App Structure & Feature Checklist

## 📱 Main Screens / Modules

### 1. Home / Dashboard ✅
**Location:** `lib/screens/general/home_screen.dart`

**Required Features:**
- [x] Quick Search Bar for products
- [x] Access to Trending Deals (sales/promotions)
- [x] Quick links to Wishlist
- [x] Quick links to Financial Tracker

**Status:** ✅ Implemented

---

### 2. Price Comparison & Search ✅
**Location:** `lib/screens/price_comparison/`

**Required Features:**
- [x] Product Search Results (`search_screen.dart`)
- [x] Product Detail Page (`product_details_screen.dart`)
  - [ ] Shows all retailers
  - [ ] Shows prices
  - [ ] Shows shipping costs
  - [ ] Price History Graph
- [ ] Advanced Filters
  - [ ] Filter by retailer
  - [ ] Filter by price range
  - [ ] Filter by brand
  - [ ] Filter by dietary needs
- [ ] Image/Barcode Scanner (camera integration)
- [x] Comparison View (`compare_screen.dart`)

**Status:** ⚠️ Partially Implemented - Need to add:
- Price history graph
- Advanced filters
- Barcode/image scanner

---

### 3. Wishlist & Alerts ✅
**Location:** `lib/screens/wishlist/`

**Required Features:**
- [x] Wishlist (`wishlist_screen.dart`)
- [x] Set Target Price (`wishlist_screen.dart`)
- [x] Price History (`price_history_screen.dart`)
- [ ] Notifications Log
  - [ ] Shows alerts when price drops
  - [ ] Notification history

**Status:** ⚠️ Partially Implemented - Need to add:
- Notifications log screen
- Push notification integration

---

### 4. Financial Tracker ✅
**Location:** `lib/screens/money_tracker/`

**Required Features:**
- [x] Expense Input (`add_expense_screen.dart`)
- [x] Receipt Scanner (OCR) (`upload_receipt_screen.dart`)
- [x] Receipts List (`receipts_screen.dart`)
- [x] Monthly Expenses Report (`expense_breakdown_screen.dart`)
  - [ ] Visual breakdown (charts)
  - [ ] Spending by category
  - [ ] Spending by month
- [x] Budget Setup (`budget_setup_screen.dart`)
- [x] Money Tracker Overview (`money_tracker_overview_screen.dart`)

**Status:** ⚠️ Partially Implemented - Need to add:
- Charts/visualizations for expense breakdown
- Category-based spending analysis

---

### 5. Nearby Store / Navigation ✅
**Location:** `lib/screens/map/`

**Required Features:**
- [x] Store Locator Map (`nearby_store_screen.dart`)
- [x] Store Details (`store_details_screen.dart`)
- [ ] Directions & Time
  - [ ] Waze-like routes
  - [ ] Estimated Distance
  - [ ] Travel Time (with traffic)
  - [ ] Toll Fees information
- [ ] Retailer Info Card
  - [ ] Store hours
  - [ ] Address
  - [ ] Link to online web store

**Status:** ⚠️ Partially Implemented - Need to add:
- Navigation/directions integration
- Traffic-aware routing
- Toll fee calculation
- Store hours display
- Web store links

---

### 6. Profile & Settings ✅
**Location:** `lib/screens/general/profile_screen.dart` & `settings_screen.dart`

**Required Features:**
- [x] Account Management
  - [ ] User details
  - [ ] Login/security settings
- [ ] App Preferences
  - [ ] Preferred currency
  - [ ] Default grocery store chains
- [ ] History
  - [ ] Past shopping lists
  - [ ] Reports history
  - [ ] Notification history

**Status:** ⚠️ Partially Implemented - Need to add:
- User details editing
- Security settings
- App preferences screen
- History screens

---

## 🎨 Additional Features

### Accessibility Module ✅
**Location:** `lib/screens/accessibility/`

- [x] Complete onboarding flow
- [x] Settings and customization
- [x] Help & support screens

---

## 📋 Implementation Priority

### High Priority (Core Features)
1. **Price History Graph** - Product detail page
2. **Advanced Filters** - Search screen
3. **Barcode/Image Scanner** - Product search
4. **Charts for Expenses** - Financial tracker
5. **Navigation Integration** - Store locator

### Medium Priority (Enhancements)
1. **Notifications Log** - Wishlist alerts
2. **Store Hours & Links** - Store details
3. **App Preferences** - Settings
4. **Shopping Lists History** - Profile

### Low Priority (Nice to Have)
1. **Traffic-aware routing** - Navigation
2. **Toll fee calculator** - Navigation
3. **Category spending analysis** - Financial tracker

---

## 🔗 Navigation Flow

```
Splash → Onboarding → Auth → Home Dashboard
                              ├─ Search Products
                              ├─ Trending Deals
                              ├─ Quick Links
                              │   ├─ Wishlist
                              │   └─ Financial Tracker
                              │
                              ├─ Price Comparison
                              │   ├─ Search Results
                              │   ├─ Product Details
                              │   │   ├─ Retailers
                              │   │   ├─ Prices
                              │   │   ├─ Price History Graph
                              │   │   └─ Comparison
                              │   └─ Filters
                              │
                              ├─ Wishlist
                              │   ├─ Saved Products
                              │   ├─ Target Prices
                              │   ├─ Price History
                              │   └─ Notifications Log
                              │
                              ├─ Financial Tracker
                              │   ├─ Add Expense
                              │   ├─ Receipt Scanner
                              │   ├─ Monthly Reports
                              │   └─ Budget Setup
                              │
                              ├─ Nearby Stores
                              │   ├─ Map View
                              │   ├─ Store Details
                              │   └─ Navigation
                              │
                              └─ Profile
                                  ├─ Account Settings
                                  ├─ App Preferences
                                  └─ History
```

---

## 📝 Notes

- All screens follow black & white theme for accessibility
- Firebase integration for backend services
- Google Maps integration for store locator
- OCR integration for receipt scanning
- Push notifications for price alerts


