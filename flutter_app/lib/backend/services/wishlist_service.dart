import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/wishlist_item.dart';
import '../models/product.dart';
import '../models/price.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add item to wishlist
  Future<void> addToWishlist(WishlistItem wishlistItem) async {
    try {
      await _firestore.collection('wishlists').add(wishlistItem.toFirestore());
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      throw Exception('Failed to add item to wishlist');
    }
  }

  // Get user's wishlist
  Future<List<WishlistItem>> getUserWishlist(String userId) async {
    try {
      final query = await _firestore
          .collection('wishlists')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => WishlistItem.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting wishlist: $e');
      return [];
    }
  }

  // Update wishlist item
  Future<void> updateWishlistItem(WishlistItem wishlistItem) async {
    try {
      await _firestore
          .collection('wishlists')
          .doc(wishlistItem.id)
          .update(wishlistItem.toFirestore());
    } catch (e) {
      debugPrint('Error updating wishlist item: $e');
      throw Exception('Failed to update wishlist item');
    }
  }

  // Remove item from wishlist
  Future<void> removeFromWishlist(String wishlistItemId) async {
    try {
      await _firestore.collection('wishlists').doc(wishlistItemId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      throw Exception('Failed to remove item from wishlist');
    }
  }

  // Check for price drops and send notifications
  Future<List<WishlistItem>> checkPriceDrops(String userId) async {
    try {
      final wishlistItems = await getUserWishlist(userId);
      final List<WishlistItem> priceDrops = [];

      for (var item in wishlistItems) {
        // Get current prices for the product
        final pricesQuery = await _firestore
            .collection('prices')
            .where('productId', isEqualTo: item.productId)
            .where('isActive', isEqualTo: true)
            .where('validFrom', isLessThanOrEqualTo: Timestamp.now())
            .orderBy('validFrom', descending: true)
            .limit(1)
            .get();

        if (pricesQuery.docs.isNotEmpty) {
          final currentPrice = Price.fromFirestore(pricesQuery.docs.first);

          // Check if current price is below target price
          if (currentPrice.price <= item.targetPrice) {
            // Check if we haven't notified recently (within 24 hours)
            final lastNotified = item.lastNotifiedAt;
            final now = DateTime.now();

            if (lastNotified == null ||
                now.difference(lastNotified).inHours >= 24) {
              priceDrops.add(item);
            }
          }
        }
      }

      return priceDrops;
    } catch (e) {
      debugPrint('Error checking price drops: $e');
      return [];
    }
  }

  // Get wishlist item with current price info
  Future<Map<String, dynamic>?> getWishlistItemWithPrice(
    String wishlistItemId,
  ) async {
    try {
      final doc = await _firestore
          .collection('wishlists')
          .doc(wishlistItemId)
          .get();
      if (!doc.exists) return null;

      final wishlistItem = WishlistItem.fromFirestore(doc);

      // Get current prices
      final pricesQuery = await _firestore
          .collection('prices')
          .where('productId', isEqualTo: wishlistItem.productId)
          .where('isActive', isEqualTo: true)
          .where('validFrom', isLessThanOrEqualTo: Timestamp.now())
          .orderBy('validFrom', descending: true)
          .limit(10)
          .get();

      final prices = pricesQuery.docs
          .map((doc) => Price.fromFirestore(doc))
          .toList();

      // Get product details
      final productDoc = await _firestore
          .collection('products')
          .doc(wishlistItem.productId)
          .get();
      Product? product;
      if (productDoc.exists) {
        product = Product.fromFirestore(productDoc);
      }

      return {
        'wishlistItem': wishlistItem,
        'product': product,
        'currentPrices': prices,
        'lowestPrice': prices.isNotEmpty ? prices.first : null,
        'isTargetReached':
            prices.isNotEmpty && prices.first.price <= wishlistItem.targetPrice,
      };
    } catch (e) {
      debugPrint('Error getting wishlist item with price: $e');
      return null;
    }
  }

  // Get wishlist statistics
  Future<Map<String, dynamic>> getWishlistStats(String userId) async {
    try {
      final wishlistItems = await getUserWishlist(userId);

      if (wishlistItems.isEmpty) {
        return {
          'totalItems': 0,
          'targetReached': 0,
          'averageTargetPrice': 0.0,
          'totalPotentialSavings': 0.0,
        };
      }

      int targetReached = 0;
      double totalPotentialSavings = 0.0;

      for (var item in wishlistItems) {
        // Get current lowest price
        final pricesQuery = await _firestore
            .collection('prices')
            .where('productId', isEqualTo: item.productId)
            .where('isActive', isEqualTo: true)
            .where('validFrom', isLessThanOrEqualTo: Timestamp.now())
            .orderBy('validFrom', descending: true)
            .limit(1)
            .get();

        if (pricesQuery.docs.isNotEmpty) {
          final currentPrice = Price.fromFirestore(pricesQuery.docs.first);

          if (currentPrice.price <= item.targetPrice) {
            targetReached++;
          }

          if (currentPrice.price < item.targetPrice) {
            totalPotentialSavings += (item.targetPrice - currentPrice.price);
          }
        }
      }

      final averageTargetPrice =
          wishlistItems.fold(0.0, (runningTotal, item) => runningTotal + item.targetPrice) /
          wishlistItems.length;

      return {
        'totalItems': wishlistItems.length,
        'targetReached': targetReached,
        'averageTargetPrice': averageTargetPrice,
        'totalPotentialSavings': totalPotentialSavings,
      };
    } catch (e) {
      debugPrint('Error getting wishlist stats: $e');
      return {};
    }
  }

  // Mark item as notified (after sending notification)
  Future<void> markAsNotified(String wishlistItemId) async {
    try {
      await _firestore.collection('wishlists').doc(wishlistItemId).update({
        'lastNotifiedAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error marking as notified: $e');
      throw Exception('Failed to mark as notified');
    }
  }
}








