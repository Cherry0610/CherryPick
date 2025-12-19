import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/general/home_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/money_tracker/money_tracker_overview_screen.dart';
import '../screens/map/nearby_store_screen.dart';
import '../screens/general/profile_screen.dart';

// Figma Design Colors
const Color kHomeRed = Color(0xFFE85D5D);
const Color kHomeWhite = Color(0xFFFFFFFF);
const Color kTextLight = Color(0xFF808080);
const Color kBorderGray = Color(0xFFE5E7EB);

/// Reusable bottom navigation bar widget
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kHomeWhite,
        border: Border(top: BorderSide(color: kBorderGray)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        top: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.shopping_bag, 'Deals', 0),
          _buildNavItem(context, Icons.favorite_border, 'Wishlist', 1),
          _buildNavItem(context, Icons.bar_chart, 'Expenses', 2),
          _buildNavItem(context, Icons.store, 'Stores', 3),
          _buildNavItem(context, Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? kHomeRed : kTextLight, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? kHomeRed : kTextLight,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    // Don't navigate if already on the selected screen
    if (currentIndex == index) return;

    // Check if user is guest
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user == null || user.isAnonymous;

    switch (index) {
      case 0: // Deals (Home)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1: // Wishlist - requires authentication
        if (isGuest) {
          // Redirect guest to profile screen to sign up/login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WishlistScreen()),
            (route) => false,
          );
        }
        break;
      case 2: // Expenses - requires authentication
        if (isGuest) {
          // Redirect guest to profile screen to sign up/login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MoneyTrackerOverviewScreen()),
            (route) => false,
          );
        }
        break;
      case 3: // Stores - can be accessed by guests
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StoresScreen()),
          (route) => false,
        );
        break;
      case 4: // Profile - always accessible (shows sign up/login for guests)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
          (route) => false,
        );
        break;
    }
  }
}

