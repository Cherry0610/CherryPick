import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // This is where you'd add a delay and then navigate
    // to your main screen. For example:
    /*
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(), // Replace with your main screen
        ),
      );
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B39AD), // Your deep purple background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 1. The NEW Logo/Icon (Assuming you have a new custom icon or image)
            // Replace this with your actual new logo widget.
            // If it's a PNG/SVG, you'll use an Image.asset() widget.
            // --- Current Logo (for reference) ---
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF6A40D7), // Lighter purple circle color
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.percent, // This is your current % sign icon
                size: 80,
                color: Colors.white,
              ),
            ),

            // Add vertical space between the logo and text
            const SizedBox(height: 24),

            // 2. The Text: "SmartPrice"
            const Text(
              'SmartPrice',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36, // Adjust size as needed
                fontWeight: FontWeight.bold,
              ),
            ),

            // IMPORTANT: Removed the currency values and any other text/widgets.

          ],
        ),
      ),
    );
  }
}