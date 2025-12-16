import 'package:flutter/material.dart';
import '../price_comparison/product_details_screen.dart';
import 'price_history_screen.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);
const Color kRed = Color(0xFFE53935); // For price drops

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock wishlist data
  final List<WishlistItem> _wishlistItems = [
    WishlistItem(
      id: '1',
      name: 'Sony WH-1000XM4',
      currentPrice: 1299.00,
      targetPrice: 1000.00,
      imageUrl: 'assets/onboard/prices.png',
      hasPriceDrop: false,
    ),
    WishlistItem(
      id: '2',
      name: 'Nintendo Switch',
      currentPrice: 999.00,
      targetPrice: 800.00,
      imageUrl: 'assets/onboard/list.png',
      hasPriceDrop: true,
    ),
    WishlistItem(
      id: '3',
      name: 'Instant Pot Duo',
      currentPrice: 499.00,
      targetPrice: 400.00,
      imageUrl: 'assets/onboard/receipt.png',
      hasPriceDrop: false,
    ),
    WishlistItem(
      id: '4',
      name: 'Kindle Paperwhite',
      currentPrice: 549.00,
      targetPrice: 500.00,
      imageUrl: 'assets/onboard/route.png',
      hasPriceDrop: false,
    ),
    WishlistItem(
      id: '5',
      name: 'AirPods Pro',
      currentPrice: 899.00,
      targetPrice: 750.00,
      imageUrl: 'assets/onboard/prices.png',
      hasPriceDrop: true,
    ),
    WishlistItem(
      id: '6',
      name: 'iPad Air',
      currentPrice: 2499.00,
      targetPrice: 2200.00,
      imageUrl: 'assets/onboard/list.png',
      hasPriceDrop: false,
    ),
  ];

  List<WishlistItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _wishlistItems;
    return _wishlistItems
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      // NO AppBar - removed white bar on top as requested
      body: SafeArea(
        child: Column(
          children: [
            // Simple Search Bar (NO barcode scanner)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search wishlist...',
                  prefixIcon: const Icon(Icons.search, color: kMediumGray),
                  filled: true,
                  fillColor: kLightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(color: kBlack),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Wishlist Items - Row by Row (like Taobao/Shopee)
            Expanded(
              child: _filteredItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return _buildWishlistItemRow(_filteredItems[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistItemRow(WishlistItem item) {
    final priceDifference = item.currentPrice - item.targetPrice;
    final isPriceMet = item.currentPrice <= item.targetPrice;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.hasPriceDrop ? kRed : kMediumGray.withOpacity(0.2),
          width: item.hasPriceDrop ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                productId: item.id,
                productName: item.name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: kLightGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kMediumGray.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image, size: 40, color: kMediumGray),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Current Price
                    Row(
                      children: [
                        Text(
                          'RM ${item.currentPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: item.hasPriceDrop ? kRed : kBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.hasPriceDrop) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Price Drop!',
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
                    const SizedBox(height: 4),

                    // Target Price
                    Row(
                      children: [
                        const Text(
                          'Target: ',
                          style: TextStyle(color: kMediumGray, fontSize: 12),
                        ),
                        Text(
                          'RM ${item.targetPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isPriceMet ? kRed : kBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isPriceMet) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle, size: 16, color: kRed),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Price Difference
                    if (priceDifference > 0)
                      Text(
                        'RM ${priceDifference.toStringAsFixed(2)} more to target',
                        style: const TextStyle(
                          color: kMediumGray,
                          fontSize: 11,
                        ),
                      )
                    else
                      const Text(
                        'Target price reached!',
                        style: TextStyle(
                          color: kRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: kMediumGray),
                    onPressed: () => _removeFromWishlist(item.id),
                    tooltip: 'Remove',
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: kMediumGray),
                    onPressed: () => _showItemOptions(item),
                    tooltip: 'More options',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: kMediumGray),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Your wishlist is empty' : 'No items found',
            style: const TextStyle(
              color: kBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Add products to track their prices'
                : 'Try a different search term',
            style: const TextStyle(color: kMediumGray, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _removeFromWishlist(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kWhite,
        title: const Text(
          'Remove from Wishlist?',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This item will be removed from your wishlist.',
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
                _wishlistItems.removeWhere((item) => item.id == itemId);
              });
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: kBlack)),
          ),
        ],
      ),
    );
  }

  void _showItemOptions(WishlistItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: kBlack),
              title: const Text('View Product Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(
                      productId: item.id,
                      productName: item.name,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timeline, color: kBlack),
              title: const Text('View Price History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PriceHistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: kRed),
              title: const Text(
                'Remove from Wishlist',
                style: TextStyle(color: kRed),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeFromWishlist(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistItem {
  final String id;
  final String name;
  final double currentPrice;
  final double targetPrice;
  final String imageUrl;
  final bool hasPriceDrop;

  WishlistItem({
    required this.id,
    required this.name,
    required this.currentPrice,
    required this.targetPrice,
    required this.imageUrl,
    this.hasPriceDrop = false,
  });
}
