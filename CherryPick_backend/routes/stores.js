// Stores Routes
import express from 'express';
import { db } from '../config/firebase.js';
import { optionalAuth } from '../middleware/auth.js';

const router = express.Router();

// GET /api/stores
router.get('/', optionalAuth, async (req, res) => {
  try {
    const { city, state, type, lat, lng, radius } = req.query;

    let storesRef = db.collection('stores')
      .where('isActive', '==', true)
      .orderBy('name');

    if (city) {
      storesRef = storesRef.where('city', '==', city);
    }
    if (state) {
      storesRef = storesRef.where('state', '==', state);
    }
    if (type) {
      storesRef = storesRef.where('type', '==', type);
    }

    const snapshot = await storesRef.get();
    let stores = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      stores.push({
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
      });
    });

    // Filter by location if lat/lng provided
    if (lat && lng && radius) {
      const userLat = parseFloat(lat);
      const userLng = parseFloat(lng);
      const radiusKm = parseFloat(radius) || 10;

      stores = stores.filter((store) => {
        const distance = calculateDistance(
          userLat,
          userLng,
          store.latitude,
          store.longitude
        );
        return distance <= radiusKm;
      });

      // Sort by distance
      stores.sort((a, b) => {
        const distA = calculateDistance(userLat, userLng, a.latitude, a.longitude);
        const distB = calculateDistance(userLat, userLng, b.latitude, b.longitude);
        return distA - distB;
      });
    }

    res.json({
      success: true,
      data: stores,
      count: stores.length,
    });
  } catch (error) {
    console.error('Error getting stores:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get stores',
      message: error.message,
    });
  }
});

// GET /api/stores/:id
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const doc = await db.collection('stores').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Store not found',
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
    console.error('Error getting store:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get store',
      message: error.message,
    });
  }
});

// Helper function to calculate distance between two points (Haversine formula)
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

export default router;



