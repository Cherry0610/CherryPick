import 'package:flutter/material.dart';

// Black and White Theme Colors
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // App Icon/Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: kBlack,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.touch_app, size: 60, color: kWhite),
              ),
              const SizedBox(height: 48),

              // Title
              const Text(
                'One-Handed Cursor Control',
                style: TextStyle(
                  color: kBlack,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                'Control your device cursor with one hand. Perfect for accessibility and convenience.',
                style: TextStyle(color: kMediumGray, fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              // Features List
              _buildFeature(
                icon: Icons.accessibility_new,
                text: 'Accessibility First',
              ),
              const SizedBox(height: 16),
              _buildFeature(icon: Icons.touch_app, text: 'Intuitive Gestures'),
              const SizedBox(height: 16),
              _buildFeature(icon: Icons.settings, text: 'Fully Customizable'),
              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/permission-check');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlack,
                    foregroundColor: kWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: kBlack, size: 24),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(color: kBlack, fontSize: 16)),
      ],
    );
  }
}
