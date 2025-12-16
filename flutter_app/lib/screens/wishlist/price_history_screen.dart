import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class PriceHistoryScreen extends StatefulWidget {
  const PriceHistoryScreen({super.key});

  @override
  State<PriceHistoryScreen> createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends State<PriceHistoryScreen> {
  String _selectedPeriod = '90 Days';

  // Mock price history data
  final List<PricePoint> _priceHistory = [
    PricePoint(
      date: DateTime.now().subtract(const Duration(days: 90)),
      price: 1299.00,
    ),
    PricePoint(
      date: DateTime.now().subtract(const Duration(days: 80)),
      price: 1250.00,
    ),
    PricePoint(
      date: DateTime.now().subtract(const Duration(days: 70)),
      price: 1200.00,
    ),
    PricePoint(
      date: DateTime.now().subtract(const Duration(days: 60)),
      price: 1150.00,
    ),
    PricePoint(
      date: DateTime.now().subtract(const Duration(days: 50)),
      price: 1100.00,
    ),
    PricePoint(
      date: DateTime.now().subtract(const Duration(days: 40)),
      price: 1080.00,
    ),
    PricePoint(
      date: DateTime.now().subtract(const Duration(days: 30)),
      price: 1050.00,
    ),
    PricePoint(
      date: DateTime.now().subtract(const Duration(days: 20)),
      price: 1020.00,
    ),
    PricePoint(
      date: DateTime.now().subtract(const Duration(days: 10)),
      price: 1000.00,
    ),
    PricePoint(date: DateTime.now(), price: 999.00),
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
        title: const Text(
          'Price History',
          style: TextStyle(
            color: kBlack,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
              const PopupMenuItem(value: '30 Days', child: Text('30 Days')),
              const PopupMenuItem(value: '90 Days', child: Text('90 Days')),
              const PopupMenuItem(value: '1 Year', child: Text('1 Year')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kLightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price History',
                    style: TextStyle(
                      color: kBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(color: kMediumGray, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Price Chart
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kLightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LineChart(_buildChartData()),
            ),
            const SizedBox(height: 24),

            // Price Statistics
            _buildPriceStats(),
            const SizedBox(height: 24),

            // Price History List
            const Text(
              'Price Changes',
              style: TextStyle(
                color: kBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._priceHistory.reversed.map(
              (point) => _buildPriceHistoryItem(point),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    final minPrice = _priceHistory
        .map((p) => p.price)
        .reduce((a, b) => a < b ? a : b);
    final maxPrice = _priceHistory
        .map((p) => p.price)
        .reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: priceRange / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: kMediumGray.withOpacity(0.1), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text(
                'RM ${value.toInt()}',
                style: const TextStyle(color: kMediumGray, fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
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
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: _priceHistory.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.price);
          }).toList(),
          isCurved: true,
          color: kBlack,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: kBlack.withOpacity(0.1)),
        ),
      ],
      minY: minPrice - (priceRange * 0.1),
      maxY: maxPrice + (priceRange * 0.1),
    );
  }

  Widget _buildPriceStats() {
    final currentPrice = _priceHistory.last.price;
    final highestPrice = _priceHistory
        .map((p) => p.price)
        .reduce((a, b) => a > b ? a : b);
    final lowestPrice = _priceHistory
        .map((p) => p.price)
        .reduce((a, b) => a < b ? a : b);
    final averagePrice =
        _priceHistory.map((p) => p.price).reduce((a, b) => a + b) /
        _priceHistory.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current',
            'RM ${currentPrice.toStringAsFixed(2)}',
            Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Highest',
            'RM ${highestPrice.toStringAsFixed(2)}',
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Lowest',
            'RM ${lowestPrice.toStringAsFixed(2)}',
            Icons.trending_down,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Average',
            'RM ${averagePrice.toStringAsFixed(2)}',
            Icons.show_chart,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kLightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kBlack, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: kMediumGray, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: kBlack,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHistoryItem(PricePoint point) {
    final index = _priceHistory.indexOf(point);
    final previousPrice = index > 0
        ? _priceHistory[index - 1].price
        : point.price;
    final priceChange = point.price - previousPrice;
    final isIncrease = priceChange > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: kLightGray,
      child: ListTile(
        leading: Icon(
          isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
          color: isIncrease ? kBlack : kMediumGray,
        ),
        title: Text(
          'RM ${point.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: kBlack,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${point.date.day}/${point.date.month}/${point.date.year}',
          style: const TextStyle(color: kMediumGray, fontSize: 12),
        ),
        trailing: Text(
          isIncrease
              ? '+RM ${priceChange.toStringAsFixed(2)}'
              : 'RM ${priceChange.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: isIncrease ? kBlack : kMediumGray,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class PricePoint {
  final DateTime date;
  final double price;

  PricePoint({required this.date, required this.price});
}
