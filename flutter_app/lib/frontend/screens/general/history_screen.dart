import 'package:flutter/material.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 0; // 0: Shopping Lists, 1: Reports, 2: Notifications

  @override
  Widget build(BuildContext context) {
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
          'History',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(),

          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildShoppingListsTab()
                : _selectedTab == 1
                ? _buildReportsTab()
                : _buildNotificationsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: kLightGray,
        border: Border(bottom: BorderSide(color: kMediumGray.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          _buildTab('Lists', 0),
          _buildTab('Reports', 1),
          _buildTab('Alerts', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? kBlack : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? kBlack : kMediumGray,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingListsTab() {
    final lists = [
      ShoppingList(
        name: 'Weekly Groceries',
        date: DateTime(2025, 4, 15),
        itemCount: 12,
      ),
      ShoppingList(
        name: 'Monthly Shopping',
        date: DateTime(2025, 3, 28),
        itemCount: 25,
      ),
      ShoppingList(
        name: 'Party Supplies',
        date: DateTime(2025, 3, 10),
        itemCount: 8,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [...lists.map((list) => _buildShoppingListCard(list))],
    );
  }

  Widget _buildShoppingListCard(ShoppingList list) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kMediumGray.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to list details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kLightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_cart, color: kBlack, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: kMediumGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${list.date.day}/${list.date.month}/${list.date.year}',
                          style: const TextStyle(
                            color: kMediumGray,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.inventory_2, size: 14, color: kMediumGray),
                        const SizedBox(width: 4),
                        Text(
                          '${list.itemCount} items',
                          style: const TextStyle(
                            color: kMediumGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kMediumGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    final reports = [
      ExpenseReport(month: 'April 2025', total: 2350.00),
      ExpenseReport(month: 'March 2025', total: 2100.00),
      ExpenseReport(month: 'February 2025', total: 1980.00),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [...reports.map((report) => _buildReportCard(report))],
    );
  }

  Widget _buildReportCard(ExpenseReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kMediumGray.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to report details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kLightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart, color: kBlack, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.month,
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RM ${report.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kMediumGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    // This would show notification history
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: kMediumGray),
          const SizedBox(height: 16),
          Text(
            'Notification History',
            style: TextStyle(
              color: kMediumGray,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View detailed notification history',
            style: TextStyle(color: kMediumGray, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to notifications log
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlack,
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View All Notifications'),
          ),
        ],
      ),
    );
  }
}

class ShoppingList {
  final String name;
  final DateTime date;
  final int itemCount;

  ShoppingList({
    required this.name,
    required this.date,
    required this.itemCount,
  });
}

class ExpenseReport {
  final String month;
  final double total;

  ExpenseReport({required this.month, required this.total});
}


