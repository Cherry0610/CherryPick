import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedTab = 0; // 0: Overview, 1: Price History, 2: Comparison

  // Mock price history data
  final List<PriceDataPoint> _priceHistory = [
    PriceDataPoint(date: DateTime(2025, 1, 1), price: 25.90),
    PriceDataPoint(date: DateTime(2025, 1, 15), price: 24.50),
    PriceDataPoint(date: DateTime(2025, 2, 1), price: 26.20),
    PriceDataPoint(date: DateTime(2025, 2, 15), price: 23.80),
    PriceDataPoint(date: DateTime(2025, 3, 1), price: 25.00),
    PriceDataPoint(date: DateTime(2025, 3, 15), price: 24.90),
    PriceDataPoint(date: DateTime(2025, 4, 1), price: 25.50),
  ];

  // Mock retailer data
  final List<RetailerPrice> _retailers = [
    RetailerPrice(
      name: 'NSK Grocer',
      price: 24.90,
      shipping: 5.00,
      inStock: true,
      rating: 4.5,
    ),
    RetailerPrice(
      name: 'Tesco',
      price: 25.50,
      shipping: 0.00,
      inStock: true,
      rating: 4.3,
    ),
    RetailerPrice(
      name: 'Giant',
      price: 26.20,
      shipping: 3.00,
      inStock: true,
      rating: 4.2,
    ),
    RetailerPrice(
      name: 'AEON',
      price: 24.50,
      shipping: 7.00,
      inStock: false,
      rating: 4.4,
    ),
  ];

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
        title: Text(
          widget.productName,
          style: const TextStyle(
            color: kBlack,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: kBlack),
            onPressed: () {
              // TODO: Share product
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing product...'),
                  backgroundColor: kBlack,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: kBlack),
            onPressed: () {
              // TODO: Add to wishlist
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to wishlist'),
                  backgroundColor: kBlack,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(),

          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildOverviewTab()
                : _selectedTab == 1
                ? _buildPriceHistoryTab()
                : _buildComparisonTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: kLightGray,
        border: Border(bottom: BorderSide(color: kMediumGray.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          _buildTab('Overview', 0),
          _buildTab('Price History', 1),
          _buildTab('Compare', 2),
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

  Widget _buildOverviewTab() {
    // Sort retailers by total price (price + shipping)
    final sortedRetailers = List<RetailerPrice>.from(_retailers)
      ..sort((a, b) => (a.price + a.shipping).compareTo(b.price + b.shipping));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: kLightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kMediumGray.withOpacity(0.2)),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 60, color: kMediumGray),
            ),
          ),
          const SizedBox(height: 24),

          // Best Price Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kBlack,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer, color: kWhite, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Best Price',
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'RM ${(sortedRetailers.first.price + sortedRetailers.first.shipping).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: kWhite,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'at ${sortedRetailers.first.name}',
                        style: TextStyle(
                          color: kWhite.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Retailers List
          const Text(
            'Available Retailers',
            style: TextStyle(
              color: kBlack,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedRetailers.map((retailer) => _buildRetailerCard(retailer)),
        ],
      ),
    );
  }

  Widget _buildRetailerCard(RetailerPrice retailer) {
    final totalPrice = retailer.price + retailer.shipping;
    final isCheapest =
        retailer ==
        _retailers.reduce(
          (a, b) => (a.price + a.shipping) < (b.price + b.shipping) ? a : b,
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCheapest ? kBlack : kMediumGray.withOpacity(0.2),
          width: isCheapest ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to retailer website or show more details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${retailer.name}...'),
              backgroundColor: kBlack,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Retailer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          retailer.name,
                          style: const TextStyle(
                            color: kBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCheapest) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kBlack,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CHEAPEST',
                              style: TextStyle(
                                color: kWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'RM ${retailer.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: kBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (retailer.shipping > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '+ RM ${retailer.shipping.toStringAsFixed(2)} shipping',
                            style: const TextStyle(
                              color: kMediumGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: RM ${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: kMediumGray,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: kMediumGray),
                        const SizedBox(width: 4),
                        Text(
                          retailer.rating.toString(),
                          style: const TextStyle(
                            color: kMediumGray,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: retailer.inStock ? kBlack : kMediumGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            retailer.inStock ? 'In Stock' : 'Out of Stock',
                            style: const TextStyle(
                              color: kWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward_ios, color: kMediumGray, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Lowest',
                  'RM ${_getLowestPrice().toStringAsFixed(2)}',
                  Icons.trending_down,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Highest',
                  'RM ${_getHighestPrice().toStringAsFixed(2)}',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Price History Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kMediumGray.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price Trend (Last 3 Months)',
                  style: TextStyle(
                    color: kBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(height: 250, child: LineChart(_buildChartData())),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Price History List
          const Text(
            'Price History',
            style: TextStyle(
              color: kBlack,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._priceHistory.reversed.map((point) => _buildHistoryItem(point)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kLightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kMediumGray.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kBlack, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: kMediumGray, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: kBlack,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: kMediumGray.withOpacity(0.1), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < _priceHistory.length) {
                final date = _priceHistory[value.toInt()].date;
                return Text(
                  '${date.month}/${date.day}',
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
                'RM ${value.toInt()}',
                style: const TextStyle(color: kMediumGray, fontSize: 10),
              );
            },
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: kMediumGray.withOpacity(0.2)),
      ),
      minX: 0,
      maxX: (_priceHistory.length - 1).toDouble(),
      minY: _getLowestPrice() - 1,
      maxY: _getHighestPrice() + 1,
      lineBarsData: [
        LineChartBarData(
          spots: _priceHistory.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.price);
          }).toList(),
          isCurved: true,
          color: kBlack,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: kBlack,
                strokeWidth: 2,
                strokeColor: kWhite,
              );
            },
          ),
          belowBarData: BarAreaData(show: true, color: kBlack.withOpacity(0.1)),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(PriceDataPoint point) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: kMediumGray.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${point.date.day}/${point.date.month}/${point.date.year}',
              style: const TextStyle(color: kBlack, fontSize: 14),
            ),
            Text(
              'RM ${point.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: kBlack,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compare Retailers',
            style: TextStyle(
              color: kBlack,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Comparison table would go here
          ..._retailers.map((retailer) => _buildComparisonCard(retailer)),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(RetailerPrice retailer) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              retailer.name,
              style: const TextStyle(
                color: kBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildComparisonRow(
              'Price',
              'RM ${retailer.price.toStringAsFixed(2)}',
            ),
            _buildComparisonRow(
              'Shipping',
              'RM ${retailer.shipping.toStringAsFixed(2)}',
            ),
            _buildComparisonRow(
              'Total',
              'RM ${(retailer.price + retailer.shipping).toStringAsFixed(2)}',
            ),
            _buildComparisonRow('Rating', retailer.rating.toString()),
            _buildComparisonRow(
              'Stock',
              retailer.inStock ? 'Available' : 'Out of Stock',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kMediumGray, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: kBlack,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  double _getLowestPrice() {
    return _priceHistory.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  double _getHighestPrice() {
    return _priceHistory.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  }
}

class PriceDataPoint {
  final DateTime date;
  final double price;

  PriceDataPoint({required this.date, required this.price});
}

class RetailerPrice {
  final String name;
  final double price;
  final double shipping;
  final bool inStock;
  final double rating;

  RetailerPrice({
    required this.name,
    required this.price,
    required this.shipping,
    required this.inStock,
    required this.rating,
  });
}
