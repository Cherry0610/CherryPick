import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/price.dart';

/// Service for tracking and retrieving price history
class PriceHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get price history for a product
  Future<List<Price>> getPriceHistory(
    String productId, {
    DateTime? startDate,
    DateTime? endDate,
    String? storeId,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore
          .collection('prices')
          .where('productId', isEqualTo: productId)
          .where('isActive', isEqualTo: true)
          .orderBy('validFrom', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where(
          'validFrom',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'validFrom',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (storeId != null) {
        query = query.where('storeId', isEqualTo: storeId);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Price.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ Error getting price history: $e');
      return [];
    }
  }

  /// Get price history grouped by store
  Future<Map<String, List<Price>>> getPriceHistoryByStore(String productId) async {
    try {
      final prices = await getPriceHistory(productId);
      final Map<String, List<Price>> pricesByStore = {};

      for (var price in prices) {
        if (!pricesByStore.containsKey(price.storeId)) {
          pricesByStore[price.storeId] = [];
        }
        pricesByStore[price.storeId]!.add(price);
      }

      return pricesByStore;
    } catch (e) {
      debugPrint('❌ Error getting price history by store: $e');
      return {};
    }
  }

  /// Get price statistics for a product
  Future<Map<String, dynamic>> getPriceStatistics(String productId) async {
    try {
      final prices = await getPriceHistory(productId);

      if (prices.isEmpty) {
        return {
          'lowestPrice': 0.0,
          'highestPrice': 0.0,
          'averagePrice': 0.0,
          'currentPrice': 0.0,
          'priceChange': 0.0,
          'priceChangePercent': 0.0,
          'dataPoints': 0,
        };
      }

      final priceValues = prices.map((p) => p.price).toList();
      final lowestPrice = priceValues.reduce((a, b) => a < b ? a : b);
      final highestPrice = priceValues.reduce((a, b) => a > b ? a : b);
      final averagePrice = priceValues.reduce((a, b) => a + b) / priceValues.length;
      final currentPrice = prices.first.price; // Most recent

      // Calculate price change (current vs oldest)
      final oldestPrice = prices.last.price;
      final priceChange = currentPrice - oldestPrice;
      final priceChangePercent = oldestPrice > 0
          ? ((priceChange / oldestPrice) * 100)
          : 0.0;

      return {
        'lowestPrice': lowestPrice,
        'highestPrice': highestPrice,
        'averagePrice': averagePrice,
        'currentPrice': currentPrice,
        'priceChange': priceChange,
        'priceChangePercent': priceChangePercent,
        'dataPoints': prices.length,
        'trend': priceChange > 0 ? 'increasing' : priceChange < 0 ? 'decreasing' : 'stable',
      };
    } catch (e) {
      debugPrint('❌ Error getting price statistics: $e');
      return {};
    }
  }

  /// Get price history chart data (for fl_chart)
  Future<List<FlSpot>> getPriceHistoryChartData(
    String productId, {
    DateTime? startDate,
    DateTime? endDate,
    String? storeId,
  }) async {
    try {
      final prices = await getPriceHistory(
        productId,
        startDate: startDate,
        endDate: endDate,
        storeId: storeId,
      );

      if (prices.isEmpty) return [];

      // Sort by date (oldest first for chart)
      prices.sort((a, b) => a.validFrom.compareTo(b.validFrom));

      // Convert to FlSpot format (x = index, y = price)
      return prices.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.price);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting price history chart data: $e');
      return [];
    }
  }

  /// Get price trends (last 30 days)
  Future<Map<String, dynamic>> getPriceTrends(String productId) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final prices = await getPriceHistory(
        productId,
        startDate: startDate,
        endDate: endDate,
      );

      if (prices.isEmpty) {
        return {
          'trend': 'no_data',
          'change': 0.0,
          'changePercent': 0.0,
        };
      }

      // Group by day
      final Map<String, List<double>> pricesByDay = {};
      for (var price in prices) {
        final dayKey = '${price.validFrom.year}-${price.validFrom.month}-${price.validFrom.day}';
        if (!pricesByDay.containsKey(dayKey)) {
          pricesByDay[dayKey] = [];
        }
        pricesByDay[dayKey]!.add(price.price);
      }

      // Calculate average price per day
      final dailyAverages = pricesByDay.map((key, values) {
        final avg = values.reduce((a, b) => a + b) / values.length;
        return MapEntry(key, avg);
      });

      final sortedDays = dailyAverages.keys.toList()..sort();
      if (sortedDays.length < 2) {
        return {
          'trend': 'insufficient_data',
          'change': 0.0,
          'changePercent': 0.0,
        };
      }

      final firstDayPrice = dailyAverages[sortedDays.first]!;
      final lastDayPrice = dailyAverages[sortedDays.last]!;
      final change = lastDayPrice - firstDayPrice;
      final changePercent = firstDayPrice > 0
          ? ((change / firstDayPrice) * 100)
          : 0.0;

      return {
        'trend': change > 0 ? 'increasing' : change < 0 ? 'decreasing' : 'stable',
        'change': change,
        'changePercent': changePercent,
        'firstPrice': firstDayPrice,
        'lastPrice': lastDayPrice,
        'days': sortedDays.length,
      };
    } catch (e) {
      debugPrint('❌ Error getting price trends: $e');
      return {};
    }
  }
}

