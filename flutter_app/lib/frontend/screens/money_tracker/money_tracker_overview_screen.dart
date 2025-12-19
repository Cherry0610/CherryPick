import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upload_receipt_screen.dart';
import '../wishlist/notifications_log_screen.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../../backend/services/expense_tracking_service.dart';
import '../../../backend/services/receipt_ocr_service.dart';
import '../../../backend/models/expense_tracking.dart';

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

  double _totalExpenses = 0.0;
  List<CategoryData> _categoryData = [];
  List<Map<String, dynamic>> _priceHistoryData = [];
  List<RecentExpense> _recentExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload expenses when screen becomes visible again
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _totalExpenses = 0.0;
        _categoryData = [];
        _recentExpenses = [];
        _priceHistoryData = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      DateTime? startDate;
      
      switch (_selectedPeriod) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'This Week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          break;
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'This Year':
          startDate = DateTime(now.year, 1, 1);
          break;
      }

      final expenses = await _expenseService.getUserExpenses(
        user.uid,
        startDate: startDate,
        endDate: now,
        limit: 1000,
      );

      // Add mock data for demonstration
      final List<ExpenseTracking> allExpenses = List.from(expenses);
      
      // RM20 spent today at NSK Grocer
      final today = DateTime(now.year, now.month, now.day);
      allExpenses.add(ExpenseTracking(
        id: 'mock_nsk_today',
        userId: user.uid,
      category: 'Groceries',
        amount: 20.0,
        currency: 'MYR',
        description: 'Grocery shopping at NSK Grocer',
        date: today,
        storeName: 'NSK Grocer',
        tags: ['mock', 'groceries'],
        createdAt: today,
        updatedAt: today,
      ));

      // RM100 spent last week at Jaya Grocer
      final lastWeek = now.subtract(Duration(days: now.weekday + 3)); // Last week
      final lastWeekDate = DateTime(lastWeek.year, lastWeek.month, lastWeek.day);
      allExpenses.add(ExpenseTracking(
        id: 'mock_jaya_lastweek',
        userId: user.uid,
        category: 'Groceries',
        amount: 100.0,
        currency: 'MYR',
        description: 'Weekly grocery shopping at Jaya Grocer',
        date: lastWeekDate,
        storeName: 'Jaya Grocer',
        tags: ['mock', 'groceries'],
        createdAt: lastWeekDate,
        updatedAt: lastWeekDate,
      ));

      // Calculate total expenses
      final total = allExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      
      // Calculate store breakdown (group by grocery store)
      final Map<String, double> storeMap = {};
      for (var expense in allExpenses) {
        final storeName = expense.storeName ?? 'Other';
        storeMap[storeName] = (storeMap[storeName] ?? 0.0) + expense.amount;
      }

      final categoryData = storeMap.entries.map((entry) {
        Color storeColor;
        final storeName = entry.key.toLowerCase();
        if (storeName.contains('nsk')) {
          storeColor = const Color(0xFF8B4513);
        } else if (storeName.contains('tesco')) {
          storeColor = const Color(0xFF0066CC);
        } else if (storeName.contains('jaya') || storeName.contains('jayagrocer')) {
          storeColor = const Color(0xFF50C878);
        } else if (storeName.contains('lotus')) {
          storeColor = const Color(0xFFE91E63);
        } else if (storeName.contains('aeon')) {
          storeColor = const Color(0xFF4A90E2);
        } else if (storeName.contains('mydin')) {
          storeColor = const Color(0xFFFF6B35);
        } else if (storeName.contains('village')) {
          storeColor = kExpenseRed;
        } else {
          storeColor = const Color(0xFF808080);
        }
        return CategoryData(
          name: entry.key,
          value: entry.value,
          color: storeColor,
        );
      }).toList();
      
      // Sort by amount (highest first)
      categoryData.sort((a, b) => b.value.compareTo(a.value));

      // Get recent expenses (last 5) - sorted by date (most recent first)
      final sortedExpenses = List<ExpenseTracking>.from(allExpenses)
        ..sort((a, b) => b.date.compareTo(a.date));
      
      final recentExpenses = sortedExpenses.take(5).map((expense) {
        // Get icon based on store name
        String icon = '🛒';
        final storeName = (expense.storeName ?? '').toLowerCase();
        if (storeName.contains('nsk')) {
          icon = '🛒';
        } else if (storeName.contains('tesco')) {
          icon = '🛒';
        } else if (storeName.contains('jaya') || storeName.contains('jayagrocer')) {
          icon = '🛒';
        } else if (storeName.contains('lotus')) {
          icon = '🛒';
        } else if (storeName.contains('aeon')) {
          icon = '🛒';
        } else if (storeName.contains('mydin')) {
          icon = '🛒';
        } else if (storeName.contains('village')) {
          icon = '🛒';
        } else {
          // Fallback to category-based icon
          switch (expense.category.toLowerCase()) {
            case 'groceries':
              icon = '🥬';
              break;
            case 'transport':
              icon = '🚗';
              break;
            case 'utilities':
              icon = '💡';
              break;
            default:
              icon = '🛒';
          }
        }

        final expenseDate = expense.date;
        final difference = now.difference(expenseDate);
        String dateLabel;
        if (difference.inMinutes < 60) {
          dateLabel = '${difference.inMinutes}m ago';
        } else if (difference.inHours < 24) {
          dateLabel = '${difference.inHours}h ago';
        } else if (difference.inDays == 0) {
          dateLabel = 'Today';
        } else if (difference.inDays == 1) {
          dateLabel = 'Yesterday';
        } else if (difference.inDays < 7) {
          dateLabel = '${difference.inDays}d ago';
        } else {
          dateLabel = '${expenseDate.day}/${expenseDate.month}/${expenseDate.year}';
        }

        // Use store name if available, otherwise use description
        final displayStore = expense.storeName?.isNotEmpty == true
            ? expense.storeName!
            : (expense.description.isNotEmpty ? expense.description : 'Expense');

        return RecentExpense(
          id: expense.id,
          store: displayStore,
          category: expense.category,
          amount: -expense.amount,
          date: dateLabel,
          icon: icon,
        );
      }).toList();

      // Generate price history data (last 7 days)
      final priceHistoryData = <Map<String, dynamic>>[];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayExpenses = allExpenses.where((e) {
          return e.date.year == date.year &&
                 e.date.month == date.month &&
                 e.date.day == date.day;
        }).toList();
        final dayTotal = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
        priceHistoryData.add({
          'day': date.day.toString(),
          'value': dayTotal,
        });
      }

      setState(() {
        _totalExpenses = total;
        _categoryData = categoryData;
        _recentExpenses = recentExpenses;
        _priceHistoryData = priceHistoryData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading expenses: $e');
      setState(() {
        _totalExpenses = 0.0;
        _categoryData = [];
        _recentExpenses = [];
        _priceHistoryData = [];
        _isLoading = false;
      });
    }
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
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCategoryBreakdown(),
              const SizedBox(height: 16),

              // Scan Receipt Button (Big, separate from period selector)
              _buildScanReceiptButton(),
              const SizedBox(height: 16),

              // Price History
              _isLoading
                  ? const SizedBox.shrink()
                  : _buildPriceHistory(),
              const SizedBox(height: 16),

              // Recent History
              _isLoading
                  ? const SizedBox.shrink()
                  : _buildRecentHistory(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              children: [
                // Period filters
                ..._periods.map((period) {
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
              ],
        ),
      ),
        ),
      ],
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
            'Expenses by Store',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          // Pie Chart
          _categoryData.isEmpty
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline, size: 64, color: kTextLight),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses yet',
                          style: TextStyle(color: kTextLight, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
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
            'Expenses by Store',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextDark,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 12),
          if (_categoryData.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No expenses in this period',
                style: TextStyle(color: kTextLight, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            )
          else
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

  Widget _buildScanReceiptButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReceiptUploadScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kExpenseRed,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kExpenseRed.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long,
              color: kExpenseWhite,
              size: 28,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan Receipt',
                  style: TextStyle(
                    color: kExpenseWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload e-receipt or enter manually',
                  style: TextStyle(
                    color: kExpenseWhite.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: kExpenseWhite,
              size: 20,
            ),
          ],
        ),
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
        if (_recentExpenses.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
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
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: kTextLight),
                  const SizedBox(height: 12),
                  Text(
                    'No recent expenses',
                    style: TextStyle(
                      color: kTextLight,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add expenses to see them here',
                    style: TextStyle(
                      color: kTextLight.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          )
        else
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
