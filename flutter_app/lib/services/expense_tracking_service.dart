import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/expense_tracking.dart';

class ExpenseTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add expense
  Future<void> addExpense(ExpenseTracking expense) async {
    try {
      await _firestore.collection('expenses').add(expense.toFirestore());
    } catch (e) {
      debugPrint('Error adding expense: $e');
      throw Exception('Failed to add expense');
    }
  }

  // Get user's expenses
  Future<List<ExpenseTracking>> getUserExpenses(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ExpenseTracking.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting user expenses: $e');
      return [];
    }
  }

  // Get monthly expense summary
  Future<MonthlyExpenseSummary> getMonthlySummary(
    String userId,
    DateTime month,
  ) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final expenses = await getUserExpenses(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
        limit: 1000,
      );

      if (expenses.isEmpty) {
        return MonthlyExpenseSummary(
          month: '${month.year}-${month.month.toString().padLeft(2, '0')}',
          totalAmount: 0.0,
          categoryBreakdown: {},
          transactionCount: 0,
          averageTransaction: 0.0,
          previousMonthAmount: 0.0,
          percentageChange: 0.0,
        );
      }

      // Calculate totals
      final totalAmount = expenses.fold(
        0.0,
        (runningTotal, expense) => runningTotal + expense.amount,
      );
      final transactionCount = expenses.length;
      final averageTransaction = totalAmount / transactionCount;

      // Calculate category breakdown
      final Map<String, double> categoryBreakdown = {};
      for (var expense in expenses) {
        categoryBreakdown[expense.category] =
            (categoryBreakdown[expense.category] ?? 0.0) + expense.amount;
      }

      // Get previous month data
      final previousMonth = DateTime(month.year, month.month - 1);
      final previousMonthExpenses = await getUserExpenses(
        userId,
        startDate: DateTime(previousMonth.year, previousMonth.month, 1),
        endDate: DateTime(
          previousMonth.year,
          previousMonth.month + 1,
          0,
          23,
          59,
          59,
        ),
        limit: 1000,
      );

      final previousMonthAmount = previousMonthExpenses.fold(
        0.0,
        (runningTotal, expense) => runningTotal + expense.amount,
      );

      double percentageChange = 0.0;
      if (previousMonthAmount > 0) {
        percentageChange =
            ((totalAmount - previousMonthAmount) / previousMonthAmount) * 100;
      }

      return MonthlyExpenseSummary(
        month: '${month.year}-${month.month.toString().padLeft(2, '0')}',
        totalAmount: totalAmount,
        categoryBreakdown: categoryBreakdown,
        transactionCount: transactionCount,
        averageTransaction: averageTransaction,
        previousMonthAmount: previousMonthAmount,
        percentageChange: percentageChange,
      );
    } catch (e) {
      debugPrint('Error getting monthly summary: $e');
      return MonthlyExpenseSummary(
        month: '${month.year}-${month.month.toString().padLeft(2, '0')}',
        totalAmount: 0.0,
        categoryBreakdown: {},
        transactionCount: 0,
        averageTransaction: 0.0,
        previousMonthAmount: 0.0,
        percentageChange: 0.0,
      );
    }
  }

  // Get expense categories
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    try {
      // In a real app, you might store these in Firestore
      // For now, return predefined categories
      return [
        ExpenseCategory(
          id: 'groceries',
          name: 'Groceries',
          icon: 'shopping_cart',
          color: '#4CAF50',
        ),
        ExpenseCategory(
          id: 'household',
          name: 'Household',
          icon: 'home',
          color: '#2196F3',
        ),
        ExpenseCategory(
          id: 'personal',
          name: 'Personal',
          icon: 'person',
          color: '#FF9800',
        ),
        ExpenseCategory(
          id: 'health',
          name: 'Health & Beauty',
          icon: 'favorite',
          color: '#E91E63',
        ),
        ExpenseCategory(
          id: 'transport',
          name: 'Transport',
          icon: 'directions_car',
          color: '#9C27B0',
        ),
        ExpenseCategory(
          id: 'entertainment',
          name: 'Entertainment',
          icon: 'movie',
          color: '#FF5722',
        ),
        ExpenseCategory(
          id: 'other',
          name: 'Other',
          icon: 'more_horiz',
          color: '#607D8B',
        ),
      ];
    } catch (e) {
      debugPrint('Error getting expense categories: $e');
      return [];
    }
  }

  // Update expense
  Future<void> updateExpense(ExpenseTracking expense) async {
    try {
      await _firestore
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toFirestore());
    } catch (e) {
      debugPrint('Error updating expense: $e');
      throw Exception('Failed to update expense');
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).delete();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      throw Exception('Failed to delete expense');
    }
  }

  // Get expense by ID
  Future<ExpenseTracking?> getExpense(String expenseId) async {
    try {
      final doc = await _firestore.collection('expenses').doc(expenseId).get();
      if (doc.exists) {
        return ExpenseTracking.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting expense: $e');
      return null;
    }
  }

  // Get spending trends (last 6 months)
  Future<List<Map<String, dynamic>>> getSpendingTrends(String userId) async {
    try {
      final List<Map<String, dynamic>> trends = [];
      final now = DateTime.now();

      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i);
        final summary = await getMonthlySummary(userId, month);

        trends.add({
          'month': summary.month,
          'amount': summary.totalAmount,
          'transactionCount': summary.transactionCount,
        });
      }

      return trends;
    } catch (e) {
      debugPrint('Error getting spending trends: $e');
      return [];
    }
  }
}








