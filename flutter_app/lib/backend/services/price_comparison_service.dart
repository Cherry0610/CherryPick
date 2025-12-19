import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/price.dart';
import '../models/store.dart';
import '../models/grocery_store_product.dart';
import 'grocery_store_api_service.dart';

class PriceComparisonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GroceryStoreApiService _groceryApiService = GroceryStoreApiService();

  // Search products by name or barcode
  // Now includes results from online grocery stores
  Future<List<Product>> searchProducts(String query) async {
    try {
      final List<Product> products = [];

      // 1. Search local Firestore database
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

      // Add name search results
      for (var doc in productsQuery.docs) {
        products.add(Product.fromFirestore(doc));
      }

      // Add barcode search results
      for (var doc in barcodeQuery.docs) {
        products.add(Product.fromFirestore(doc));
      }

      // 2. Search online grocery stores (Shopee, Lazada, etc.)
      try {
        final groceryProducts = await _groceryApiService.searchProducts(query);
        
        // Convert grocery store products to local Product model
        for (var groceryProduct in groceryProducts) {
          // Check if product already exists in local database
          final existingProduct = products.firstWhere(
            (p) => p.name.toLowerCase() == groceryProduct.name.toLowerCase(),
            orElse: () => Product(
              id: 'grocery_${groceryProduct.id}',
              name: groceryProduct.name,
              category: groceryProduct.category ?? 'Grocery',
              brand: groceryProduct.brand ?? '',
              description: groceryProduct.description ?? '',
              imageUrl: groceryProduct.imageUrl,
              barcode: null,
              unit: groceryProduct.unit,
              tags: [groceryProduct.storeName],
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          
          // Only add if not already in list
          if (!products.any((p) => p.id == existingProduct.id)) {
            products.add(existingProduct);
          }
        }
      } catch (e) {
        debugPrint('Error searching grocery stores: $e');
        // Continue with local results even if grocery API fails
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
  // Now includes prices from online grocery stores
  Future<Map<String, dynamic>> getPriceComparison(String productId) async {
    try {
      final product = await getProduct(productId);
      if (product == null) return {};

      // Get local Firestore prices
      final prices = await getProductPrices(productId);

      // Group prices by store
      final Map<String, List<Price>> pricesByStore = {};
      for (var price in prices) {
        if (!pricesByStore.containsKey(price.storeId)) {
          pricesByStore[price.storeId] = [];
        }
        pricesByStore[price.storeId]!.add(price);
      }

      // Get store details for local stores
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
            'source': 'local', // Mark as local database
          });
        }
      }

      // Get prices from online grocery stores
      try {
        final groceryComparison = await _groceryApiService.compareProduct(product.name);
        final groceryProducts = groceryComparison['products'] as List<GroceryStoreProduct>? ?? [];
        
        // Add grocery store prices to comparison
        for (var groceryProduct in groceryProducts) {
          storePrices.add({
            'store': Store(
              id: 'grocery_${groceryProduct.storeName.toLowerCase()}',
              name: groceryProduct.storeName,
              address: '',
              city: 'Online',
              state: 'Malaysia',
              postcode: '00000',
              type: 'online',
              latitude: 0.0,
              longitude: 0.0,
              phone: '',
              website: groceryProduct.productUrl,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            'price': Price(
              id: 'grocery_price_${groceryProduct.id}',
              productId: productId,
              storeId: 'grocery_${groceryProduct.storeName.toLowerCase()}',
              price: groceryProduct.price,
              currency: groceryProduct.currency,
              validFrom: DateTime.now(),
              validUntil: null,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            'isAvailable': groceryProduct.inStock,
            'source': 'online', // Mark as online grocery store
            'groceryProduct': groceryProduct, // Include full grocery product data
            'productUrl': groceryProduct.productUrl,
            'rating': groceryProduct.rating,
            'reviewCount': groceryProduct.reviewCount,
          });
        }
      } catch (e) {
        debugPrint('Error getting grocery store prices: $e');
        // Continue with local prices even if grocery API fails
      }

      // Sort by price (lowest first)
      storePrices.sort(
        (a, b) =>
            (a['price'] as Price).price.compareTo((b['price'] as Price).price),
      );

      // Calculate statistics
      final allPrices = storePrices.map((sp) => (sp['price'] as Price).price).toList();
      final lowestPrice = allPrices.isNotEmpty ? allPrices.first : null;
      final highestPrice = allPrices.isNotEmpty ? allPrices.last : null;
      final averagePrice = allPrices.isNotEmpty
          ? allPrices.reduce((a, b) => a + b) / allPrices.length
          : 0.0;

      return {
        'product': product,
        'prices': storePrices,
        'lowestPrice': lowestPrice != null
            ? storePrices.firstWhere((sp) => (sp['price'] as Price).price == lowestPrice)['price']
            : null,
        'highestPrice': highestPrice != null
            ? storePrices.firstWhere((sp) => (sp['price'] as Price).price == highestPrice)['price']
            : null,
        'averagePrice': averagePrice,
        'storeCount': storePrices.length,
        'onlineStoreCount': storePrices.where((sp) => sp['source'] == 'online').length,
        'localStoreCount': storePrices.where((sp) => sp['source'] == 'local').length,
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

  /// Get price comparison from online grocery stores only
  Future<Map<String, dynamic>> getGroceryStoreComparison(String productName) async {
    try {
      return await _groceryApiService.compareProduct(productName);
    } catch (e) {
      debugPrint('Error getting grocery store comparison: $e');
      return {
        'productName': productName,
        'stores': {},
        'products': [],
        'lowestPrice': null,
        'highestPrice': null,
        'averagePrice': 0.0,
        'storeCount': 0,
        'totalResults': 0,
      };
    }
  }

  /// Search products in online grocery stores only
  Future<List<GroceryStoreProduct>> searchGroceryStores(String query) async {
    try {
      return await _groceryApiService.searchProducts(query);
    } catch (e) {
      debugPrint('Error searching grocery stores: $e');
      return [];
    }
  }
}
