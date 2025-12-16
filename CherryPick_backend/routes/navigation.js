import express from 'express';
import { db } from '../config/firebase.js';
import { optionalAuth } from '../middleware/auth.js';

const router = express.Router();

// Haversine distance in km
function haversine(lat1, lon1, lat2, lon2) {
  const toRad = (deg) => (deg * Math.PI) / 180;
  const R = 6371; // km
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Simple ETA (minutes) assuming 40km/h average; replace with Google/Mapbox Directions API
function estimateEtaMinutes(distanceKm) {
  const avgSpeed = 40; // km/h
  return Math.max(3, Math.round((distanceKm / avgSpeed) * 60));
}

// GET /api/navigation/nearby?lat=..&lng=..&limit=10
// Returns nearest stores with rough distance/eta/toll (toll=0 placeholder).
router.get('/nearby', optionalAuth, async (req, res) => {
  try {
    const lat = parseFloat(req.query.lat);
    const lng = parseFloat(req.query.lng);
    const limit = Math.min(parseInt(req.query.limit) || 10, 25);

    if (Number.isNaN(lat) || Number.isNaN(lng)) {
      return res.status(400).json({
        success: false,
        error: 'lat and lng are required numbers',
      });
    }

    const storesSnap = await db.collection('stores')
      .where('isActive', '==', true)
      .get();

    const stores = [];
    storesSnap.forEach((doc) => {
      const data = doc.data();
      if (typeof data.lat === 'number' && typeof data.lng === 'number') {
        const distanceKm = haversine(lat, lng, data.lat, data.lng);
        stores.push({
          id: doc.id,
          name: data.name || 'Store',
          lat: data.lat,
          lng: data.lng,
          address: data.address || '',
          distanceKm: Number(distanceKm.toFixed(2)),
          etaMinutes: estimateEtaMinutes(distanceKm),
          tollRm: 0, // TODO: integrate toll pricing API; keep 0 for now
        });
      }
    });

    stores.sort((a, b) => a.distanceKm - b.distanceKm);

    res.json({
      success: true,
      data: stores.slice(0, limit),
      count: Math.min(stores.length, limit),
    });
  } catch (error) {
    console.error('Error getting nearby stores:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get nearby stores',
      message: error.message,
    });
  }
});

export default router;


