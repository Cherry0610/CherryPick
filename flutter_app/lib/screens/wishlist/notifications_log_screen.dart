import 'package:flutter/material.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class NotificationsLogScreen extends StatefulWidget {
  const NotificationsLogScreen({super.key});

  @override
  State<NotificationsLogScreen> createState() => _NotificationsLogScreenState();
}

class _NotificationsLogScreenState extends State<NotificationsLogScreen> {
  String _filter = 'All'; // All, Today, This Week, This Month

  // Mock notifications
  final List<PriceAlert> _notifications = [
    PriceAlert(
      productName: 'Sony WH-1000XM4',
      oldPrice: 1299.00,
      newPrice: 1099.00,
      store: 'NSK Grocer',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    PriceAlert(
      productName: 'Nintendo Switch',
      oldPrice: 999.00,
      newPrice: 899.00,
      store: 'Tesco',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    PriceAlert(
      productName: 'Instant Pot Duo',
      oldPrice: 499.00,
      newPrice: 449.00,
      store: 'Giant',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
    PriceAlert(
      productName: 'Kindle Paperwhite',
      oldPrice: 549.00,
      newPrice: 499.00,
      store: 'AEON',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
    ),
  ];

  List<PriceAlert> get _filteredNotifications {
    final now = DateTime.now();
    switch (_filter) {
      case 'Today':
        return _notifications.where((n) {
          return n.timestamp.day == now.day &&
              n.timestamp.month == now.month &&
              n.timestamp.year == now.year;
        }).toList();
      case 'This Week':
        return _notifications.where((n) {
          return n.timestamp.isAfter(now.subtract(const Duration(days: 7)));
        }).toList();
      case 'This Month':
        return _notifications.where((n) {
          return n.timestamp.month == now.month && n.timestamp.year == now.year;
        }).toList();
      default:
        return _notifications;
    }
  }

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
          'Price Alerts',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kBlack),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kLightGray,
              border: Border(
                bottom: BorderSide(color: kMediumGray.withOpacity(0.2)),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Today'),
                  const SizedBox(width: 8),
                  _buildFilterChip('This Week'),
                  const SizedBox(width: 8),
                  _buildFilterChip('This Month'),
                ],
              ),
            ),
          ),

          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        _filteredNotifications[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = label;
        });
      },
      backgroundColor: kWhite,
      selectedColor: kBlack,
      labelStyle: TextStyle(
        color: isSelected ? kWhite : kBlack,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? kBlack : kMediumGray.withOpacity(0.3),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: kMediumGray),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              color: kMediumGray,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see price alerts here when items drop',
            style: TextStyle(color: kMediumGray, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(PriceAlert alert) {
    final priceDrop = alert.oldPrice - alert.newPrice;
    final priceDropPercent = (priceDrop / alert.oldPrice) * 100;
    final timeAgo = _getTimeAgo(alert.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: alert.isRead ? kWhite : kLightGray,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.isRead
              ? kMediumGray.withOpacity(0.2)
              : kBlack.withOpacity(0.3),
          width: alert.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            alert.isRead = true;
          });
          // TODO: Navigate to product
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: kWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.productName,
                            style: TextStyle(
                              color: kBlack,
                              fontSize: 16,
                              fontWeight: alert.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!alert.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kBlack,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'RM ${alert.oldPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: kMediumGray,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RM ${alert.newPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: kBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: kBlack,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${priceDropPercent.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: kWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.store, size: 14, color: kMediumGray),
                        const SizedBox(width: 4),
                        Text(
                          alert.store,
                          style: const TextStyle(
                            color: kMediumGray,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 14, color: kMediumGray),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
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
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kWhite,
        title: const Text(
          'Clear All Notifications?',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will remove all notifications from your log.',
          style: TextStyle(color: kMediumGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kMediumGray)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: kBlack)),
          ),
        ],
      ),
    );
  }
}

class PriceAlert {
  final String productName;
  final double oldPrice;
  final double newPrice;
  final String store;
  final DateTime timestamp;
  bool isRead;

  PriceAlert({
    required this.productName,
    required this.oldPrice,
    required this.newPrice,
    required this.store,
    required this.timestamp,
    this.isRead = false,
  });
}
