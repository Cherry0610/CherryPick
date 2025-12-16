import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'general/onboarding_screen.dart';
import 'auth/sign_in_screen.dart';
import 'general/home_screen.dart';

// Modern CherryPick Theme Colors
const Color kCherryPickRed = Color(0xFFE53935);
const Color kCherryPickGreen = Color(0xFF4CAF50);
const Color kBackgroundLight = Color(0xFFF5F5F5);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);

// Key for storing the onboarding status
const String kHasSeenOnboarding = 'hasSeenOnboarding';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for splash screen display (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check onboarding status
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(kHasSeenOnboarding) ?? false;

    if (!mounted) return;

    // Flow: Splash → Onboarding → Auth → Home
    if (!hasSeenOnboarding) {
      // First time user -> Show Onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      // User has seen onboarding -> Check auth status
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is logged in -> Go to Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // User is not logged in -> Go to Auth
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // CherryPick Logo with Apple Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Apple Icon with Leaf
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Icon(Icons.apple, size: 60, color: kCherryPickRed),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Icon(Icons.eco, size: 20, color: kCherryPickGreen),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // CherryPick Text
                const Text(
                  'CherryPick',
                  style: TextStyle(
                    color: kCherryPickRed,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tagline
            const Text(
              'Smart Shopping Starts Here',
              style: TextStyle(
                color: kTextLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            // Loading Indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(kCherryPickRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
