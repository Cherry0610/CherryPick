import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_expense_screen.dart';
import '../wishlist/notifications_log_screen.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../../backend/services/expense_tracking_service.dart';
import '../../../backend/services/receipt_ocr_service.dart';

// Figma Design Colors
const Color kExpenseRed = Color(0xFFE85D5D);
const Color kExpenseWhite = Color(0xFFFFFFFF);
const Color kExpenseBackground = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBorderGray = Color(0xFFE5E7EB);

// Category Data Model
class CategoryData {
  final String name;
  final double value;
  final Color color;

  CategoryData({
    required this.name,
    required this.value,
    required this.color,
  });
}

// Recent Expense Model
class RecentExpense {
  final String id;
  final String store;
  final String category;
  final double amount;
  final String date;
  final String icon;

  RecentExpense({
    required this.id,
    required this.store,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
  });
}

class MoneyTrackerOverviewScreen extends StatefulWidget {
  const MoneyTrackerOverviewScreen({super.key});

  @override
  State<MoneyTrackerOverviewScreen> createState() =>
      _MoneyTrackerOverviewScreenState();
}

class _MoneyTrackerOverviewScreenState
    extends State<MoneyTrackerOverviewScreen> {
  String _selectedPeriod = 'This Month';

  final List<String> _periods = ['Today', 'This Week', 'This Month', 'This Year'];
  final ExpenseTrackingService _expenseService = ExpenseTrackingService();
  final ReceiptOcrService _receiptService = ReceiptOcrService();

  final double _totalExpenses = 450.0;

  final List<CategoryData> _categoryData = [
    CategoryData(name: 'Groceries', value: 180, color: kExpenseRed),
    CategoryData(name: 'Utilities', value: 120, color: const Color(0xFF4A90E2)),
    CategoryData(name: 'Transport', value: 85.5, color: const Color(0xFF50C878)),
    CategoryData(name: 'Others', value: 64.5, color: const Color(0xFFF5A623)),
  ];

  final List<Map<String, dynamic>> _priceHistoryData = [
    {'day': '1', 'value': 40},
    {'day': '50', 'value': 35},
    {'day': '100', 'value': 42},
    {'day': '150', 'value': 38},
    {'day': '200', 'value': 45},
    {'day': '250', 'value': 50},
    {'day': '300', 'value': 48},
  ];

  final List<RecentExpense> _recentExpenses = [
    RecentExpense(
      id: '1',
      store: 'Whole Foods',
      category: 'Groceries',
      amount: -85.5,
      date: 'Today',
      icon: '🥬',
    ),
    RecentExpense(
      id: '2',
      store: 'Transport',
      category: 'Utilities',
      amount: -85.5,
      date: 'Yesterday',
      icon: '🚗',
    ),
  ];

  void _onAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
  }

  Future<void> _handleClearAllData() async {
    // First confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Expense Data'),
        content: const Text(
          'Are you sure you want to delete all your expenses and receipts? This action cannot be undone.\n\nAll expense records and receipt data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Second confirmation for extra safety
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'This will permanently delete ALL your expense and receipt data. This cannot be undone.\n\nDo you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (doubleConfirmed == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please sign in to clear data'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Show loading dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Clear all expenses
        await _expenseService.clearAllExpenses(user.uid);
        
        // Clear all receipts
        await _receiptService.clearAllReceipts(user.uid);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All expense data cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Refresh the screen
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog if still open
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing data: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kExpenseBackground,
      appBar: AppBar(
        backgroundColor: kExpenseWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: kTextLight),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kExpenseRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsLogScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: kExpenseRed),
            onPressed: _onAddExpense,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: kTextDark),
            onSelected: (value) {
              if (value == 'clear_all') {
                _handleClearAllData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Clear All Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              _buildPeriodSelector(),
              const SizedBox(height: 16),

              // Total Summary
              _buildTotalSummary(),
              const SizedBox(height: 16),

              // Category Breakdown
              _buildCategoryBreakdown(),
              const SizedBox(height: 16),

              // Price History
              _buildPriceHistory(),
              const SizedBox(height: 16),

              // Recent History
              _buildRecentHistory(),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddExpense,
        backgroundColor: kExpenseRed,
        child: const Icon(Icons.add, color: kExpenseWhite),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _periods.map((period) {
            final isSelected = _selectedPeriod == period;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriod = period),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? kExpenseRed : kExpenseBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      color: isSelected ? kExpenseWhite : kTextDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              color: kTextLight,
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RM${_totalExpenses.toStringAsFixed(2)}',
            style: const TextStyle(
              color: kExpenseRed,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Expenses This Month',
            style: TextStyle(
              color: kTextLight,
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nearby Tracker',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          // Pie Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 60,
                sections: _categoryData.map((category) {
                  return PieChartSectionData(
                    value: category.value,
                    color: category.color,
                    radius: 80,
                    title: '',
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Expense List',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextDark,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 12),
          ..._categoryData.map((category) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kExpenseBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category.name,
                        style: const TextStyle(
                          color: kTextDark,
                          fontSize: 14,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '-RM${category.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: kExpenseRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price History (90 Days)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                  fontFamily: 'Roboto',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: kTextLight),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 50 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: kTextLight,
                              fontSize: 10,
                              fontFamily: 'Roboto',
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _priceHistoryData.asMap().entries.map((entry) {
                      return FlSpot(
                        double.tryParse(entry.value['day'].toString()) ?? entry.key.toDouble(),
                        entry.value['value'].toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: kExpenseRed,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Set price alert
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kExpenseRed,
                foregroundColor: kExpenseWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Set Price Alert',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kTextDark,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 12),
        ..._recentExpenses.map((expense) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          expense.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.store,
                          style: const TextStyle(
                            color: kTextDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          expense.category,
                          style: const TextStyle(
                            color: kTextLight,
                            fontSize: 12,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'RM${expense.amount.abs().toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: kExpenseRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Text(
                      expense.date,
                      style: TextStyle(
                        color: kTextLight.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
