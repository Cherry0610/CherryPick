import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../price_comparison/product_details_screen.dart';
import 'notifications_log_screen.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../../backend/services/wishlist_service.dart';
import '../../../backend/models/product.dart';
import '../../../backend/models/price.dart';

// Figma Design Colors
const Color kWishlistRed = Color(0xFFE85D5D);
const Color kWishlistRedLight = Color(0xFFF28D7F);
const Color kWishlistWhite = Color(0xFFFFFFFF);
const Color kWishlistBackground = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBorderGray = Color(0xFFE5E7EB);

// Wishlist Item Model
class WishlistItem {
  final String id;
  final String name;
  final String image;
  final double currentPrice;
  final double targetPrice;
  final double priceChange;
  final bool alertActive;
  final String lastChecked;

  WishlistItem({
    required this.id,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.targetPrice,
    required this.priceChange,
    required this.alertActive,
    required this.lastChecked,
  });
}

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  List<WishlistItem> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _wishlistItems = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final backendItems = await _wishlistService.getUserWishlist(user.uid);
      
      // Convert backend wishlist items to UI wishlist items
      final List<WishlistItem> uiItems = [];
      
      for (var backendItem in backendItems) {
        // Get product details and current price
        final itemWithPrice = await _wishlistService.getWishlistItemWithPrice(backendItem.id);
        
        if (itemWithPrice != null) {
          final product = itemWithPrice['product'] as Product?;
          final lowestPrice = itemWithPrice['lowestPrice'] as Price?;
          
          final currentPrice = lowestPrice?.price ?? backendItem.targetPrice;
          final priceChange = currentPrice - backendItem.targetPrice;
          
          uiItems.add(WishlistItem(
            id: backendItem.id,
            name: product?.name ?? backendItem.productName,
            image: product?.imageUrl ?? backendItem.productImageUrl ?? '',
            currentPrice: currentPrice,
            targetPrice: backendItem.targetPrice,
            priceChange: priceChange,
            alertActive: true, // Default to true, can be managed separately
            lastChecked: _formatLastChecked(backendItem.updatedAt),
          ));
        } else {
          // Fallback if itemWithPrice is null
          uiItems.add(WishlistItem(
            id: backendItem.id,
            name: backendItem.productName,
            image: backendItem.productImageUrl ?? '',
            currentPrice: backendItem.targetPrice,
            targetPrice: backendItem.targetPrice,
            priceChange: 0.0,
            alertActive: true,
            lastChecked: _formatLastChecked(backendItem.updatedAt),
          ));
        }
      }
      
      setState(() {
        _wishlistItems = uiItems;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
      setState(() {
        _wishlistItems = [];
        _isLoading = false;
      });
    }
  }

  String _formatLastChecked(DateTime? dateTime) {
    if (dateTime == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Future<void> _removeItem(String id) async {
    try {
      await _wishlistService.removeFromWishlist(id);
      await _loadWishlist(); // Reload wishlist
    } catch (e) {
      debugPrint('Error removing wishlist item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing item: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleAlert(String id) async {
    // Toggle alert state in UI only for now
    // Backend model doesn't have isAlertActive field yet
    setState(() {
      _wishlistItems = _wishlistItems.map((item) {
        if (item.id == id) {
          return WishlistItem(
            id: item.id,
            name: item.name,
            image: item.image,
            currentPrice: item.currentPrice,
            targetPrice: item.targetPrice,
            priceChange: item.priceChange,
            alertActive: !item.alertActive,
            lastChecked: item.lastChecked,
          );
        }
        return item;
      }).toList();
    });
  }

  void _onProductClick(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: productId,
          productName: 'Product',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeAlerts = _wishlistItems.where((item) => item.alertActive).length;

    return Scaffold(
      backgroundColor: kWishlistBackground,
      appBar: AppBar(
        backgroundColor: kWishlistWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Wishlist & Price Alerts',
          style: TextStyle(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: kTextLight),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kWishlistRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsLogScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    _buildSummaryCard(activeAlerts),
                    const SizedBox(height: 16),

                    // Wishlist Items
                    if (_wishlistItems.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Wishlist (${_wishlistItems.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Remove all items from wishlist
                        for (var item in _wishlistItems) {
                          try {
                            await _wishlistService.removeFromWishlist(item.id);
                          } catch (e) {
                            debugPrint('Error removing item ${item.id}: $e');
                          }
                        }
                        await _loadWishlist(); // Reload wishlist
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          color: kWishlistRed,
                          fontSize: 14,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._wishlistItems.map((item) => _buildWishlistItem(item)),
              ] else ...[
                _buildEmptyState(),
              ],
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildSummaryCard(int activeAlerts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kWishlistRed, kWishlistRedLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Price Alerts',
                style: TextStyle(
                  color: kWishlistWhite.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activeAlerts.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kWishlistWhite,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You\'ll be notified when prices drop below your target',
                style: TextStyle(
                  color: kWishlistWhite.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          const Icon(
            Icons.notifications_active,
            size: 32,
            color: kWishlistWhite,
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(WishlistItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              GestureDetector(
                onTap: () => _onProductClick(item.id),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kWishlistBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 40),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _onProductClick(item.id),
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kTextDark,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'RM${item.currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kWishlistRed,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.priceChange < 0
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.priceChange < 0
                                    ? Icons.trending_down
                                    : Icons.trending_up,
                                size: 12,
                                color: item.priceChange < 0
                                    ? Colors.green[600]
                                    : Colors.red[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.priceChange.abs().toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: item.priceChange < 0
                                      ? Colors.green[600]
                                      : Colors.red[600],
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target: RM${item.targetPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextLight,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            Text(
                              'Updated ${item.lastChecked}',
                              style: TextStyle(
                                fontSize: 10,
                                color: kTextLight.withValues(alpha: 0.7),
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _toggleAlert(item.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: item.alertActive
                                  ? kWishlistRed
                                  : kWishlistBackground,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  size: 12,
                                  color: item.alertActive
                                      ? kWishlistWhite
                                      : kTextLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.alertActive ? 'Alert ON' : 'Alert OFF',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: item.alertActive
                                        ? kWishlistWhite
                                        : kTextLight,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Remove button
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _removeItem(item.id),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: kWishlistBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: kTextLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_border,
            size: 64,
            color: kTextLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding products to track their prices',
            style: TextStyle(
              color: kTextLight,
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kWishlistRed,
              foregroundColor: kWishlistWhite,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Browse Products',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
