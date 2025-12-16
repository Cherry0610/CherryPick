// onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/sign_in_screen.dart';

// Key for SharedPreferences
const String kHasSeenOnboarding = 'hasSeenOnboarding';

// Modern CherryPick Theme Colors
const Color kCherryPickRed = Color(0xFFE53935);
const Color kCherryPickGreen = Color(0xFF4CAF50);
const Color kBackgroundLight = Color(0xFFF5F5F5);
const Color kCardWhite = Color(0xFFFFFFFF);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);

// --- Data Model for Onboarding Cards ---
class OnboardingCardData {
  final String title;
  final String description;
  final Widget illustration;

  OnboardingCardData({
    required this.title,
    required this.description,
    required this.illustration,
  });
}

// --- Onboarding Card Widget ---
class OnboardingCardWidget extends StatelessWidget {
  final OnboardingCardData cardData;
  final bool isLastCard;
  final int currentIndex;
  final VoidCallback onButtonPressed;

  const OnboardingCardWidget({
    super.key,
    required this.cardData,
    required this.isLastCard,
    required this.currentIndex,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: kCardWhite,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Illustration
              SizedBox(
                height: 180,
                width: double.infinity,
                child: cardData.illustration,
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                cardData.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Expanded(
                child: Text(
                  cardData.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: kTextLight,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCherryPickRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLastCard ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pagination Dots (inside card)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == currentIndex
                          ? kCherryPickRed
                          : kTextLight.withOpacity(0.3),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Onboarding Screen Stateful Widget (Main Class) ---
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding cards with custom illustrations
  final List<OnboardingCardData> onboardingCards = [
    OnboardingCardData(
      title: 'Find & Compare Instantly',
      description:
          'Search monthly or compare prices from all nearby stores tomorrow.',
      illustration: _buildSearchIllustration(),
    ),
    OnboardingCardData(
      title: 'Track Prices & Save Alerts',
      description:
          'Add prices and get price drop alerts when items go on sale.',
      illustration: _buildPriceTrackingIllustration(),
    ),
    OnboardingCardData(
      title: 'Smart History & Budgeting',
      description: 'Scan receipts and track monthly spending reports.',
      illustration: _buildSpendingIllustration(),
    ),
  ];

  // Illustration 1: Search & Compare
  static Widget _buildSearchIllustration() {
    return Container(
      decoration: BoxDecoration(
        color: kBackgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Magnifying glass (centered)
          Center(child: Icon(Icons.search, size: 80, color: kCherryPickRed)),
          // Shopping cart overlay
          Positioned(
            left: 30,
            top: 20,
            child: Icon(Icons.shopping_cart, size: 50, color: kCherryPickRed),
          ),
          // Shopping items around
          Positioned(
            right: 20,
            top: 30,
            child: Container(
              width: 35,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.amber.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            right: 60,
            top: 50,
            child: Container(
              width: 30,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 40,
            child: Container(
              width: 28,
              height: 40,
              decoration: BoxDecoration(
                color: kCherryPickRed.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 30,
            child: Container(
              width: 40,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.brown.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Illustration 2: Price Tracking
  static Widget _buildPriceTrackingIllustration() {
    return Container(
      decoration: BoxDecoration(
        color: kBackgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Line graph background
          Positioned.fill(child: CustomPaint(painter: _LineGraphPainter())),
          // Bell icons (notifications) - top right
          Positioned(
            top: 15,
            right: 20,
            child: Icon(
              Icons.notifications_active,
              size: 28,
              color: kCherryPickRed,
            ),
          ),
          Positioned(
            top: 15,
            right: 55,
            child: Icon(
              Icons.notifications_active,
              size: 28,
              color: kCherryPickRed,
            ),
          ),
          // Checkmark and bell at bottom
          Positioned(
            bottom: 20,
            left: 30,
            child: Icon(Icons.check_circle, size: 32, color: kCherryPickRed),
          ),
          Positioned(
            bottom: 20,
            left: 75,
            child: Icon(
              Icons.notifications_active,
              size: 32,
              color: kCherryPickRed,
            ),
          ),
        ],
      ),
    );
  }

  // Illustration 3: Spending/History
  static Widget _buildSpendingIllustration() {
    return Container(
      decoration: BoxDecoration(
        color: kBackgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Pie chart (centered)
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(painter: _PieChartPainter()),
            ),
          ),
          // "Whole Foods" text label
          Positioned(
            top: 15,
            left: 15,
            child: Text(
              'Whole Foods',
              style: TextStyle(
                color: kTextDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Receipt icon
          Positioned(
            bottom: 20,
            right: 25,
            child: Icon(Icons.receipt_long, size: 45, color: kCherryPickRed),
          ),
        ],
      ),
    );
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kHasSeenOnboarding, true);

    if (!mounted) return;
    // Navigate to auth screen after onboarding
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  void _onNextPressed() {
    if (_currentPage < onboardingCards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top Section: Logo and Tagline
            _buildHeader(),

            // Onboarding Cards - Horizontal Scrollable
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingCards.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final isLastCard = index == onboardingCards.length - 1;
                  return OnboardingCardWidget(
                    cardData: onboardingCards[index],
                    isLastCard: isLastCard,
                    currentIndex: index,
                    onButtonPressed: _onNextPressed,
                  );
                },
              ),
            ),

            // Bottom Pagination Dots (outside cards)
            _buildPaginationDots(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Extracted Header Widget ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          // CherryPick Logo (matching splash screen)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Apple Icon with Leaf
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Icon(Icons.apple, size: 40, color: kCherryPickRed),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Icon(Icons.eco, size: 16, color: kCherryPickGreen),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // CherryPick Text
              const Text(
                'CherryPick',
                style: TextStyle(
                  color: kCherryPickRed,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Smart Shopping Starts Here',
            style: TextStyle(
              color: kTextLight,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- Extracted Pagination Dots Widget ---
  Widget _buildPaginationDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SmoothPageIndicator(
        controller: _pageController,
        count: onboardingCards.length,
        effect: const WormEffect(
          spacing: 8.0,
          dotWidth: 10.0,
          dotHeight: 10.0,
          dotColor: kTextLight,
          activeDotColor: kCherryPickRed,
        ),
      ),
    );
  }
}

// Custom Painter for Line Graph
class _LineGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kCherryPickRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(30, size.height - 40);
    path.lineTo(60, size.height - 80);
    path.lineTo(90, size.height - 100);
    path.lineTo(120, size.height - 120);
    path.lineTo(150, size.height - 100);
    path.lineTo(180, size.height - 80);
    path.lineTo(210, size.height - 60);

    canvas.drawPath(path, paint);

    // Fill area under line
    final fillPaint = Paint()
      ..color = kCherryPickRed.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path);
    fillPath.lineTo(210, size.height - 40);
    fillPath.lineTo(30, size.height - 40);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Pie Chart
class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Red segment (45%)
    final redPaint = Paint()..color = kCherryPickRed;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start at top (-90 degrees)
      1.41, // 45% of circle
      true,
      redPaint,
    );

    // Green segment (30%)
    final greenPaint = Paint()..color = kCherryPickGreen;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.16, // Continue from red
      0.94, // 30% of circle
      true,
      greenPaint,
    );

    // Blue segment (25%)
    final bluePaint = Paint()..color = Colors.blue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.78, // Continue from green
      1.57, // 25% of circle
      true,
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
