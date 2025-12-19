import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  bool _showText = false;
  bool _showDots = false;

  @override
  void initState() {
    super.initState();

    // 1. Setup Icon Animation (Spring-like effect)
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut, // Simulates the [0.34, 1.56, 0.64, 1] ease
    );

    _rotateAnimation = Tween<double>(
      begin: -3.14,
      end: 0,
    ).animate(CurvedAnimation(parent: _iconController, curve: Curves.easeOut));

    // 2. Start Sequence
    _startAnimation();
  }

  void _startAnimation() async {
    // Delay 200ms (as per your delay: 0.2)
    await Future.delayed(const Duration(milliseconds: 200));
    _iconController.forward();

    // Delay 600ms (as per your delay: 0.8)
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _showText = true);

    // Delay 500ms (as per your delay: 1.3)
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _showDots = true);

    // Total time ~2.5s before completing
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    await _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      if (!mounted) return;

      // Check if user has seen onboarding
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (!hasSeenOnboarding) {
        // First time user - show onboarding
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
        }
      } else if (user == null) {
        // User not logged in - show sign in
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
        }
      } else {
        // User is logged in - go to home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      }
    } catch (e) {
      debugPrint('❌ Error navigating from splash: $e');
      // Fallback to sign in screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
      }
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD94C4C), Color(0xFFE55C5C), Color(0xFFF08080)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Card
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Color(0xFFD94C4C),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Text Animations
            AnimatedOpacity(
              opacity: _showText ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              child: AnimatedSlide(
                offset: _showText ? Offset.zero : const Offset(0, 0.2),
                duration: const Duration(milliseconds: 600),
                child: Column(
                  children: [
                    const Text(
                      'SmartPrice',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Compare. Save. Shop Smart.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pulse Dots
            if (_showDots) const LoadingDots(),
          ],
        ),
      ),
    );
  }
}

// Simple Pulse Dots Widget
class LoadingDots extends StatelessWidget {
  const LoadingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
