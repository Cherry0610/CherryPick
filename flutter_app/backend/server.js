/**
 * SmartPrice Backend API
 * Simple Express server for SmartPrice app
 * 
 * To start: npm run dev
 * API will be available at: http://localhost:3000/api
 */

const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors()); // Allow requests from Flutter app
app.use(express.json()); // Parse JSON bodies

// Initialize Firebase Admin SDK
// NOTE: You need to download service account key from Firebase Console
// Go to: Firebase Console → Project Settings → Service Accounts → Generate new private key
// Save it as 'serviceAccountKey.json' in this folder

let db;
try {
  // Option 1: Use service account key file (recommended for production)
  // Uncomment and update path when you have the key file:
  // const serviceAccount = require('./serviceAccountKey.json');
  // admin.initializeApp({
  //   credential: admin.credential.cert(serviceAccount),
  // });

  // Option 2: Use environment variables (for now, we'll use default credentials)
  // This works if you're running on Firebase Cloud Functions or have GOOGLE_APPLICATION_CREDENTIALS set
  admin.initializeApp({
    projectId: 'cherrypick-67246',
  });

  db = admin.firestore();
  console.log('✅ Firebase Admin initialized');
} catch (error) {
  console.error('❌ Firebase Admin initialization error:', error);
  console.log('⚠️  Some features may not work without proper Firebase setup');
}

// ==================== ROUTES ====================

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'SmartPrice API is running! 🚀',
    timestamp: new Date().toISOString(),
  });
});

// Search products
app.get('/api/products/search', async (req, res) => {
  try {
    const query = req.query.q || '';
    
    if (!db) {
      return res.status(503).json({
        success: false,
        error: 'Database not initialized',
        data: [], // Return empty array so app doesn't crash
      });
    }

    const productsRef = db.collection('products');
    const snapshot = await productsRef
      .where('isActive', '==', true)
      .where('name', '>=', query)
      .where('name', '<=', query + '\uf8ff')
      .limit(20)
      .get();

    const products = [];
    snapshot.forEach((doc) => {
      products.push({
        id: doc.id,
        ...doc.data(),
      });
    });

    res.json({ success: true, data: products });
  } catch (error) {
    console.error('Error searching products:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      data: [], // Return empty array so app doesn't crash
    });
  }
});

// Get single product
app.get('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    if (!db) {
      return res.status(503).json({
        success: false,
        error: 'Database not initialized',
        data: null,
      });
    }

    const doc = await db.collection('products').doc(id).get();
    
    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Product not found',
        data: null,
      });
    }

    res.json({
      success: true,
      data: { id: doc.id, ...doc.data() },
    });
  } catch (error) {
    console.error('Error getting product:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      data: null,
    });
  }
});

// Get product prices
app.get('/api/prices/product/:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    
    if (!db) {
      return res.status(503).json({
        success: false,
        error: 'Database not initialized',
        data: [],
      });
    }

    const pricesRef = db.collection('prices');
    const snapshot = await pricesRef
      .where('productId', '==', productId)
      .where('isActive', '==', true)
      .orderBy('createdAt', 'desc')
      .limit(10)
      .get();

    const prices = [];
    snapshot.forEach((doc) => {
      const data = doc.data();
      prices.push({
        id: doc.id,
        ...data,
        // Convert Firestore Timestamp to ISO string
        createdAt: data.createdAt?.toDate?.()?.toISOString() || data.createdAt,
      });
    });

    res.json({ success: true, data: prices });
  } catch (error) {
    console.error('Error getting prices:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      data: [],
    });
  }
});

// Get price comparison
app.get('/api/prices/compare/:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    
    if (!db) {
      return res.status(503).json({
        success: false,
        error: 'Database not initialized',
        data: null,
      });
    }

    // Get all prices for this product
    const pricesRef = db.collection('prices');
    const snapshot = await pricesRef
      .where('productId', '==', productId)
      .where('isActive', '==', true)
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

    const prices = [];
    const storesMap = new Map();

    snapshot.forEach((doc) => {
      const priceData = doc.data();
      prices.push({
        id: doc.id,
        ...priceData,
        createdAt: priceData.createdAt?.toDate?.()?.toISOString() || priceData.createdAt,
      });
      
      if (priceData.storeId && !storesMap.has(priceData.storeId)) {
        storesMap.set(priceData.storeId, null);
      }
    });

    // Get store details
    for (const storeId of storesMap.keys()) {
      try {
        const storeDoc = await db.collection('stores').doc(storeId).get();
        if (storeDoc.exists) {
          storesMap.set(storeId, {
            id: storeDoc.id,
            ...storeDoc.data(),
          });
        }
      } catch (err) {
        console.error(`Error fetching store ${storeId}:`, err);
      }
    }

    // Group prices by store and get latest price
    const storePrices = [];
    const pricesByStore = {};

    prices.forEach((price) => {
      if (!pricesByStore[price.storeId]) {
        pricesByStore[price.storeId] = [];
      }
      pricesByStore[price.storeId].push(price);
    });

    Object.keys(pricesByStore).forEach((storeId) => {
      const storePricesList = pricesByStore[storeId];
      const latestPrice = storePricesList[0]; // Most recent
      const store = storesMap.get(storeId);

      if (store) {
        storePrices.push({
          store,
          price: latestPrice,
          isAvailable: true,
        });
      }
    });

    // Sort by price
    storePrices.sort((a, b) => a.price.price - b.price.price);

    res.json({
      success: true,
      data: {
        productId,
        prices: storePrices,
        lowestPrice: storePrices.length > 0 ? storePrices[0].price : null,
        highestPrice: storePrices.length > 0 ? storePrices[storePrices.length - 1].price : null,
        averagePrice: storePrices.length > 0
          ? storePrices.reduce((sum, sp) => sum + sp.price.price, 0) / storePrices.length
          : 0,
      },
    });
  } catch (error) {
    console.error('Error getting price comparison:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      data: null,
    });
  }
});

// Get nearby stores
app.get('/api/navigation/nearby', async (req, res) => {
  try {
    const lat = parseFloat(req.query.lat) || 0;
    const lng = parseFloat(req.query.lng) || 0;
    const limit = parseInt(req.query.limit) || 10;
    
    if (!db) {
      return res.status(503).json({
        success: false,
        error: 'Database not initialized',
        data: [],
      });
    }

    // Get all active stores
    const storesRef = db.collection('stores');
    const snapshot = await storesRef
      .where('isActive', '==', true)
      .limit(100) // Get more than needed, then filter by distance
      .get();

    const stores = [];
    snapshot.forEach((doc) => {
      const storeData = doc.data();
      stores.push({
        id: doc.id,
        ...storeData,
      });
    });

    // Calculate distance and sort
    const storesWithDistance = stores.map((store) => {
      const distance = calculateDistance(
        lat,
        lng,
        store.latitude || 0,
        store.longitude || 0,
      );
      return { ...store, distance };
    });

    // Sort by distance and limit
    storesWithDistance.sort((a, b) => a.distance - b.distance);
    const nearbyStores = storesWithDistance.slice(0, limit);

    res.json({ success: true, data: nearbyStores });
  } catch (error) {
    console.error('Error getting nearby stores:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      data: [],
    });
  }
});

// Get user wishlist (requires authentication)
app.get('/api/wishlist', async (req, res) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized - No token provided',
        data: [],
      });
    }

    if (!admin.apps.length) {
      return res.status(503).json({
        success: false,
        error: 'Firebase Admin not initialized',
        data: [],
      });
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    const userId = decodedToken.uid;

    if (!db) {
      return res.status(503).json({
        success: false,
        error: 'Database not initialized',
        data: [],
      });
    }

    const wishlistRef = db.collection('wishlists').doc(userId);
    const doc = await wishlistRef.get();

    if (doc.exists) {
      res.json({
        success: true,
        data: doc.data().items || [],
      });
    } else {
      res.json({
        success: true,
        data: [],
      });
    }
  } catch (error) {
    console.error('Error getting wishlist:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      data: [],
    });
  }
});

// Add/Update wishlist (requires authentication)
app.post('/api/wishlist', async (req, res) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized - No token provided',
      });
    }

    if (!admin.apps.length) {
      return res.status(503).json({
        success: false,
        error: 'Firebase Admin not initialized',
      });
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    const userId = decodedToken.uid;

    if (!db) {
      return res.status(503).json({
        success: false,
        error: 'Database not initialized',
      });
    }

    const wishlistRef = db.collection('wishlists').doc(userId);
    await wishlistRef.set({
      items: req.body.items || [],
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    res.json({
      success: true,
      message: 'Wishlist updated successfully',
    });
  } catch (error) {
    console.error('Error updating wishlist:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Get user expenses (requires authentication)
app.get('/api/expenses', async (req, res) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized - No token provided',
        data: [],
      });
    }

    if (!admin.apps.length) {
      return res.status(503).json({
        success: false,
        error: 'Firebase Admin not initialized',
        data: [],
      });
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    const userId = decodedToken.uid;
    const month = req.query.month;

    if (!db) {
      return res.status(503).json({
        success: false,
        error: 'Database not initialized',
        data: [],
      });
    }

    let query = db.collection('expenses')
      .where('userId', '==', userId)
      .orderBy('date', 'desc')
      .limit(100);

    if (month) {
      // Filter by month if provided
      const [year, monthNum] = month.split('-');
      const startDate = new Date(year, parseInt(monthNum) - 1, 1);
      const endDate = new Date(year, parseInt(monthNum), 0);
      
      query = query
        .where('date', '>=', admin.firestore.Timestamp.fromDate(startDate))
        .where('date', '<=', admin.firestore.Timestamp.fromDate(endDate));
    }

    const snapshot = await query.get();
    const expenses = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      expenses.push({
        id: doc.id,
        ...data,
        date: data.date?.toDate?.()?.toISOString() || data.date,
      });
    });

    res.json({ success: true, data: expenses });
  } catch (error) {
    console.error('Error getting expenses:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      data: [],
    });
  }
});

// ==================== HELPER FUNCTIONS ====================

// Calculate distance between two coordinates (Haversine formula)
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in kilometers
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRad(degrees) {
  return degrees * (Math.PI / 180);
}

// ==================== START SERVER ====================

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log('');
  console.log('🚀 SmartPrice Backend API Server');
  console.log('================================');
  console.log(`📍 Server running on: http://localhost:${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
  console.log('');
  console.log('📚 Available endpoints:');
  console.log('   GET  /api/health');
  console.log('   GET  /api/products/search?q=query');
  console.log('   GET  /api/products/:id');
  console.log('   GET  /api/prices/product/:productId');
  console.log('   GET  /api/prices/compare/:productId');
  console.log('   GET  /api/navigation/nearby?lat=0&lng=0&limit=10');
  console.log('   GET  /api/wishlist (requires auth)');
  console.log('   POST /api/wishlist (requires auth)');
  console.log('   GET  /api/expenses (requires auth)');
  console.log('');
  console.log('💡 Tip: Make sure Firebase Admin is properly configured');
  console.log('');
});

