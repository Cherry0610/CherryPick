import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'grocery_store_api_service.dart';
import '../models/grocery_store_product.dart';
import 'unified_grocery_catalog_service.dart';

/// Service for recommending products based on user history
class UserRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UnifiedGroceryCatalogService _catalogService = UnifiedGroceryCatalogService();
  final GroceryStoreApiService _groceryService = GroceryStoreApiService();

  /// Get recommended products based on user history
  Future<List<UnifiedProduct>> getRecommendedProducts(String userId, {int limit = 12}) async {
    try {
      // Get user's search history
      final searchHistory = await _getUserSearchHistory(userId);
      
      // Get user's purchase history (from expenses/receipts)
      final purchaseHistory = await _getUserPurchaseHistory(userId);
      
      // Get user's wishlist items
      final wishlistItems = await _getUserWishlistItems(userId);
      
      // Combine all history to get keywords
      final Set<String> keywords = {};
      
      // Add keywords from search history
      for (var search in searchHistory) {
        final query = search['query'] as String? ?? '';
        if (query.isNotEmpty) {
          keywords.addAll(query.toLowerCase().split(' ').where((w) => w.length > 2));
        }
      }
      
      // Add keywords from purchase history
      for (var purchase in purchaseHistory) {
        final description = purchase['description'] as String? ?? '';
        if (description.isNotEmpty) {
          keywords.addAll(description.toLowerCase().split(' ').where((w) => w.length > 2));
        }
      }
      
      // Add keywords from wishlist
      for (var item in wishlistItems) {
        final productName = item['productName'] as String? ?? '';
        if (productName.isNotEmpty) {
          keywords.addAll(productName.toLowerCase().split(' ').where((w) => w.length > 2));
        }
      }
      
      // If no history, use popular items
      if (keywords.isEmpty) {
        return await _catalogService.getTrendingProducts(limit: limit);
      }
      
      // Search for products based on keywords
      final List<GroceryStoreProduct> allProducts = [];
      final uniqueKeywords = keywords.take(10).toList(); // Limit to 10 keywords
      
      for (var keyword in uniqueKeywords) {
        try {
          final products = await _groceryService.searchProducts(keyword);
          allProducts.addAll(products);
        } catch (e) {
          debugPrint('Error searching for $keyword: $e');
        }
      }
      
      // Create unified products and shuffle for variety
      final unifiedProducts = await _catalogService.browseAllProducts(limit: limit * 2);
      
      // Shuffle to show different products on refresh
      unifiedProducts.shuffle();
      
      return unifiedProducts.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting recommended products: $e');
      // Fallback to trending products
      return await _catalogService.getTrendingProducts(limit: limit);
    }
  }

  /// Get user's search history
  Future<List<Map<String, dynamic>>> _getUserSearchHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_search_history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error getting search history: $e');
      return [];
    }
  }

  /// Get user's purchase history from expenses
  Future<List<Map<String, dynamic>>> _getUserPurchaseHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(30)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error getting purchase history: $e');
      return [];
    }
  }

  /// Get user's wishlist items
  Future<List<Map<String, dynamic>>> _getUserWishlistItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(20)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error getting wishlist items: $e');
      return [];
    }
  }

  /// Save user search to history
  Future<void> saveSearchHistory(String userId, String query) async {
    try {
      await _firestore.collection('user_search_history').add({
        'userId': userId,
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }
}

