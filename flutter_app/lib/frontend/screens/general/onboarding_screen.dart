// onboarding_screen.dart - Matching Figma Design with Gradients

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_routes.dart';

// Key for SharedPreferences
const String kHasSeenOnboarding = 'hasSeenOnboarding';

// Figma Design Colors
const Color kOnboardingRedDark = Color(0xFFD94C4C); // Primary red
const Color kOnboardingRedMid = Color(0xFFE55C5C); // Mid red
const Color kOnboardingRedLight = Color(0xFFF08080); // Light red
const Color kOnboardingRedDarker = Color(0xFFC43C3C); // Darker red
const Color kOnboardingWhite = Color(0xFFFFFFFF); // White
const Color kOnboardingBackground = Color(0xFFFFFFFF); // White background
const Color kTextDark = Color(0xFF1A1A1A); // Dark text (gray-900)
const Color kTextLight = Color(0xFF808080); // Light gray text (gray-600)
const Color kPaginationInactive = Color(0xFFD1D5DB); // Gray-300

// Onboarding Page Data with Gradient Colors
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors; // Gradient colors for icon background
  final bool isLastPage;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    this.isLastPage = false,
  });
}

// Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Stores that we compare prices from
  final List<String> _availableStores = [
    'NSK Grocer',
    'Jaya Grocer',
    'Lotus',
    'Mydin',
    'AEON',
  ];

  // Onboarding pages matching Figma design with gradients
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Compare Prices',
      description:
          'Search and compare grocery prices from multiple stores in real-time',
      icon: Icons.search,
      gradientColors: [
        kOnboardingRedDark, // from-[#D94C4C]
        kOnboardingRedMid, // to-[#E55C5C]
      ],
    ),
    OnboardingPage(
      title: 'Price Alerts',
      description: 'Get notified when prices drop on your favorite items',
      icon: Icons.notifications_active,
      gradientColors: [
        kOnboardingRedDark, // from-[#D94C4C]
        kOnboardingRedLight, // to-[#F08080]
      ],
    ),
    OnboardingPage(
      title: 'Track Expenses',
      description:
          'Monitor your grocery spending and save money with smart insights',
      icon: Icons.trending_down,
      gradientColors: [
        kOnboardingRedDarker, // from-[#C43C3C]
        kOnboardingRedDark, // to-[#D94C4C]
      ],
      isLastPage: true,
    ),
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onSkipPressed() {
    _finishOnboarding();
  }

  void _onDotTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kHasSeenOnboarding, true);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOnboardingBackground,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Page content with slide transitions
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index], index);
                  },
                ),
              ),

              // Bottom section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    // Dots indicator
                    _buildPaginationDots(),
                    const SizedBox(height: 32),
                    // Next/Get Started button
                    _buildNextButton(),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),

          // Skip button - absolute positioned top right
          Positioned(
            top: 24,
            right: 24,
            child: TextButton(
              onPressed: _onSkipPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: kTextLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page, int index) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: Offset(_currentPage > index ? -0.5 : 0.5, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Padding(
        key: ValueKey<int>(index),
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background (or store logos for price comparison page)
            if (index == 0)
              // First page: Show store logos
              Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: page.gradientColors,
                      ),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Icon(page.icon, size: 96, color: kOnboardingWhite),
                  ),
                  const SizedBox(height: 32),
                  // Store logos grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: _availableStores.map((store) {
                      return _buildStoreLogo(store);
                    }).toList(),
                  ),
                ],
              )
            else
              // Other pages: Show icon only
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: page.gradientColors,
                  ),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(32),
                child: Icon(page.icon, size: 96, color: kOnboardingWhite),
              ),

            const SizedBox(height: 32),

            // Title
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: kTextDark,
                fontFamily: 'Roboto',
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              page.description,
              textAlign: TextAlign.center,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: kTextLight,
                height: 1.6,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get store logo asset path
  String? _getStoreLogoAsset(String store) {
    switch (store) {
      case 'Lotus':
        return 'assets/images/stores/lotus.png';
      case 'Jaya Grocer':
        return 'assets/images/stores/jaya_grocer.png';
      case 'Mydin':
        return 'assets/images/stores/mydin.png';
      case 'NSK Grocer':
        return 'assets/images/stores/nsk_grocer.png';
      case 'AEON':
        return 'assets/images/stores/aeon.png';
      default:
        return null;
    }
  }

  /// Build store logo widget for onboarding
  Widget _buildStoreLogo(String store) {
    final logoAsset = _getStoreLogoAsset(store);
    final size = 60.0;

    if (logoAsset != null && logoAsset.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: kOnboardingWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              logoAsset,
              width: size - 16,
              height: size - 16,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: kOnboardingBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      store.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: kOnboardingBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            store.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;
        return GestureDetector(
          onTap: () => _onDotTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? kOnboardingRedDark : kPaginationInactive,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton() {
    final isLastPage = _pages[_currentPage].isLastPage;
    return SizedBox(
      width: double.infinity,
      height: 56, // h-14
      child: ElevatedButton(
        onPressed: _onNextPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kOnboardingRedDark,
          foregroundColor: kOnboardingWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // rounded-2xl
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastPage ? 'Get Started' : 'Next',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
