// Prices Routes
import express from 'express';
import { db } from '../config/firebase.js';
import { optionalAuth } from '../middleware/auth.js';

const router = express.Router();

// GET /api/prices/product/:productId
router.get('/product/:productId', optionalAuth, async (req, res) => {
  try {
    const { productId } = req.params;
    const now = new Date();

    const snapshot = await db.collection('prices')
      .where('productId', '==', productId)
      .where('isActive', '==', true)
      .where('validFrom', '<=', now)
      .orderBy('validFrom', 'desc')
      .limit(50)
      .get();

    const prices = [];
    snapshot.forEach((doc) => {
      const data = doc.data();
      prices.push({
        id: doc.id,
        ...data,
        validFrom: data.validFrom?.toDate?.()?.toISOString(),
        validUntil: data.validUntil?.toDate?.()?.toISOString(),
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
      });
    });

    res.json({
      success: true,
      data: prices,
      count: prices.length,
    });
  } catch (error) {
    console.error('Error getting prices:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get prices',
      message: error.message,
    });
  }
});

// GET /api/prices/compare/:productId
router.get('/compare/:productId', optionalAuth, async (req, res) => {
  try {
    const { productId } = req.params;
    const now = new Date();

    // Get product
    const productDoc = await db.collection('products').doc(productId).get();
    if (!productDoc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Product not found',
      });
    }

    // Get all prices for this product
    const pricesSnapshot = await db.collection('prices')
      .where('productId', '==', productId)
      .where('isActive', '==', true)
      .where('validFrom', '<=', now)
      .orderBy('validFrom', 'desc')
      .get();

    // Group prices by store and get the most recent price per store
    const pricesByStore = {};
    pricesSnapshot.forEach((doc) => {
      const data = doc.data();
      const storeId = data.storeId;

      if (!pricesByStore[storeId] || 
          data.validFrom.toDate() > pricesByStore[storeId].validFrom.toDate()) {
        pricesByStore[storeId] = {
          id: doc.id,
          ...data,
          validFrom: data.validFrom?.toDate?.()?.toISOString(),
          validUntil: data.validUntil?.toDate?.()?.toISOString(),
        };
      }
    });

    // Get store details for each price
    const storePrices = [];
    for (const [storeId, price] of Object.entries(pricesByStore)) {
      try {
        const storeDoc = await db.collection('stores').doc(storeId).get();
        if (storeDoc.exists) {
          const storeData = storeDoc.data();
          storePrices.push({
            store: {
              id: storeDoc.id,
              ...storeData,
              createdAt: storeData.createdAt?.toDate?.()?.toISOString(),
              updatedAt: storeData.updatedAt?.toDate?.()?.toISOString(),
            },
            price: price,
            isAvailable: true,
          });
        }
      } catch (error) {
        console.error(`Error getting store ${storeId}:`, error);
      }
    }

    // Sort by price
    storePrices.sort((a, b) => a.price.price - b.price.price);

    // Calculate statistics
    const prices = storePrices.map(sp => sp.price.price);
    const lowestPrice = storePrices.length > 0 ? storePrices[0].price : null;
    const highestPrice = storePrices.length > 0 ? storePrices[storePrices.length - 1].price : null;
    const averagePrice = prices.length > 0
      ? prices.reduce((a, b) => a + b, 0) / prices.length
      : 0;

    res.json({
      success: true,
      data: {
        product: {
          id: productDoc.id,
          ...productDoc.data(),
          createdAt: productDoc.data().createdAt?.toDate?.()?.toISOString(),
          updatedAt: productDoc.data().updatedAt?.toDate?.()?.toISOString(),
        },
        prices: storePrices,
        lowestPrice,
        highestPrice,
        averagePrice,
        priceRange: highestPrice && lowestPrice 
          ? highestPrice.price - lowestPrice.price 
          : 0,
      },
    });
  } catch (error) {
    console.error('Error comparing prices:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to compare prices',
      message: error.message,
    });
  }
});

// POST /api/prices
router.post('/', optionalAuth, async (req, res) => {
  try {
    const {
      productId,
      storeId,
      price,
      currency = 'RM',
      isOnSale = false,
      originalPrice,
      saleDescription,
      validFrom,
      validUntil,
      source = 'manual',
    } = req.body;

    if (!productId || !storeId || price === undefined) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: productId, storeId, price',
      });
    }

    const now = new Date();
    const priceData = {
      productId,
      storeId,
      price: parseFloat(price),
      currency,
      isOnSale,
      originalPrice: originalPrice ? parseFloat(originalPrice) : null,
      saleDescription: saleDescription || null,
      validFrom: validFrom ? new Date(validFrom) : now,
      validUntil: validUntil ? new Date(validUntil) : null,
      source,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    };

    const docRef = await db.collection('prices').add(priceData);

    res.status(201).json({
      success: true,
      data: {
        id: docRef.id,
        ...priceData,
        validFrom: priceData.validFrom.toISOString(),
        validUntil: priceData.validUntil?.toISOString(),
        createdAt: priceData.createdAt.toISOString(),
        updatedAt: priceData.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error adding price:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add price',
      message: error.message,
    });
  }
});

export default router;



