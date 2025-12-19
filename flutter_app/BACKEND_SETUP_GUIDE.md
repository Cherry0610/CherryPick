# 🚀 Backend Setup Guide for SmartPrice App

## 📋 Current Status

✅ **Already Set Up:**
- Firebase Authentication (working)
- Firebase Firestore (database)
- Firebase Storage (file uploads)

⚠️ **Needs Setup:**
- REST API backend (for advanced features)
- Product price data
- Store locations data

---

## 🎯 Option 1: Firebase-Only (Easiest for Beginners) ⭐ RECOMMENDED

**Best for:** Getting started quickly, no server management needed

### What You Get:
- ✅ User authentication (already working)
- ✅ User data storage (profiles, wishlists, expenses)
- ✅ File uploads (receipt images)
- ✅ Real-time updates
- ✅ Free tier: 50K reads/day, 20K writes/day

### Setup Steps:

1. **Enable Firestore Database:**
   ```bash
   # Already done! Your app is using Firestore
   ```

2. **Set up Firestore Security Rules:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select project: `cherrypick-67246`
   - Go to **Firestore Database** → **Rules**
   - Replace with:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users can only read/write their own data
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Products are public to read, only admins can write
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null && 
           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.admin == true;
       }
       
       // Prices are public to read
       match /prices/{priceId} {
         allow read: if true;
         allow write: if request.auth != null;
       }
       
       // Wishlists are private to each user
       match /wishlists/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Expenses are private to each user
       match /expenses/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

3. **Add Sample Data (Optional):**
   - Go to Firestore Database → **Data** tab
   - Click **Start collection**
   - Collection ID: `products`
   - Add a document with:
     ```json
     {
       "name": "Milk 1L",
       "barcode": "123456789",
       "category": "Dairy",
       "isActive": true,
       "createdAt": "2025-01-15T10:00:00Z"
     }
     ```

### ✅ You're Done!
Your app can now:
- Store user data
- Save wishlists
- Track expenses
- Upload receipts

---

## 🎯 Option 2: Node.js/Express Backend (For Learning)

**Best for:** Learning backend development, more control

### Prerequisites:
- Node.js installed ([Download here](https://nodejs.org/))
- Basic terminal knowledge

### Setup Steps:

1. **Create Backend Folder:**
   ```bash
   cd /Users/cherry/Development/CherryPick
   mkdir smartprice-backend
   cd smartprice-backend
   ```

2. **Initialize Node.js Project:**
   ```bash
   npm init -y
   ```

3. **Install Dependencies:**
   ```bash
   npm install express cors dotenv firebase-admin
   npm install --save-dev nodemon
   ```

4. **Create `server.js`:**
   ```javascript
   const express = require('express');
   const cors = require('cors');
   const admin = require('firebase-admin');
   require('dotenv').config();

   const app = express();
   app.use(cors());
   app.use(express.json());

   // Initialize Firebase Admin
   admin.initializeApp({
     credential: admin.credential.cert({
       projectId: 'cherrypick-67246',
       // You'll need to download service account key from Firebase Console
     }),
   });

   const db = admin.firestore();

   // Health check
   app.get('/api/health', (req, res) => {
     res.json({ status: 'ok', message: 'SmartPrice API is running!' });
   });

   // Search products
   app.get('/api/products/search', async (req, res) => {
     try {
       const query = req.query.q || '';
       const productsRef = db.collection('products');
       const snapshot = await productsRef
         .where('name', '>=', query)
         .where('name', '<=', query + '\uf8ff')
         .limit(20)
         .get();

       const products = [];
       snapshot.forEach((doc) => {
         products.push({ id: doc.id, ...doc.data() });
       });

       res.json({ success: true, data: products });
     } catch (error) {
       res.status(500).json({ success: false, error: error.message });
     }
   });

   // Get product prices
   app.get('/api/prices/product/:productId', async (req, res) => {
     try {
       const { productId } = req.params;
       const pricesRef = db.collection('prices');
       const snapshot = await pricesRef
         .where('productId', '==', productId)
         .orderBy('createdAt', 'desc')
         .limit(10)
         .get();

       const prices = [];
       snapshot.forEach((doc) => {
         prices.push({ id: doc.id, ...doc.data() });
       });

       res.json({ success: true, data: prices });
     } catch (error) {
       res.status(500).json({ success: false, error: error.message });
     }
   });

   // Get user wishlist (requires authentication)
   app.get('/api/wishlist', async (req, res) => {
     try {
       const token = req.headers.authorization?.split('Bearer ')[1];
       if (!token) {
         return res.status(401).json({ success: false, error: 'Unauthorized' });
       }

       const decodedToken = await admin.auth().verifyIdToken(token);
       const userId = decodedToken.uid;

       const wishlistRef = db.collection('wishlists').doc(userId);
       const doc = await wishlistRef.get();

       if (doc.exists) {
         res.json({ success: true, data: doc.data().items || [] });
       } else {
         res.json({ success: true, data: [] });
       }
     } catch (error) {
       res.status(500).json({ success: false, error: error.message });
     }
   });

   // Add to wishlist
   app.post('/api/wishlist', async (req, res) => {
     try {
       const token = req.headers.authorization?.split('Bearer ')[1];
       if (!token) {
         return res.status(401).json({ success: false, error: 'Unauthorized' });
       }

       const decodedToken = await admin.auth().verifyIdToken(token);
       const userId = decodedToken.uid;

       const wishlistRef = db.collection('wishlists').doc(userId);
       await wishlistRef.set({
         items: req.body.items || [],
         updatedAt: admin.firestore.FieldValue.serverTimestamp(),
       });

       res.json({ success: true, message: 'Wishlist updated' });
     } catch (error) {
       res.status(500).json({ success: false, error: error.message });
     }
   });

   const PORT = process.env.PORT || 3000;
   app.listen(PORT, () => {
     console.log(`🚀 Server running on http://localhost:${PORT}`);
   });
   ```

5. **Create `.env` file:**
   ```env
   PORT=3000
   ```

6. **Update `package.json` scripts:**
   ```json
   {
     "scripts": {
       "start": "node server.js",
       "dev": "nodemon server.js"
     }
   }
   ```

7. **Get Firebase Service Account Key:**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key"
   - Save as `serviceAccountKey.json` in backend folder
   - Update `server.js` to use the file path

8. **Start the Server:**
   ```bash
   npm run dev
   ```

### ✅ Your Backend is Running!
- API available at: `http://localhost:3000/api`
- Test it: Open `http://localhost:3000/api/health` in browser

---

## 🎯 Option 3: Supabase (Alternative to Firebase)

**Best for:** PostgreSQL database, easier than Firebase for complex queries

### Quick Setup:
1. Go to [supabase.com](https://supabase.com)
2. Create free account
3. Create new project
4. Get API keys
5. Use Supabase Flutter package

---

## 📊 What Your App Needs

### Data Collections:

1. **Products** (`products`)
   - name, barcode, category, imageUrl

2. **Prices** (`prices`)
   - productId, storeId, price, date

3. **Stores** (`stores`)
   - name, address, latitude, longitude

4. **Wishlists** (`wishlists/{userId}`)
   - items array with productId, targetPrice

5. **Expenses** (`expenses/{userId}`)
   - amount, category, date, storeId

---

## 🚀 Next Steps

### For Beginners (Recommended):
1. ✅ Use **Option 1 (Firebase-Only)**
2. ✅ Set up Firestore security rules
3. ✅ Add sample products manually
4. ✅ Test your app!

### For Learning:
1. ✅ Use **Option 2 (Node.js/Express)**
2. ✅ Follow the setup steps
3. ✅ Learn how APIs work
4. ✅ Add more endpoints as needed

---

## 🆘 Need Help?

### Common Issues:

1. **"Cannot connect to backend"**
   - Make sure server is running: `npm run dev`
   - Check if port 3000 is available

2. **"Firebase permission denied"**
   - Check Firestore security rules
   - Make sure user is authenticated

3. **"CORS error"**
   - Add `cors` middleware in Express
   - Allow your Flutter app's origin

---

## 📚 Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [Node.js Tutorial](https://nodejs.org/en/docs/guides/getting-started-guide/)

---

## ✅ Quick Start Checklist

- [ ] Choose Option 1 (Firebase) or Option 2 (Node.js)
- [ ] Set up Firestore security rules
- [ ] Add sample data
- [ ] Test API endpoints
- [ ] Update app to use backend
- [ ] Deploy backend (when ready)

Good luck! 🎉

