import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/general/home_screen.dart';
import 'screens/price_comparison/compare_screen.dart';
import 'screens/money_tracker/receipts_screen.dart';
import 'screens/money_tracker/money_tracker_overview_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/general/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  // Run the application - Always start with Splash Screen
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CherryPick',
      theme: AppTheme.lightTheme,
      // Flow: Splash → Onboarding → Auth → Home
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
