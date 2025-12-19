import 'package:flutter/material.dart';
import '../price_comparison/search_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../money_tracker/money_tracker_overview_screen.dart';

// Black and White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SmartPrice',
                    style: TextStyle(
                      color: kBlack,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: kBlack),
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Search Bar
              _buildQuickSearchBar(context),
              const SizedBox(height: 24),

              // Quick Links Section
              _buildSectionHeader('Quick Access'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickLinkCard(
                      context,
                      icon: Icons.favorite_border,
                      title: 'Wishlist',
                      subtitle: '${_getWishlistCount()} items',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WishlistScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickLinkCard(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: 'Tracker',
                      subtitle: 'View expenses',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MoneyTrackerOverviewScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Trending Deals Section
              _buildSectionHeader('Trending Deals'),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _getTrendingDeals().length,
                  itemBuilder: (context, index) {
                    final deal = _getTrendingDeals()[index];
                    return _buildDealCard(context, deal);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Recent Searches (Optional)
              _buildSectionHeader('Recent Searches'),
              const SizedBox(height: 12),
              _buildRecentSearches(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSearchBar(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: kLightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kMediumGray, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: kMediumGray, size: 24),
            const SizedBox(width: 12),
            Text(
              'Search for products...',
              style: TextStyle(color: kMediumGray, fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.camera_alt_outlined, color: kMediumGray, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: kBlack,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuickLinkCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kLightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kMediumGray, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kBlack, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: kBlack,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: kMediumGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, Deal deal) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: kLightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kMediumGray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kMediumGray,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(Icons.shopping_bag, color: kWhite, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.productName,
                  style: const TextStyle(
                    color: kBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      deal.originalPrice,
                      style: TextStyle(
                        color: kMediumGray,
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      deal.discountPrice,
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: kBlack,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${deal.discount}% OFF',
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final recentSearches = ['Milk', 'Eggs', 'Bread', 'Chicken'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: recentSearches.map((search) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kLightGray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kMediumGray, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history, color: kMediumGray, size: 16),
                const SizedBox(width: 6),
                Text(
                  search,
                  style: const TextStyle(color: kBlack, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  int _getWishlistCount() {
    // TODO: Get actual count from wishlist service
    return 5;
  }

  List<Deal> _getTrendingDeals() {
    // TODO: Get actual deals from API
    return [
      Deal(
        productName: 'Fresh Milk 1L',
        originalPrice: 'RM 8.90',
        discountPrice: 'RM 6.90',
        discount: 22,
      ),
      Deal(
        productName: 'Free Range Eggs',
        originalPrice: 'RM 12.90',
        discountPrice: 'RM 9.90',
        discount: 23,
      ),
      Deal(
        productName: 'Whole Wheat Bread',
        originalPrice: 'RM 4.50',
        discountPrice: 'RM 3.50',
        discount: 22,
      ),
    ];
  }
}

class Deal {
  final String productName;
  final String originalPrice;
  final String discountPrice;
  final int discount;

  Deal({
    required this.productName,
    required this.originalPrice,
    required this.discountPrice,
    required this.discount,
  });
}
