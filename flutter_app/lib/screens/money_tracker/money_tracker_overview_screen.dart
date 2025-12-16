import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/expense_tracking_service.dart';
import '../../models/expense_tracking.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final ExpenseTrackingService _expenseService = ExpenseTrackingService();
  List<ExpenseTracking> _expenses = [];
  bool _isLoading = true;
  MonthlyExpenseSummary? _monthlySummary;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final expenses = await _expenseService.getUserExpenses(
        user.uid,
        limit: 50,
      );
      final summary = await _expenseService.getMonthlySummary(
        user.uid,
        DateTime.now(),
      );

      setState(() {
        _expenses = expenses;
        _monthlySummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading expenses: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Tracker'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExpenses,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monthly Summary
                    if (_monthlySummary != null) _buildMonthlySummary(),
                    const SizedBox(height: 20),

                    _buildReportActions(),
                    const SizedBox(height: 20),

                    // Recent Expenses
                    _buildRecentExpenses(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReportActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: trigger monthly PDF/CSV export (backend)
              debugPrint('Export monthly report');
            },
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Export report'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _addExpense,
            icon: const Icon(Icons.add_chart),
            label: const Text('Manual expense'),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySummary() {
    final summary = _monthlySummary!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Month',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Spent',
                    summary.formattedTotalAmount,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Transactions',
                    '${summary.transactionCount}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Average',
                    summary.formattedAverageTransaction,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Last Month',
                    summary.formattedPreviousMonthAmount,
                    Colors.grey,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Change',
                    summary.formattedPercentageChange,
                    summary.percentageChange >= 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentExpenses() {
    if (_expenses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No expenses yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first expense',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Expenses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._expenses.map((expense) => _buildExpenseCard(expense)),
      ],
    );
  }

  Widget _buildExpenseCard(ExpenseTracking expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense.category).withAlpha((255 * 0.2).round()),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: _getCategoryColor(expense.category),
          ),
        ),
        title: Text(expense.description),
        subtitle: Text('${expense.category} • ${expense.formattedDate}'),
        trailing: Text(
          expense.formattedAmount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Colors.green;
      case 'household':
        return Colors.blue;
      case 'personal':
        return Colors.orange;
      case 'health':
        return Colors.pink;
      case 'transport':
        return Colors.purple;
      case 'entertainment':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'household':
        return Icons.home;
      case 'personal':
        return Icons.person;
      case 'health':
        return Icons.favorite;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  void _addExpense() {
    // Show add expense dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: const Text('Expense tracking feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
