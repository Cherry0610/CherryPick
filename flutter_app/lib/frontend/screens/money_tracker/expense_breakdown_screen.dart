import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../backend/services/expense_tracking_service.dart';
import '../../../backend/models/expense_tracking.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class ExpenseBreakdownScreen extends StatefulWidget {
  const ExpenseBreakdownScreen({super.key});

  @override
  State<ExpenseBreakdownScreen> createState() => _ExpenseBreakdownScreenState();
}

class _ExpenseBreakdownScreenState extends State<ExpenseBreakdownScreen> {
  final ExpenseTrackingService _expenseService = ExpenseTrackingService();
  String _selectedPeriod = 'Today'; // Today, This Week, This Month, This Year
  String _selectedView = 'Store'; // Store, Category
  bool _isLoading = true;

  // Real data from Firestore
  List<CategoryExpense> _categoryExpenses = [];
  List<StoreExpense> _storeExpenses = [];
  List<ExpenseTracking> _expenses = [];
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadExpenseData();
  }

  Future<void> _loadExpenseData() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Calculate date range based on selected period
      switch (_selectedPeriod) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'This Week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
          break;
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'This Year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      // Load expenses for the selected period
      _expenses = await _expenseService.getUserExpenses(
        user.uid,
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );

      // Calculate total
      _totalExpense = _expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

      // Group by store
      final Map<String, double> storeBreakdown = {};
      for (var expense in _expenses) {
        final storeName = expense.storeName ?? 'Unknown Store';
        storeBreakdown[storeName] = (storeBreakdown[storeName] ?? 0) + expense.amount;
      }
      _storeExpenses = storeBreakdown.entries.map((entry) {
        return StoreExpense(
          storeName: entry.key,
          amount: entry.value,
          color: _getStoreColor(entry.key),
        );
      }).toList();
      _storeExpenses.sort((a, b) => b.amount.compareTo(a.amount));

      // Group by category
      final Map<String, double> categoryBreakdown = {};
      for (var expense in _expenses) {
        categoryBreakdown[expense.category] = (categoryBreakdown[expense.category] ?? 0) + expense.amount;
      }
      _categoryExpenses = categoryBreakdown.entries.map((entry) {
        return CategoryExpense(
          category: entry.key,
          amount: entry.value,
          color: _getCategoryColor(entry.key),
        );
      }).toList();
      _categoryExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    } catch (e) {
      debugPrint('❌ Error loading expense data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStoreColor(String storeName) {
    final colors = [
      kBlack,
      kDarkGray,
      kMediumGray,
      kLightGray,
    ];
    return colors[storeName.hashCode % colors.length];
  }

  Color _getCategoryColor(String category) {
    final colors = [
      kBlack,
      kDarkGray,
      kMediumGray,
      kLightGray,
    ];
    return colors[category.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          backgroundColor: kWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kBlack),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Expense Breakdown',
            style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expense Breakdown',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Barcode Scanner Block
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                // Navigate to receipt scanner
                Navigator.pushNamed(context, '/receipts');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kBlack,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.qr_code_scanner, color: kWhite, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Scan Receipt',
                      style: TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Expense Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Expenses',
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RM ${_totalExpense.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedPeriod,
                    style: TextStyle(
                      color: kWhite.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Period Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: kLightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPeriodButton('Today', _selectedPeriod == 'Today'),
                  ),
                  Expanded(
                    child: _buildPeriodButton('This Week', _selectedPeriod == 'This Week'),
                  ),
                  Expanded(
                    child: _buildPeriodButton('This Month', _selectedPeriod == 'This Month'),
                  ),
                  Expanded(
                    child: _buildPeriodButton('This Year', _selectedPeriod == 'This Year'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // View Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: kLightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      'Store',
                      _selectedView == 'Store',
                    ),
                  ),
                  Expanded(
                    child: _buildToggleButton(
                      'Category',
                      _selectedView == 'Category',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chart
            if (_selectedView == 'Store')
              _buildStoreChart()
            else
              _buildCategoryChart(),

            const SizedBox(height: 24),

            // Breakdown List
            const Text(
              'Expense List',
              style: TextStyle(
                color: kBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedView == 'Store')
              ..._storeExpenses.map(
                (expense) => _buildStoreItem(expense, _totalExpense),
              )
            else
              ..._categoryExpenses.map(
                (expense) => _buildCategoryItem(expense, _totalExpense),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
        _loadExpenseData();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? kWhite : kBlack,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedView = label;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? kWhite : kBlack,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChart() {
    final total = _categoryExpenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kMediumGray.withValues(alpha: 0.2)),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: _categoryExpenses.map((expense) {
            return PieChartSectionData(
              value: expense.amount,
              title: '${((expense.amount / total) * 100).toStringAsFixed(0)}%',
              color: expense.color,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kWhite,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStoreChart() {
    final total = _storeExpenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kMediumGray.withValues(alpha: 0.2)),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: _storeExpenses.map((expense) {
            return PieChartSectionData(
              value: expense.amount,
              title: '${((expense.amount / total) * 100).toStringAsFixed(0)}%',
              color: expense.color,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kWhite,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryExpense expense, double total) {
    final percentage = (expense.amount / total) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kMediumGray.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: expense.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: const TextStyle(
                      color: kBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: kLightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(expense.color),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RM ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: kBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(color: kMediumGray, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreItem(StoreExpense expense, double total) {
    final percentage = (expense.amount / total) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kMediumGray.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: expense.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.storeName,
                    style: const TextStyle(
                      color: kBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: kLightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(expense.color),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RM ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: kBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(color: kMediumGray, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryExpense {
  final String category;
  final double amount;
  final Color color;

  CategoryExpense({
    required this.category,
    required this.amount,
    required this.color,
  });
}

class StoreExpense {
  final String storeName;
  final double amount;
  final Color color;

  StoreExpense({
    required this.storeName,
    required this.amount,
    required this.color,
  });
}


