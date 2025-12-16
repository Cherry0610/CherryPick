// Wishlist Routes
import express from 'express';
import { db } from '../config/firebase.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

// GET /api/wishlist
router.get('/', verifyToken, async (req, res) => {
  try {
    const { userId } = req.user;

    const snapshot = await db.collection('wishlists')
      .where('userId', '==', userId)
      .where('isActive', '==', true)
      .orderBy('createdAt', 'desc')
      .get();

    const wishlistItems = [];
    snapshot.forEach((doc) => {
      const data = doc.data();
      wishlistItems.push({
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
        lastNotifiedAt: data.lastNotifiedAt?.toDate?.()?.toISOString(),
      });
    });

    res.json({
      success: true,
      data: wishlistItems,
      count: wishlistItems.length,
    });
  } catch (error) {
    console.error('Error getting wishlist:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get wishlist',
      message: error.message,
    });
  }
});

// GET /api/wishlist/stats
router.get('/stats', verifyToken, async (req, res) => {
  try {
    const { userId } = req.user;
    const now = new Date();

    const snapshot = await db.collection('wishlists')
      .where('userId', '==', userId)
      .where('isActive', '==', true)
      .get();

    const wishlistItems = [];
    snapshot.forEach((doc) => {
      wishlistItems.push({ id: doc.id, ...doc.data() });
    });

    if (wishlistItems.length === 0) {
      return res.json({
        success: true,
        data: {
          totalItems: 0,
          targetReached: 0,
          averageTargetPrice: 0,
          totalPotentialSavings: 0,
        },
      });
    }

    let targetReached = 0;
    let totalPotentialSavings = 0;
    let totalTargetPrice = 0;

    for (const item of wishlistItems) {
      totalTargetPrice += item.targetPrice;

      // Get current lowest price
      const pricesSnapshot = await db.collection('prices')
        .where('productId', '==', item.productId)
        .where('isActive', '==', true)
        .where('validFrom', '<=', now)
        .orderBy('validFrom', 'desc')
        .limit(1)
        .get();

      if (!pricesSnapshot.empty) {
        const currentPrice = pricesSnapshot.docs[0].data().price;

        if (currentPrice <= item.targetPrice) {
          targetReached++;
        }

        if (currentPrice < item.targetPrice) {
          totalPotentialSavings += (item.targetPrice - currentPrice);
        }
      }
    }

    res.json({
      success: true,
      data: {
        totalItems: wishlistItems.length,
        targetReached,
        averageTargetPrice: totalTargetPrice / wishlistItems.length,
        totalPotentialSavings,
      },
    });
  } catch (error) {
    console.error('Error getting wishlist stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get wishlist stats',
      message: error.message,
    });
  }
});

// GET /api/wishlist/:id
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.user;
    const now = new Date();

    const doc = await db.collection('wishlists').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Wishlist item not found',
      });
    }

    const data = doc.data();

    if (data.userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'Access denied',
      });
    }

    // Get current prices
    const pricesSnapshot = await db.collection('prices')
      .where('productId', '==', data.productId)
      .where('isActive', '==', true)
      .where('validFrom', '<=', now)
      .orderBy('validFrom', 'desc')
      .limit(10)
      .get();

    const prices = [];
    pricesSnapshot.forEach((priceDoc) => {
      const priceData = priceDoc.data();
      prices.push({
        id: priceDoc.id,
        ...priceData,
        validFrom: priceData.validFrom?.toDate?.()?.toISOString(),
        validUntil: priceData.validUntil?.toDate?.()?.toISOString(),
      });
    });

    // Get product details
    const productDoc = await db.collection('products').doc(data.productId).get();
    const product = productDoc.exists
      ? { id: productDoc.id, ...productDoc.data() }
      : null;

    const lowestPrice = prices.length > 0 ? prices[0] : null;
    const isTargetReached = lowestPrice && lowestPrice.price <= data.targetPrice;

    res.json({
      success: true,
      data: {
        wishlistItem: {
          id: doc.id,
          ...data,
          createdAt: data.createdAt?.toDate?.()?.toISOString(),
          updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
          lastNotifiedAt: data.lastNotifiedAt?.toDate?.()?.toISOString(),
        },
        product,
        currentPrices: prices,
        lowestPrice,
        isTargetReached,
      },
    });
  } catch (error) {
    console.error('Error getting wishlist item:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get wishlist item',
      message: error.message,
    });
  }
});

// POST /api/wishlist
router.post('/', verifyToken, async (req, res) => {
  try {
    const { userId } = req.user;
    const {
      productId,
      productName,
      productImageUrl,
      targetPrice,
      currency = 'MYR',
      preferredStores = [],
      notes,
    } = req.body;

    if (!productId || !productName || targetPrice === undefined) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: productId, productName, targetPrice',
      });
    }

    const now = new Date();
    const wishlistData = {
      userId,
      productId,
      productName,
      productImageUrl: productImageUrl || null,
      targetPrice: parseFloat(targetPrice),
      currency,
      isActive: true,
      preferredStores: Array.isArray(preferredStores) ? preferredStores : [],
      notes: notes || null,
      createdAt: now,
      updatedAt: now,
      lastNotifiedAt: null,
    };

    const docRef = await db.collection('wishlists').add(wishlistData);

    res.status(201).json({
      success: true,
      data: {
        id: docRef.id,
        ...wishlistData,
        createdAt: wishlistData.createdAt.toISOString(),
        updatedAt: wishlistData.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error adding to wishlist:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add to wishlist',
      message: error.message,
    });
  }
});

// PUT /api/wishlist/:id
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.user;
    const updateData = req.body;

    const doc = await db.collection('wishlists').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Wishlist item not found',
      });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'Access denied',
      });
    }

    updateData.updatedAt = new Date();

    await db.collection('wishlists').doc(id).update(updateData);

    const updatedDoc = await db.collection('wishlists').doc(id).get();
    const data = updatedDoc.data();

    res.json({
      success: true,
      data: {
        id: updatedDoc.id,
        ...data,
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
        lastNotifiedAt: data.lastNotifiedAt?.toDate?.()?.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error updating wishlist item:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update wishlist item',
      message: error.message,
    });
  }
});

// DELETE /api/wishlist/:id
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.user;

    const doc = await db.collection('wishlists').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Wishlist item not found',
      });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'Access denied',
      });
    }

    // Soft delete
    await db.collection('wishlists').doc(id).update({
      isActive: false,
      updatedAt: new Date(),
    });

    res.json({
      success: true,
      message: 'Wishlist item removed successfully',
    });
  } catch (error) {
    console.error('Error removing wishlist item:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to remove wishlist item',
      message: error.message,
    });
  }
});

export default router;



