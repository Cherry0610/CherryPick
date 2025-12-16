// Products Routes
import express from 'express';
import { db } from '../config/firebase.js';
import { optionalAuth } from '../middleware/auth.js';

const router = express.Router();

// GET /api/products/search?q=query&limit=20
router.get('/search', optionalAuth, async (req, res) => {
  try {
    const query = req.query.q || '';
    const limit = parseInt(req.query.limit) || 20;
    const category = req.query.category;

    if (!query) {
      return res.json({
        success: true,
        data: [],
        count: 0,
      });
    }

    let productsRef = db.collection('products')
      .where('isActive', '==', true)
      .limit(limit);

    // If category is provided, filter by category
    if (category) {
      productsRef = productsRef.where('category', '==', category);
    }

    const snapshot = await productsRef.get();
    const products = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      const name = (data.name || '').toLowerCase();
      const brand = (data.brand || '').toLowerCase();
      const searchQuery = query.toLowerCase();

      // Simple text search
      if (name.includes(searchQuery) || brand.includes(searchQuery)) {
        products.push({
          id: doc.id,
          ...data,
          createdAt: data.createdAt?.toDate?.()?.toISOString(),
          updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
        });
      }
    });

    // Sort by relevance (exact match first, then by name)
    products.sort((a, b) => {
      const aName = a.name.toLowerCase();
      const bName = b.name.toLowerCase();
      const queryLower = query.toLowerCase();

      if (aName.startsWith(queryLower) && !bName.startsWith(queryLower)) return -1;
      if (!aName.startsWith(queryLower) && bName.startsWith(queryLower)) return 1;
      return aName.localeCompare(bName);
    });

    res.json({
      success: true,
      data: products,
      count: products.length,
      query,
    });
  } catch (error) {
    console.error('Error searching products:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to search products',
      message: error.message,
    });
  }
});

// GET /api/products/:id
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const doc = await db.collection('products').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Product not found',
      });
    }

    const data = doc.data();
    res.json({
      success: true,
      data: {
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error getting product:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get product',
      message: error.message,
    });
  }
});

// GET /api/products?category=food&limit=50
router.get('/', optionalAuth, async (req, res) => {
  try {
    const category = req.query.category;
    const limit = parseInt(req.query.limit) || 50;
    const offset = parseInt(req.query.offset) || 0;

    let productsRef = db.collection('products')
      .where('isActive', '==', true)
      .orderBy('name')
      .limit(limit)
      .offset(offset);

    if (category) {
      productsRef = productsRef.where('category', '==', category);
    }

    const snapshot = await productsRef.get();
    const products = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      products.push({
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
      });
    });

    res.json({
      success: true,
      data: products,
      count: products.length,
    });
  } catch (error) {
    console.error('Error getting products:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get products',
      message: error.message,
    });
  }
});

export default router;



