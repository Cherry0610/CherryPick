// Expenses Routes
import express from 'express';
import { db } from '../config/firebase.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

// GET /api/expenses
router.get('/', verifyToken, async (req, res) => {
  try {
    const { userId } = req.user;
    const {
      startDate,
      endDate,
      category,
      limit = 100,
      offset = 0,
    } = req.query;

    let expensesRef = db.collection('expenses')
      .where('userId', '==', userId)
      .orderBy('date', 'desc')
      .limit(parseInt(limit))
      .offset(parseInt(offset));

    if (startDate) {
      expensesRef = expensesRef.where('date', '>=', new Date(startDate));
    }

    if (endDate) {
      expensesRef = expensesRef.where('date', '<=', new Date(endDate));
    }

    if (category) {
      expensesRef = expensesRef.where('category', '==', category);
    }

    const snapshot = await expensesRef.get();
    const expenses = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      expenses.push({
        id: doc.id,
        ...data,
        date: data.date?.toDate?.()?.toISOString(),
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
      });
    });

    res.json({
      success: true,
      data: expenses,
      count: expenses.length,
    });
  } catch (error) {
    console.error('Error getting expenses:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get expenses',
      message: error.message,
    });
  }
});

// GET /api/expenses/summary
router.get('/summary', verifyToken, async (req, res) => {
  try {
    const { userId } = req.user;
    const { month } = req.query; // Format: YYYY-MM

    let startOfMonth, endOfMonth;
    if (month) {
      const [year, monthNum] = month.split('-').map(Number);
      startOfMonth = new Date(year, monthNum - 1, 1);
      endOfMonth = new Date(year, monthNum, 0, 23, 59, 59);
    } else {
      const now = new Date();
      startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
    }

    // Get current month expenses
    const snapshot = await db.collection('expenses')
      .where('userId', '==', userId)
      .where('date', '>=', startOfMonth)
      .where('date', '<=', endOfMonth)
      .get();

    const expenses = [];
    snapshot.forEach((doc) => {
      expenses.push(doc.data());
    });

    // Calculate totals
    const totalAmount = expenses.reduce((sum, exp) => sum + exp.amount, 0);
    const transactionCount = expenses.length;
    const averageTransaction = transactionCount > 0 ? totalAmount / transactionCount : 0;

    // Category breakdown
    const categoryBreakdown = {};
    expenses.forEach((exp) => {
      categoryBreakdown[exp.category] = (categoryBreakdown[exp.category] || 0) + exp.amount;
    });

    // Get previous month
    const prevMonth = new Date(startOfMonth);
    prevMonth.setMonth(prevMonth.getMonth() - 1);
    const prevStartOfMonth = new Date(prevMonth.getFullYear(), prevMonth.getMonth(), 1);
    const prevEndOfMonth = new Date(prevMonth.getFullYear(), prevMonth.getMonth() + 1, 0, 23, 59, 59);

    const prevSnapshot = await db.collection('expenses')
      .where('userId', '==', userId)
      .where('date', '>=', prevStartOfMonth)
      .where('date', '<=', prevEndOfMonth)
      .get();

    const prevExpenses = [];
    prevSnapshot.forEach((doc) => {
      prevExpenses.push(doc.data());
    });

    const previousMonthAmount = prevExpenses.reduce((sum, exp) => sum + exp.amount, 0);
    const percentageChange = previousMonthAmount > 0
      ? ((totalAmount - previousMonthAmount) / previousMonthAmount) * 100
      : 0;

    res.json({
      success: true,
      data: {
        month: `${startOfMonth.getFullYear()}-${String(startOfMonth.getMonth() + 1).padStart(2, '0')}`,
        totalAmount,
        currency: 'RM',
        categoryBreakdown,
        transactionCount,
        averageTransaction,
        previousMonthAmount,
        percentageChange,
      },
    });
  } catch (error) {
    console.error('Error getting expense summary:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get expense summary',
      message: error.message,
    });
  }
});

// GET /api/expenses/trends
router.get('/trends', verifyToken, async (req, res) => {
  try {
    const { userId } = req.user;
    const { months = 6 } = req.query;

    const trends = [];
    const now = new Date();

    for (let i = parseInt(months) - 1; i >= 0; i--) {
      const month = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const startOfMonth = new Date(month.getFullYear(), month.getMonth(), 1);
      const endOfMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0, 23, 59, 59);

      const snapshot = await db.collection('expenses')
        .where('userId', '==', userId)
        .where('date', '>=', startOfMonth)
        .where('date', '<=', endOfMonth)
        .get();

      let totalAmount = 0;
      let transactionCount = 0;

      snapshot.forEach((doc) => {
        const data = doc.data();
        totalAmount += data.amount;
        transactionCount++;
      });

      trends.push({
        month: `${month.getFullYear()}-${String(month.getMonth() + 1).padStart(2, '0')}`,
        amount: totalAmount,
        transactionCount,
      });
    }

    res.json({
      success: true,
      data: trends,
    });
  } catch (error) {
    console.error('Error getting expense trends:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get expense trends',
      message: error.message,
    });
  }
});

// GET /api/expenses/categories
router.get('/categories', verifyToken, async (req, res) => {
  try {
    const categories = [
      { id: 'groceries', name: 'Groceries', icon: 'shopping_cart', color: '#4CAF50' },
      { id: 'household', name: 'Household', icon: 'home', color: '#2196F3' },
      { id: 'personal', name: 'Personal', icon: 'person', color: '#FF9800' },
      { id: 'health', name: 'Health & Beauty', icon: 'favorite', color: '#E91E63' },
      { id: 'transport', name: 'Transport', icon: 'directions_car', color: '#9C27B0' },
      { id: 'entertainment', name: 'Entertainment', icon: 'movie', color: '#FF5722' },
      { id: 'other', name: 'Other', icon: 'more_horiz', color: '#607D8B' },
    ];

    res.json({
      success: true,
      data: categories,
    });
  } catch (error) {
    console.error('Error getting categories:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get categories',
      message: error.message,
    });
  }
});

// POST /api/expenses
router.post('/', verifyToken, async (req, res) => {
  try {
    const { userId } = req.user;
    const {
      category,
      amount,
      currency = 'RM',
      description,
      date,
      receiptId,
      storeId,
      storeName,
      tags = [],
    } = req.body;

    if (!category || amount === undefined || !description) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: category, amount, description',
      });
    }

    const now = new Date();
    const expenseData = {
      userId,
      category,
      amount: parseFloat(amount),
      currency,
      description,
      date: date ? new Date(date) : now,
      receiptId: receiptId || null,
      storeId: storeId || null,
      storeName: storeName || null,
      tags: Array.isArray(tags) ? tags : [],
      createdAt: now,
      updatedAt: now,
    };

    const docRef = await db.collection('expenses').add(expenseData);

    res.status(201).json({
      success: true,
      data: {
        id: docRef.id,
        ...expenseData,
        date: expenseData.date.toISOString(),
        createdAt: expenseData.createdAt.toISOString(),
        updatedAt: expenseData.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error adding expense:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add expense',
      message: error.message,
    });
  }
});

// PUT /api/expenses/:id
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.user;
    const updateData = req.body;

    const doc = await db.collection('expenses').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Expense not found',
      });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'Access denied',
      });
    }

    if (updateData.date) {
      updateData.date = new Date(updateData.date);
    }
    updateData.updatedAt = new Date();

    await db.collection('expenses').doc(id).update(updateData);

    const updatedDoc = await db.collection('expenses').doc(id).get();
    const data = updatedDoc.data();

    res.json({
      success: true,
      data: {
        id: updatedDoc.id,
        ...data,
        date: data.date?.toDate?.()?.toISOString(),
        createdAt: data.createdAt?.toDate?.()?.toISOString(),
        updatedAt: data.updatedAt?.toDate?.()?.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error updating expense:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update expense',
      message: error.message,
    });
  }
});

// DELETE /api/expenses/:id
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { userId } = req.user;

    const doc = await db.collection('expenses').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Expense not found',
      });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({
        success: false,
        error: 'Access denied',
      });
    }

    await db.collection('expenses').doc(id).delete();

    res.json({
      success: true,
      message: 'Expense deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting expense:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete expense',
      message: error.message,
    });
  }
});

export default router;



