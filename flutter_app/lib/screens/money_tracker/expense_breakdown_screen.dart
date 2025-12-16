import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
  String _selectedPeriod = 'Monthly'; // Monthly, Yearly
  String _selectedView = 'Category'; // Category, Month

  // Mock data
  final List<CategoryExpense> _categoryExpenses = [
    CategoryExpense(category: 'Groceries', amount: 1250.00, color: kBlack),
    CategoryExpense(category: 'Dining Out', amount: 450.00, color: kDarkGray),
    CategoryExpense(category: 'Household', amount: 320.00, color: kMediumGray),
    CategoryExpense(
      category: 'Personal Care',
      amount: 180.00,
      color: kLightGray,
    ),
    CategoryExpense(category: 'Other', amount: 150.00, color: kMediumGray),
  ];

  final List<MonthlyExpense> _monthlyExpenses = [
    MonthlyExpense(month: 'Jan', amount: 1200.00),
    MonthlyExpense(month: 'Feb', amount: 1350.00),
    MonthlyExpense(month: 'Mar', amount: 1100.00),
    MonthlyExpense(month: 'Apr', amount: 1450.00),
    MonthlyExpense(month: 'May', amount: 1300.00),
    MonthlyExpense(month: 'Jun', amount: 1250.00),
  ];

  @override
  Widget build(BuildContext context) {
    final totalExpense = _categoryExpenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: kBlack),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Monthly', child: Text('Monthly')),
              const PopupMenuItem(value: 'Yearly', child: Text('Yearly')),
            ],
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
                    'RM ${totalExpense.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedPeriod == 'Monthly' ? 'This Month' : 'This Year',
                    style: TextStyle(
                      color: kWhite.withOpacity(0.7),
                      fontSize: 12,
                    ),
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
                      'Category',
                      _selectedView == 'Category',
                    ),
                  ),
                  Expanded(
                    child: _buildToggleButton(
                      'Month',
                      _selectedView == 'Month',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chart
            if (_selectedView == 'Category')
              _buildCategoryChart()
            else
              _buildMonthlyChart(),

            const SizedBox(height: 24),

            // Breakdown List
            const Text(
              'Breakdown',
              style: TextStyle(
                color: kBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedView == 'Category')
              ..._categoryExpenses.map(
                (expense) => _buildCategoryItem(expense, totalExpense),
              )
            else
              ..._monthlyExpenses.map((expense) => _buildMonthlyItem(expense)),
          ],
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
        border: Border.all(color: kMediumGray.withOpacity(0.2)),
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

  Widget _buildMonthlyChart() {
    final maxAmount = _monthlyExpenses
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kMediumGray.withOpacity(0.2)),
      ),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxAmount / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: kMediumGray.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < _monthlyExpenses.length) {
                    return Text(
                      _monthlyExpenses[value.toInt()].month,
                      style: const TextStyle(color: kMediumGray, fontSize: 10),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'RM${value.toInt()}',
                    style: const TextStyle(color: kMediumGray, fontSize: 10),
                  );
                },
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: kMediumGray.withOpacity(0.2)),
          ),
          barGroups: _monthlyExpenses.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.amount,
                  color: kBlack,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
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
        side: BorderSide(color: kMediumGray.withOpacity(0.2)),
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

  Widget _buildMonthlyItem(MonthlyExpense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kMediumGray.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              expense.month,
              style: const TextStyle(
                color: kBlack,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'RM ${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: kBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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

class MonthlyExpense {
  final String month;
  final double amount;

  MonthlyExpense({required this.month, required this.amount});
}
