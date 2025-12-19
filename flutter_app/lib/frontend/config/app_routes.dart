import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/general/onboarding_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/general/home_screen.dart';
import '../screens/general/profile_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/price_comparison/search_screen.dart';
import '../screens/price_comparison/product_details_screen.dart';
import '../screens/price_comparison/barcode_scanner_screen.dart';
import '../screens/price_comparison/advanced_filters_screen.dart';
import '../screens/map/nearby_store_screen.dart';
import '../screens/map/navigation_screen.dart';
import '../screens/money_tracker/receipts_screen.dart';
import '../utils/route_transitions.dart';

/// App route names
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String wishlist = '/wishlist';
  static const String search = '/search';
  static const String productDetails = '/product-details';
  static const String barcodeScanner = '/barcode-scanner';
  static const String advancedFilters = '/advanced-filters';
  static const String nearbyStores = '/nearby-stores';
  static const String navigation = '/navigation';
  static const String receipts = '/receipts';
}

/// Route generator
class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return FadePageRoute(page: const SplashScreen());

      case AppRoutes.onboarding:
        return SlidePageRoute(
          page: const OnboardingScreen(),
          direction: SlideDirection.left,
        );

      case AppRoutes.signIn:
        return SlidePageRoute(
          page: const SignInScreen(),
          direction: SlideDirection.right,
        );

      case AppRoutes.signUp:
        return SlidePageRoute(
          page: const SignUpScreen(),
          direction: SlideDirection.right,
        );

      case AppRoutes.forgotPassword:
        return SlidePageRoute(
          page: ForgotPasswordScreen(),
          direction: SlideDirection.right,
        );

      case AppRoutes.home:
        return FadePageRoute(page: const HomeScreen());

      case AppRoutes.profile:
        return SlidePageRoute(
          page: const ProfileScreen(),
          direction: SlideDirection.right,
        );

      case AppRoutes.wishlist:
        return SlidePageRoute(
          page: const WishlistScreen(),
          direction: SlideDirection.right,
        );

      case AppRoutes.search:
        return SlidePageRoute(
          page: const SearchScreen(),
          direction: SlideDirection.bottom,
        );

      case AppRoutes.productDetails:
        if (args is Map<String, dynamic>) {
          return SlidePageRoute(
            page: ProductDetailsScreen(
              productId: args['productId'] as String? ?? '',
              productName: args['productName'] as String? ?? 'Product',
            ),
            direction: SlideDirection.bottom,
          );
        }
        return _errorRoute();

      case AppRoutes.barcodeScanner:
        return SlidePageRoute(
          page: const BarcodeScannerScreen(),
          direction: SlideDirection.bottom,
        );

      case AppRoutes.advancedFilters:
        return SlidePageRoute(
          page: const AdvancedFiltersScreen(),
          direction: SlideDirection.bottom,
        );

      case AppRoutes.nearbyStores:
        return SlidePageRoute(
          page: const StoresScreen(),
          direction: SlideDirection.right,
        );

      case AppRoutes.navigation:
        if (args is Map<String, dynamic>) {
          return SlidePageRoute(
            page: NavigationScreen(
              storeName: args['storeName'] as String? ?? '',
              destinationLat: args['destinationLat'] as double? ?? 0.0,
              destinationLng: args['destinationLng'] as double? ?? 0.0,
            ),
            direction: SlideDirection.right,
          );
        }
        return _errorRoute();

      case AppRoutes.receipts:
        return SlidePageRoute(
          page: const ReceiptDetailsScreen(),
          direction: SlideDirection.bottom,
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}
