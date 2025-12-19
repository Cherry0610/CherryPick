import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/app_routes.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';
import 'how_smartprice_works_screen.dart';
import 'data_privacy_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'legal_information_screen.dart';
import 'third_party_licenses_screen.dart';
import 'report_issue_screen.dart';
import '../../../backend/services/user_service.dart';
import '../../../backend/services/wishlist_service.dart';
import '../../widgets/bottom_navigation_bar.dart';

// Figma Design Colors
const Color kProfileRed = Color(0xFFE85D5D);
const Color kProfileRedLight = Color(0xFFF28D7F);
const Color kProfileWhite = Color(0xFFFFFFFF);
const Color kProfileBackground = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBorderGray = Color(0xFFE5E7EB);

// Settings Item Model
class SettingsItem {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback? onTap;

  SettingsItem({
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final WishlistService _wishlistService = WishlistService();
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;
  int _wishlistCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload profile when screen becomes visible again (e.g., after editing profile)
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final profile = await _userService.getUserProfile(user.uid);
        
        // Fetch actual wishlist count from Firebase
        int wishlistCount = 0;
        try {
          final wishlistItems = await _wishlistService.getUserWishlist(user.uid);
          wishlistCount = wishlistItems.length;
        } catch (e) {
          debugPrint('Error loading wishlist count: $e');
          wishlistCount = 0;
        }
        
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _wishlistCount = wishlistCount;
            _isLoadingProfile = false;
          });
        }
      } catch (e) {
        debugPrint('Error loading user profile: $e');
        if (mounted) {
          setState(() {
            _wishlistCount = 0;
            _isLoadingProfile = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _wishlistCount = 0;
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.signIn,
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user == null || user.isAnonymous;
    
    // If user is a guest, show login/signup screen
    if (isGuest) {
      return _buildGuestProfileScreen(context);
    }
    
    // Regular profile for logged-in users (user is guaranteed to be non-null here)
    // Get data from Firestore profile - display exactly what user entered
    final userName = _userProfile?['username'] as String? ?? 
                     user.displayName ?? 
                     'User';
    final userEmail = _userProfile?['email'] as String? ?? 
                      user.email ?? 
                      '';
    // Display phone exactly as user typed it
    final userPhone = _userProfile?['phone'] as String? ?? '';
    final profileImageUrl = _userProfile?['profileImageUrl'] as String?;
    final memberSince = user.metadata.creationTime != null
        ? '${_getMonthName(user.metadata.creationTime!.month)} ${user.metadata.creationTime!.year}'
        : 'January 2024';

    final settingsGroups = [
      {
        'title': 'Account Settings',
        'items': [
          SettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      },
      {
        'title': 'Preferences',
        'items': [
          SettingsItem(
            icon: Icons.security_outlined,
            label: 'Privacy & Security',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacySecurityScreen(),
                ),
              );
            },
          ),
          SettingsItem(
            icon: Icons.settings_outlined,
            label: 'App Settings',
          ),
        ],
      },
      {
        'title': 'About',
        'items': [
          SettingsItem(
            icon: Icons.help_outline,
            label: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          SettingsItem(
            icon: Icons.info_outline,
            label: 'How SmartPrice Works',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HowSmartPriceWorksScreen(),
                ),
              );
            },
          ),
          SettingsItem(
            icon: Icons.security_outlined,
            label: 'Data Privacy Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataPrivacySettingsScreen(),
                ),
              );
            },
          ),
          SettingsItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          SettingsItem(
            icon: Icons.gavel_outlined,
            label: 'Legal Information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LegalInformationScreen(),
                ),
              );
            },
          ),
          SettingsItem(
            icon: Icons.code_outlined,
            label: 'Third Party Licenses',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThirdPartyLicensesScreen(),
                ),
              );
            },
          ),
          SettingsItem(
            icon: Icons.bug_report_outlined,
            label: 'Report an Issue',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportIssueScreen(),
                ),
              );
            },
          ),
        ],
      },
    ];

    return Scaffold(
      backgroundColor: kProfileBackground,
      appBar: AppBar(
        backgroundColor: kProfileWhite,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              _isLoadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : _buildUserProfileCard(
                      userName,
                      userEmail,
                      userPhone,
                      profileImageUrl,
                      memberSince,
                      context,
                    ),
              const SizedBox(height: 16),

              // Stats
              _buildStats(),
              const SizedBox(height: 16),

              // Settings Groups
              ...settingsGroups.map((group) {
                return Column(
                  children: [
                    _buildSettingsGroup(
                      group['title'] as String,
                      group['items'] as List<SettingsItem>,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),

              // App Version
              _buildAppVersion(),
              const SizedBox(height: 16),

              // Logout Button
              _buildLogoutButton(context),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildUserProfileCard(
    String name,
    String email,
    String phone,
    String? profileImageUrl,
    String memberSince,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kProfileRed, kProfileRedLight],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to edit profile when photo is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      ).then((_) {
                        // Reload profile after editing
                        _loadUserProfile();
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: kProfileWhite.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kProfileWhite.withValues(alpha: 0.5),
                          width: 4,
                        ),
                      ),
                      child: profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                profileImageUrl,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: kProfileWhite.withValues(alpha: 0.2),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(kProfileWhite),
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: kProfileWhite,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: kProfileWhite,
                            ),
                    ),
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kProfileWhite,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since $memberSince',
                      style: TextStyle(
                        fontSize: 12,
                        color: kProfileWhite.withValues(alpha: 0.8),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kProfileWhite.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildUserInfoRow(Icons.email_outlined, email.isNotEmpty ? email : 'Not provided'),
                const SizedBox(height: 8),
                _buildUserInfoRow(Icons.phone_outlined, phone.isNotEmpty ? phone : 'Not provided'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: kProfileWhite,
                foregroundColor: kProfileRed,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kProfileWhite),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: kProfileWhite,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    // Use actual wishlist count from Firebase, default to 0
    final wishlistCount = _wishlistCount;
    final totalSaved = _userProfile?['totalSaved'] as double? ?? 0.0;
    final purchaseCount = _userProfile?['purchaseCount'] as int? ?? 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(wishlistCount.toString(), 'Wishlist'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('RM${totalSaved.toStringAsFixed(0)}', 'Saved'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(purchaseCount.toString(), 'Purchases'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kProfileRed,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: kTextLight,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<SettingsItem> items) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kTextDark,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          ...items.map((item) {
            return _buildSettingsItem(item);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(SettingsItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: kBorderGray.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kProfileBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: kTextLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: kTextDark,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            if (item.badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kProfileRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.badge!,
                  style: const TextStyle(
                    color: kProfileWhite,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right,
              color: kTextLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Container(
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
      child: Column(
        children: [
          const Text(
            'SmartPrice v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: kTextLight,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2025 SmartPrice. All rights reserved.',
            style: TextStyle(
              color: kTextLight.withValues(alpha: 0.7),
              fontSize: 10,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildGuestProfileScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: kProfileBackground,
      appBar: AppBar(
        backgroundColor: kProfileWhite,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Guest Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: kProfileRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kProfileRed,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 60,
                    color: kProfileRed,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Guest Message
              const Text(
                'You\'re browsing as a guest',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to access your profile, wishlist, and save your preferences',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kTextLight,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 40),
              
              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signIn);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kProfileRed,
                    foregroundColor: kProfileWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signUp);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kProfileRed, width: 2),
                    foregroundColor: kProfileRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Benefits Section
              _buildGuestBenefits(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildGuestBenefits() {
    final benefits = [
      {'icon': Icons.favorite_outline, 'text': 'Save products to wishlist'},
      {'icon': Icons.notifications_outlined, 'text': 'Get price drop alerts'},
      {'icon': Icons.history, 'text': 'Track your purchase history'},
      {'icon': Icons.settings_outlined, 'text': 'Customize your preferences'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Benefits of signing in:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          ...benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    benefit['icon'] as IconData,
                    size: 20,
                    color: kProfileRed,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit['text'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kTextDark,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
