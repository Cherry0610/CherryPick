# 📊 Database Guide - Checking User Expenses & Wishlist

This guide shows you where to check user expenses and wishlist data in Firestore.

## 🔥 Firestore Collections

### 1. **Expenses Collection**
**Collection Name:** `expenses`

**Location in Code:**
- Service: `lib/backend/services/expense_tracking_service.dart`
- Line 12: `_firestore.collection('expenses').add(...)`

**Data Structure:**
```dart
{
  'id': String (auto-generated),
  'userId': String (Firebase Auth UID),
  'amount': double,
  'category': String,
  'description': String?,
  'date': Timestamp,
  'storeName': String?,
  'receiptId': String?,
  'createdAt': Timestamp,
  'updatedAt': Timestamp,
}
```

**How to Check:**
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Navigate to **Firestore Database**
4. Click on the `expenses` collection
5. Filter by `userId` to see a specific user's expenses

**Query for User Expenses:**
```dart
// In code, expenses are queried like this:
_firestore
  .collection('expenses')
  .where('userId', isEqualTo: userId)
  .orderBy('date', descending: true)
  .get();
```

---

### 2. **Wishlist Collection**
**Collection Name:** `wishlists`

**Location in Code:**
- Service: `lib/backend/services/wishlist_service.dart`
- Line 13: `_firestore.collection('wishlists').add(...)`

**Data Structure:**
```dart
{
  'id': String (auto-generated),
  'userId': String (Firebase Auth UID),
  'productId': String,
  'productName': String,
  'productImageUrl': String?,
  'targetPrice': double,
  'currency': String,
  'isActive': bool,
  'preferredStores': List<String>?,
  'notes': String?,
  'createdAt': Timestamp,
  'updatedAt': Timestamp,
  'lastNotifiedAt': Timestamp?,
}
```

**How to Check:**
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Navigate to **Firestore Database**
4. Click on the `wishlists` collection
5. Filter by `userId` and `isActive == true` to see active wishlist items

**Query for User Wishlist:**
```dart
// In code, wishlist is queried like this:
_firestore
  .collection('wishlists')
  .where('userId', isEqualTo: userId)
  .where('isActive', isEqualTo: true)
  .orderBy('createdAt', descending: true)
  .get();
```

---

### 3. **Users Collection** (Summary Data)
**Collection Name:** `users`

**Location in Code:**
- Service: `lib/backend/services/expense_tracking_service.dart`
- Line 27: `_firestore.collection('users').doc(userId)`

**Data Structure:**
```dart
{
  'userId': String (Firebase Auth UID),
  'expenseCount': int,
  'totalExpenses': double,
  'updatedAt': Timestamp,
  // ... other user data
}
```

**Note:** This collection stores summary/aggregated data for quick access.

---

## 🔍 How to Verify Database is Empty for First-Time Users

### Method 1: Using Firebase Console (Web UI)

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com
   - Select your project

2. **Check Expenses**
   - Navigate to **Firestore Database** → `expenses` collection
   - Use the filter: `userId == [USER_ID]`
   - Should show **0 documents** for a new user

3. **Check Wishlist**
   - Navigate to **Firestore Database** → `wishlists` collection
   - Use the filter: `userId == [USER_ID]` AND `isActive == true`
   - Should show **0 documents** for a new user

4. **Check User Summary**
   - Navigate to **Firestore Database** → `users` collection
   - Find document with ID = `[USER_ID]`
   - Should have `expenseCount: 0` and `totalExpenses: 0.0` (or not exist yet)

---

### Method 2: Using Flutter Code (Debug)

Add this debug code to check database state:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> checkUserDatabase() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ No user logged in');
    return;
  }
  
  final userId = user.uid;
  final firestore = FirebaseFirestore.instance;
  
  // Check Expenses
  final expensesSnapshot = await firestore
      .collection('expenses')
      .where('userId', isEqualTo: userId)
      .get();
  
  print('📊 Expenses Count: ${expensesSnapshot.docs.length}');
  if (expensesSnapshot.docs.isEmpty) {
    print('✅ Expenses collection is empty (as expected for new user)');
  }
  
  // Check Wishlist
  final wishlistSnapshot = await firestore
      .collection('wishlists')
      .where('userId', isEqualTo: userId)
      .where('isActive', isEqualTo: true)
      .get();
  
  print('📋 Wishlist Count: ${wishlistSnapshot.docs.length}');
  if (wishlistSnapshot.docs.isEmpty) {
    print('✅ Wishlist collection is empty (as expected for new user)');
  }
  
  // Check User Summary
  final userDoc = await firestore.collection('users').doc(userId).get();
  if (userDoc.exists) {
    final data = userDoc.data()!;
    print('👤 User Summary:');
    print('   - Expense Count: ${data['expenseCount'] ?? 0}');
    print('   - Total Expenses: RM ${data['totalExpenses'] ?? 0.0}');
  } else {
    print('✅ User document does not exist yet (will be created on first expense)');
  }
}
```

---

## 📝 Code Locations Summary

### Expenses
- **Service File:** `lib/backend/services/expense_tracking_service.dart`
- **Model File:** `lib/backend/models/expense_tracking.dart`
- **Collection:** `expenses`
- **User Summary:** `users/{userId}` (fields: `expenseCount`, `totalExpenses`)

### Wishlist
- **Service File:** `lib/backend/services/wishlist_service.dart`
- **Model File:** `lib/backend/models/wishlist_item.dart`
- **Collection:** `wishlists`
- **Filter:** `isActive == true` for active items

---

## 🧪 Testing First-Time User Experience

1. **Create a new test user** (or use anonymous auth)
2. **Check database** - should be empty
3. **Add an expense** - verify it appears in `expenses` collection
4. **Add to wishlist** - verify it appears in `wishlists` collection
5. **Check user summary** - verify `expenseCount` and `totalExpenses` update

---

## 🗑️ Clearing Data for Testing

### Clear All Expenses for a User
```dart
final expenseService = ExpenseTrackingService();
await expenseService.clearAllExpenses(userId);
```

### Clear Wishlist (Soft Delete)
```dart
final wishlistService = WishlistService();
final wishlist = await wishlistService.getUserWishlist(userId);
for (var item in wishlist) {
  await wishlistService.removeFromWishlist(item.id);
}
```

---

## 📱 Quick Access in Firebase Console

**Direct Links (replace PROJECT_ID):**
- Expenses: `https://console.firebase.google.com/project/PROJECT_ID/firestore/data/~2Fexpenses`
- Wishlist: `https://console.firebase.google.com/project/PROJECT_ID/firestore/data/~2Fwishlists`
- Users: `https://console.firebase.google.com/project/PROJECT_ID/firestore/data/~2Fusers`

---

## ✅ Expected Behavior for First-Time Users

1. **No expenses** in `expenses` collection
2. **No wishlist items** in `wishlists` collection (or all `isActive == false`)
3. **User document** may not exist yet (created on first expense)
4. **No errors** when querying empty collections (returns empty list)

---

## 🔐 Security Rules (Important!)

Make sure your Firestore security rules allow users to only access their own data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Expenses - users can only read/write their own
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Wishlist - users can only read/write their own
    match /wishlists/{wishlistId} {
      allow read, write: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Users - users can only read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        userId == request.auth.uid;
    }
  }
}
```

---

## 📞 Need Help?

If you need to debug database issues:
1. Check Firebase Console for actual data
2. Use Flutter debug prints (already in service files)
3. Check Firestore security rules
4. Verify user authentication status

