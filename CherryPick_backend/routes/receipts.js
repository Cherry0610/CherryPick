// Receipts Routes
import express from 'express';
import { db, storage } from '../config/firebase.js';
import { verifyToken } from '../middleware/auth.js';
import multer from 'multer';
import { createWorker } from 'tesseract.js';

const router = express.Router();

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  },
});

// GET /api/receipts
router.get('/', verifyToken, async (req, res) => {
  try {
    const { userId } = req.user;
    const { status, startDate, endDate, limit = 50 } = req.query;

    let receiptsRef = db.collection('receipts')
      .where('userId', '==', userId)
      .orderBy('purchaseDate', 'desc')
      .limit(parseInt(limit));

    if (status) {
      receiptsRef = receiptsRef.where('status', '==', status);
    }

    if (startDate) {
      receiptsRef = receiptsRef.where('purchaseDate', '>=', new Date(startDate));
    }

    if (endDate) {
      receiptsRef = receiptsRef.where('purchaseDate', '<=', new Date(endDate));
    }

    const snapshot = await receiptsRef.get();
    const receipts = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      receipts.push({
        id: doc.id,
        ...data,
        purchaseDate: data.purchaseDate?.toDate?.()?.toISOString(),
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
      });
    });

    res.json({
      success: true,
      data: receipts,
      count: receipts.length,
    });
  } catch (error) {
    console.error('Error getting receipts:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get receipts',
      message: error.message,
    });
  }
});

// GET /api/receipts/:id
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.user;

    const doc = await db.collection('receipts').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Receipt not found',
      });
    }

    const data = doc.data();

    // Verify ownership
    if (data.userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'Access denied',
      });
    }

    res.json({
      success: true,
      data: {
        id: doc.id,
        ...data,
        purchaseDate: data.purchaseDate?.toDate?.()?.toISOString(),
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error getting receipt:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get receipt',
      message: error.message,
    });
  }
});

// POST /api/receipts/upload
router.post('/upload', verifyToken, upload.single('image'), async (req, res) => {
  try {
    const { userId } = req.user;
    const { storeId, storeName } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No image file provided',
      });
    }

    // Upload image to Firebase Storage
    const bucket = storage.bucket();
    const fileName = `receipts/${userId}/${Date.now()}_${req.file.originalname}`;
    const file = bucket.file(fileName);

    await file.save(req.file.buffer, {
      metadata: {
        contentType: req.file.mimetype,
      },
    });

    // Make file publicly accessible (or use signed URLs in production)
    await file.makePublic();
    const imageUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;

    // Create receipt document
    const now = new Date();
    const receiptData = {
      userId,
      storeId: storeId || '',
      storeName: storeName || 'Unknown Store',
      imageUrl,
      totalAmount: 0,
      currency: 'MYR',
      purchaseDate: now,
      items: [],
      status: 'pending',
      ocrText: null,
      createdAt: now,
      updatedAt: now,
    };

    const docRef = await db.collection('receipts').add(receiptData);

    // Process OCR in background (async)
    processReceiptOCR(docRef.id, req.file.buffer).catch((error) => {
      console.error('Error processing OCR:', error);
    });

    res.status(201).json({
      success: true,
      data: {
        id: docRef.id,
        ...receiptData,
        purchaseDate: receiptData.purchaseDate.toISOString(),
        createdAt: receiptData.createdAt.toISOString(),
        updatedAt: receiptData.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error uploading receipt:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to upload receipt',
      message: error.message,
    });
  }
});

// Helper function to process OCR
async function processReceiptOCR(receiptId, imageBuffer) {
  try {
    const worker = await createWorker('eng');
    const { data: { text } } = await worker.recognize(imageBuffer);
    await worker.terminate();

    // Update receipt with OCR text
    await db.collection('receipts').doc(receiptId).update({
      ocrText: text,
      status: 'processed',
      updatedAt: new Date(),
    });

    // TODO: Parse OCR text to extract items and prices
    // This would involve NLP/text parsing to identify products and prices
    console.log(`OCR completed for receipt ${receiptId}`);
  } catch (error) {
    console.error('OCR processing error:', error);
    await db.collection('receipts').doc(receiptId).update({
      status: 'failed',
      updatedAt: new Date(),
    });
  }
}

// PUT /api/receipts/:id
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.user;
    const updateData = req.body;

    const doc = await db.collection('receipts').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Receipt not found',
      });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'Access denied',
      });
    }

    // Convert date strings to Date objects if present
    if (updateData.purchaseDate) {
      updateData.purchaseDate = new Date(updateData.purchaseDate);
    }
    updateData.updatedAt = new Date();

    await db.collection('receipts').doc(id).update(updateData);

    const updatedDoc = await db.collection('receipts').doc(id).get();
    const data = updatedDoc.data();

    res.json({
      success: true,
      data: {
        id: updatedDoc.id,
        ...data,
        purchaseDate: data.purchaseDate?.toDate?.()?.toISOString(),
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error updating receipt:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update receipt',
      message: error.message,
    });
  }
});

// DELETE /api/receipts/:id
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.user;

    const doc = await db.collection('receipts').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Receipt not found',
      });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'Access denied',
      });
    }

    await db.collection('receipts').doc(id).delete();

    res.json({
      success: true,
      message: 'Receipt deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting receipt:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete receipt',
      message: error.message,
    });
  }
});

export default router;



