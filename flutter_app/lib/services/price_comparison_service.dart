import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/price.dart';
import '../models/store.dart';

class PriceComparisonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search products by name or barcode
  Future<List<Product>> searchProducts(String query) async {
    try {
      final productsQuery = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(20)
          .get();

      final barcodeQuery = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('barcode', isEqualTo: query)
          .limit(5)
          .get();

      final List<Product> products = [];

      // Add name search results
      for (var doc in productsQuery.docs) {
        products.add(Product.fromFirestore(doc));
      }

      // Add barcode search results
      for (var doc in barcodeQuery.docs) {
        products.add(Product.fromFirestore(doc));
      }

      return products;
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // Get current prices for a product across all stores
  Future<List<Price>> getProductPrices(String productId) async {
    try {
      final query = await _firestore
          .collection('prices')
          .where('productId', isEqualTo: productId)
          .where('isActive', isEqualTo: true)
          .where('validFrom', isLessThanOrEqualTo: Timestamp.now())
          .orderBy('validFrom', descending: true)
          .limit(50)
          .get();

      return query.docs.map((doc) => Price.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting product prices: $e');
      return [];
    }
  }

  // Get price comparison for a product
  Future<Map<String, dynamic>> getPriceComparison(String productId) async {
    try {
      final prices = await getProductPrices(productId);
      final product = await getProduct(productId);

      if (product == null) return {};

      // Group prices by store
      final Map<String, List<Price>> pricesByStore = {};
      for (var price in prices) {
        if (!pricesByStore.containsKey(price.storeId)) {
          pricesByStore[price.storeId] = [];
        }
        pricesByStore[price.storeId]!.add(price);
      }

      // Get store details
      final List<Map<String, dynamic>> storePrices = [];
      for (var storeId in pricesByStore.keys) {
        final store = await getStore(storeId);
        if (store != null) {
          final storePriceList = pricesByStore[storeId]!;
          final currentPrice = storePriceList.first; // Most recent price

          storePrices.add({
            'store': store,
            'price': currentPrice,
            'isAvailable': true,
          });
        }
      }

      // Sort by price
      storePrices.sort(
        (a, b) =>
            (a['price'] as Price).price.compareTo((b['price'] as Price).price),
      );

      return {
        'product': product,
        'prices': storePrices,
        'lowestPrice': storePrices.isNotEmpty
            ? storePrices.first['price']
            : null,
        'highestPrice': storePrices.isNotEmpty
            ? storePrices.last['price']
            : null,
        'averagePrice': storePrices.isNotEmpty
            ? storePrices
                      .map((sp) => (sp['price'] as Price).price)
                      .reduce((a, b) => a + b) /
                  storePrices.length
            : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting price comparison: $e');
      return {};
    }
  }

  // Get product by ID
  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  // Get store by ID
  Future<Store?> getStore(String storeId) async {
    try {
      final doc = await _firestore.collection('stores').doc(storeId).get();
      if (doc.exists) {
        return Store.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting store: $e');
      return null;
    }
  }

  // Get all active stores
  Future<List<Store>> getAllStores() async {
    try {
      final query = await _firestore
          .collection('stores')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs.map((doc) => Store.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting stores: $e');
      return [];
    }
  }

  // Get nearby stores based on location
  Future<List<Store>> getNearbyStores(
    double latitude,
    double longitude, {
    double radiusKm = 10.0,
  }) async {
    try {
      // This is a simplified version - in production, you'd use GeoFlutterFire
      // or implement proper geospatial queries
      final stores = await getAllStores();

      return stores.where((store) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          store.latitude,
          store.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      debugPrint('Error getting nearby stores: $e');
      return [];
    }
  }

  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Add new price (for manual entry or receipt processing)
  Future<void> addPrice(Price price) async {
    try {
      await _firestore.collection('prices').add(price.toFirestore());
    } catch (e) {
      debugPrint('Error adding price: $e');
      throw Exception('Failed to add price');
    }
  }

  // Update existing price
  Future<void> updatePrice(String priceId, Price price) async {
    try {
      await _firestore
          .collection('prices')
          .doc(priceId)
          .update(price.toFirestore());
    } catch (e) {
      debugPrint('Error updating price: $e');
      throw Exception('Failed to update price');
    }
  }
}
