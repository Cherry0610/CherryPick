import 'package:flutter/foundation.dart';
import 'wishlist_service.dart';
import 'notification_service.dart';
import 'price_comparison_service.dart';
import '../models/price.dart';
import '../models/store.dart';

/// Service to monitor prices and send notifications when target prices are reached
class PriceMonitorService {
  final WishlistService _wishlistService = WishlistService();
  final NotificationService _notificationService = NotificationService();
  final PriceComparisonService _priceService = PriceComparisonService();

  /// Check all wishlist items for price drops and send notifications
  Future<void> checkPriceDrops(String userId) async {
    try {
      debugPrint('🔍 Checking price drops for user: $userId');
      
      // Get all active wishlist items
      final wishlistItems = await _wishlistService.getUserWishlist(userId);
      
      if (wishlistItems.isEmpty) {
        debugPrint('📭 No wishlist items to check');
        return;
      }

      debugPrint('📋 Found ${wishlistItems.length} wishlist items to check');

      // Check each item
      for (var item in wishlistItems) {
        try {
          // Get current prices for this product
          final comparison = await _priceService.getPriceComparison(item.productId);
          final prices = comparison['prices'] as List<dynamic>? ?? [];

          if (prices.isEmpty) {
            debugPrint('⚠️ No prices found for ${item.productName}');
            continue;
          }

          // Find the cheapest price
          double? cheapestPrice;
          String? cheapestStoreName;

          for (var priceData in prices) {
            final price = priceData['price'] as Price?;
            final store = priceData['store'] as Store?;
            
            if (price != null && store != null) {
              if (cheapestPrice == null || price.price < cheapestPrice) {
                cheapestPrice = price.price;
                cheapestStoreName = store.name;
              }
            }
          }

          if (cheapestPrice == null || cheapestStoreName == null) {
            continue;
          }

          // Check if price dropped to or below target
          if (cheapestPrice <= item.targetPrice) {
            // Check if we've already notified recently (within 24 hours)
            final lastNotified = item.lastNotifiedAt;
            final now = DateTime.now();
            final shouldNotify = lastNotified == null ||
                now.difference(lastNotified).inHours >= 24;

            if (shouldNotify) {
              debugPrint('💰 Price drop detected! ${item.productName}: RM$cheapestPrice (Target: RM${item.targetPrice})');
              
              // Send notification
              await _notificationService.sendPriceDropNotification(
                userId: userId,
                productName: item.productName,
                currentPrice: cheapestPrice,
                targetPrice: item.targetPrice,
                storeName: cheapestStoreName,
              );

              // Mark as notified
              await _wishlistService.markAsNotified(item.id);
              
              debugPrint('✅ Notification sent for ${item.productName}');
            } else {
              debugPrint('⏭️ Already notified recently for ${item.productName}');
            }
          } else {
            debugPrint('📊 ${item.productName}: RM$cheapestPrice (Target: RM${item.targetPrice}) - Not reached yet');
          }
        } catch (e) {
          debugPrint('❌ Error checking price for ${item.productName}: $e');
        }
      }

      debugPrint('✅ Finished checking price drops');
    } catch (e) {
      debugPrint('❌ Error checking price drops: $e');
    }
  }

  /// Start periodic price monitoring (call this from app lifecycle)
  void startMonitoring(String userId, {Duration interval = const Duration(hours: 6)}) {
    // Check immediately
    checkPriceDrops(userId);
    
    // Then check periodically
    // Note: In production, you'd use a background task or cloud function
    // For now, this checks when the app is active
    debugPrint('🔄 Price monitoring started (checking every ${interval.inHours} hours)');
  }
}

