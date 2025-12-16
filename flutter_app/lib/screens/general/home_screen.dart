import 'package:flutter/material.dart';
// NOTE: Ensure these files exist in your project structure
import '../price_comparison/search_screen.dart';
import '../map/nearby_store_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'profile_screen.dart';
import '../money_tracker/receipts_screen.dart'; // Used for the FAB action
import '../wishlist/notifications_log_screen.dart';
import '../price_comparison/product_details_screen.dart';

// --- Constants (reused from previous screens) ---
const Color accentColor = Color(0xFF6DE4E0);
const Color darkCardColor = Color(0xFF1E1E1E);

// --- Home Screen Container (Handles State and Navigation) ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Current index: 0=Home, 1=Stores, 2=FAB Action (No widget), 3=Wishlist, 4=Profile
  int _selectedIndex = 0;

  // FIX: The widget list should only contain the screens linked to the bottom bar indices (0, 1, 3, 4).
  static final List<Widget> _widgetOptions = <Widget>[
    const _HomeContent(), // Index 0: Home Feed
    const StoresScreen(), // Index 1: Stores
    // Index 2 is intentionally skipped here, as it's the FAB trigger
    const WishlistScreen(), // Index 3: Wishlist (Actual list index 2)
    const ProfileScreen(), // Index 4: Profile (Actual list index 3)
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // FIX: Change ReceiptsScreen() to ReceiptDetailsScreen()
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReceiptDetailsScreen()),
      );
      debugPrint(
        'FAB Scan Action Triggered! Navigating to ReceiptDetailsScreen.',
      );
    } else {
      // Navigate to the screen widget stored in _widgetOptions
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Custom Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return BottomAppBar(
      color: Colors.black,
      height: 75.0,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavBarItem(Icons.home, 'Home', 0),
          _buildNavBarItem(Icons.storefront, 'Stores', 1),
          const SizedBox(width: 40), // Space for the FAB
          _buildNavBarItem(Icons.favorite_border, 'Wishlist', 3),
          _buildNavBarItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index) {
    // Determine the icon and color based on the actual index.
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? accentColor : Colors.white70;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Simplified icon logic for cleaner code
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Correctly map the navigation index (0, 1, 3, 4) to the list index (0, 1, 2, 3)
    int actualBodyIndex;
    if (_selectedIndex < 2) {
      actualBodyIndex = _selectedIndex; // 0 maps to 0, 1 maps to 1
    } else {
      actualBodyIndex = _selectedIndex - 1; // 3 maps to 2, 4 maps to 3
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // Use the calculated index to display the correct screen content
      body: _widgetOptions.elementAt(actualBodyIndex),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(),

      // Floating Action Button (Scan Receipt)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(2); // Triggers the FAB action/navigation
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4.0,
        child: const Icon(Icons.qr_code_scanner, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// --- Original Home Screen Content (Refactored) ---

class Deal {
  final String title;
  final String price;
  final String imageUrl;
  final Color backgroundColor;
  const Deal({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.backgroundColor,
  });
}

// Dummy data using existing assets
const List<Deal> trendingDeals = [
  Deal(
    title: 'Galaxy S24',
    price: 'RM3,499',
    imageUrl: 'assets/onboard/receipt.png',
    backgroundColor: Color(0xFF6DE4E0),
  ),
  Deal(
    title: 'Running Shoes',
    price: 'RM199',
    imageUrl: 'assets/onboard/route.png',
    backgroundColor: Color(0xFFE8E8E8),
  ),
];
const List<Deal> forYouDeals = [
  Deal(
    title: 'Sony ZV-1',
    price: 'RM250',
    imageUrl: 'assets/onboard/prices.png',
    backgroundColor: Color(0xFF8D8D8D),
  ),
  Deal(
    title: 'Xiaomi SmartWatch..',
    price: 'RM899',
    imageUrl: 'assets/onboard/list.png',
    backgroundColor: Color(0xFF666666),
  ),
];

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildAppBarHeader(context),
            const SizedBox(height: 20),
            _buildSearchBar(context),
            const SizedBox(height: 30),
            _buildSectionTitle('Trending Deals ⚡'),
            const SizedBox(height: 15),
            _buildDealRow(context, trendingDeals),
            const SizedBox(height: 40),
            _buildSectionTitle('For You'),
            const SizedBox(height: 15),
            _buildDealRow(context, forYouDeals),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: () {
          // FIX: Correctly navigate to the SearchScreen when the bar is tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: IgnorePointer(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                hintText: 'Search for products, stores, or brands',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Remaining _HomeContent Widgets (buildAppBarHeader, buildSectionTitle, buildDealRow, buildDealCard) ---

  Widget _buildAppBarHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white70,
            child: Icon(Icons.person, color: Colors.black54),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Text(
                'Welcome Back, Cherry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 28,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDealRow(BuildContext context, List<Deal> deals) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (deals.isNotEmpty)
            Expanded(child: _buildDealCard(context, deals[0])),
          if (deals.length > 1) const SizedBox(width: 15),
          if (deals.length > 1)
            Expanded(child: _buildDealCard(context, deals[1])),
        ],
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, Deal deal) {
    return Container(
      decoration: BoxDecoration(
        color: darkCardColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                productId: 'deal-${deal.title}',
                productName: deal.title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: deal.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
              child: Center(
                child: Image.asset(
                  deal.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Return a fallback icon without throwing errors
                    return Icon(
                      deal.title.contains('Shoes')
                          ? Icons.directions_walk
                          : deal.title.contains('Watch')
                          ? Icons.watch
                          : deal.title.contains('Sony')
                          ? Icons.headphones
                          : Icons.shopping_bag,
                      color: Colors.black54,
                      size: 60,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'from ${deal.price}',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
