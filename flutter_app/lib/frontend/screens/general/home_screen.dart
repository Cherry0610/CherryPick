import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../price_comparison/search_screen.dart';
import '../map/nearby_store_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'profile_screen.dart';
import '../wishlist/notifications_log_screen.dart';
import '../money_tracker/money_tracker_overview_screen.dart';
import '../../../backend/services/unified_grocery_catalog_service.dart';
import '../../../backend/data/mock_grocery_data.dart';
import '../../../backend/models/grocery_store_product.dart';
import '../../widgets/product_image_widget.dart';
import '../../config/app_routes.dart';
import '../price_comparison/product_details_screen.dart';

// Figma Design Colors
const Color kHomeRed = Color(0xFFE85D5D); // Primary red
const Color kHomeRedLight = Color(0xFFF28D7F); // Light red for gradients
const Color kHomeWhite = Color(0xFFFFFFFF);
const Color kHomeBackground = Color(0xFFF9FAFB); // Gray-50
const Color kTextDark = Color(0xFF1A1A1A); // Gray-900
const Color kTextLight = Color(0xFF808080); // Gray-600
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBorderGray = Color(0xFFE5E7EB); // Gray-200

// Product Model
class Product {
  final String id;
  final String title;
  final String price;
  final String? originalPrice;
  final String? discount;
  final String imageUrl;
  final String storeName;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.originalPrice,
    this.discount,
    required this.imageUrl,
    required this.storeName,
  });
}

// New Product Data Model
class ForYouProduct {
  final int id;
  final String category;
  final String productName;
  final String brand;
  final Map<String, double> prices;
  final String unit;

  ForYouProduct({
    required this.id,
    required this.category,
    required this.productName,
    required this.brand,
    required this.prices,
    required this.unit,
  });

  factory ForYouProduct.fromJson(Map<String, dynamic> json) {
    return ForYouProduct(
      id: json['id'] as int,
      category: json['category'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      prices: Map<String, double>.from(
        (json['prices'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      ),
      unit: json['unit'] as String,
    );
  }
}

// For You Product Data
final List<Map<String, dynamic>> _forYouProductData = [
  {
    "id": 1,
    "category": "Rice & Grains",
    "productName": "Local White Rice 5kg",
    "brand": "Cap Rambutan",
    "prices": {"Lotus": 11.90, "JayaGrocer": 30.99, "Mydin": 12.50},
    "unit": "5kg",
  },
  {
    "id": 2,
    "category": "Rice & Grains",
    "productName": "Spaghetti",
    "brand": "San Remo",
    "prices": {"Lotus": 4.50, "JayaGrocer": 4.19, "Mydin": 4.30},
    "unit": "500g",
  },
  {
    "id": 3,
    "category": "Fresh Produce",
    "productName": "Banana",
    "brand": "Local",
    "prices": {"Lotus": 3.50, "JayaGrocer": 8.20, "Mydin": 3.80},
    "unit": "1kg",
  },
  {
    "id": 4,
    "category": "Fresh Produce",
    "productName": "Apple Fuji",
    "brand": "Imported",
    "prices": {"Lotus": 9.50, "JayaGrocer": 11.90, "Mydin": 10.80},
    "unit": "6pcs",
  },
  {
    "id": 5,
    "category": "Fresh Produce",
    "productName": "Sweet Corn",
    "brand": "Local",
    "prices": {"Lotus": 3.80, "JayaGrocer": 4.30, "Mydin": 2.50},
    "unit": "2pcs",
  },
  {
    "id": 6,
    "category": "Meat & Protein",
    "productName": "Whole Chicken",
    "brand": "Fresh",
    "prices": {"Lotus": 18.90, "JayaGrocer": 20.90, "Mydin": 17.90},
    "unit": "1.8kg",
  },
  {
    "id": 7,
    "category": "Meat & Protein",
    "productName": "Chicken Burger Patty",
    "brand": "Ramly",
    "prices": {"Lotus": 6.50, "JayaGrocer": 7.20, "Mydin": 5.85},
    "unit": "130g",
  },
  {
    "id": 8,
    "category": "Dairy & Eggs",
    "productName": "Grade A Eggs",
    "brand": "Farm Fresh",
    "prices": {"Lotus": 7.50, "JayaGrocer": 6.99, "Mydin": 7.20},
    "unit": "10pcs",
  },
  {
    "id": 9,
    "category": "Dairy & Eggs",
    "productName": "UHT Fresh Milk",
    "brand": "Dutch Lady",
    "prices": {"Lotus": 7.99, "JayaGrocer": 9.99, "Mydin": 7.50},
    "unit": "1L",
  },
  {
    "id": 10,
    "category": "Cooking Essentials",
    "productName": "Refined Cooking Oil",
    "brand": "Saji",
    "prices": {"Lotus": 16.90, "JayaGrocer": 29.49, "Mydin": 17.50},
    "unit": "5kg",
  },
  {
    "id": 11,
    "category": "Cooking Essentials",
    "productName": "White Sugar",
    "brand": "CSR",
    "prices": {"Lotus": 2.50, "JayaGrocer": 2.95, "Mydin": 2.60},
    "unit": "1kg",
  },
  {
    "id": 12,
    "category": "Sauces & Condiments",
    "productName": "Chilli Sauce",
    "brand": "Life",
    "prices": {"Lotus": 5.49, "JayaGrocer": 4.69, "Mydin": 5.20},
    "unit": "305g",
  },
  {
    "id": 13,
    "category": "Snacks",
    "productName": "Instant Noodles",
    "brand": "Maggi",
    "prices": {"Lotus": 3.00, "JayaGrocer": 2.99, "Mydin": 2.99},
    "unit": "5-pack",
  },
  {
    "id": 14,
    "category": "Beverages",
    "productName": "Soft Drink",
    "brand": "Coca-Cola",
    "prices": {"Lotus": 5.50, "JayaGrocer": 6.20, "Mydin": 5.30},
    "unit": "1.5L",
  },
  {
    "id": 15,
    "category": "Frozen Food",
    "productName": "Frozen Chicken Nuggets",
    "brand": "Ayamas",
    "prices": {"Lotus": 12.90, "JayaGrocer": 14.50, "Mydin": 12.20},
    "unit": "850g",
  },
  {
    "id": 16,
    "category": "Fresh Produce",
    "productName": "Carrot",
    "brand": "Local",
    "prices": {"Lotus": 4.90, "JayaGrocer": 6.50, "Mydin": 5.20},
    "unit": "1kg",
  },
  {
    "id": 17,
    "category": "Fresh Produce",
    "productName": "Potato",
    "brand": "Local",
    "prices": {"Lotus": 4.50, "JayaGrocer": 6.90, "Mydin": 4.80},
    "unit": "1kg",
  },
  {
    "id": 18,
    "category": "Fresh Produce",
    "productName": "Broccoli",
    "brand": "Imported",
    "prices": {"Lotus": 8.90, "JayaGrocer": 11.50, "Mydin": 9.20},
    "unit": "1 stalk",
  },
  {
    "id": 19,
    "category": "Fresh Produce",
    "productName": "Tomato",
    "brand": "Local",
    "prices": {"Lotus": 6.50, "JayaGrocer": 8.90, "Mydin": 6.80},
    "unit": "1kg",
  },
  {
    "id": 20,
    "category": "Fresh Produce",
    "productName": "Cabbage",
    "brand": "Local",
    "prices": {"Lotus": 4.20, "JayaGrocer": 6.00, "Mydin": 4.50},
    "unit": "1kg",
  },
  {
    "id": 21,
    "category": "Meat & Protein",
    "productName": "Chicken Breast",
    "brand": "Fresh",
    "prices": {"Lotus": 15.90, "JayaGrocer": 18.90, "Mydin": 16.50},
    "unit": "1kg",
  },
  {
    "id": 22,
    "category": "Meat & Protein",
    "productName": "Minced Beef",
    "brand": "Imported",
    "prices": {"Lotus": 29.90, "JayaGrocer": 35.90, "Mydin": 31.50},
    "unit": "1kg",
  },
  {
    "id": 23,
    "category": "Meat & Protein",
    "productName": "Fish Fillet",
    "brand": "Dory",
    "prices": {"Lotus": 19.90, "JayaGrocer": 24.90, "Mydin": 21.50},
    "unit": "1kg",
  },
  {
    "id": 24,
    "category": "Meat & Protein",
    "productName": "Canned Tuna",
    "brand": "Ayam Brand",
    "prices": {"Lotus": 6.50, "JayaGrocer": 7.70, "Mydin": 6.80},
    "unit": "160g",
  },
  {
    "id": 25,
    "category": "Dairy & Eggs",
    "productName": "Cheddar Cheese",
    "brand": "Anchor",
    "prices": {"Lotus": 13.90, "JayaGrocer": 15.90, "Mydin": 14.50},
    "unit": "250g",
  },
  {
    "id": 26,
    "category": "Dairy & Eggs",
    "productName": "Butter",
    "brand": "Anchor",
    "prices": {"Lotus": 13.50, "JayaGrocer": 13.99, "Mydin": 13.20},
    "unit": "227g",
  },
  {
    "id": 27,
    "category": "Dairy & Eggs",
    "productName": "Yogurt Drink",
    "brand": "Dutch Lady",
    "prices": {"Lotus": 3.50, "JayaGrocer": 2.50, "Mydin": 2.80},
    "unit": "200g",
  },
  {
    "id": 28,
    "category": "Cooking Essentials",
    "productName": "Soy Sauce",
    "brand": "Kikkoman",
    "prices": {"Lotus": 7.90, "JayaGrocer": 9.50, "Mydin": 8.20},
    "unit": "500ml",
  },
  {
    "id": 29,
    "category": "Cooking Essentials",
    "productName": "Oyster Sauce",
    "brand": "Lee Kum Kee",
    "prices": {"Lotus": 6.90, "JayaGrocer": 8.50, "Mydin": 7.20},
    "unit": "510g",
  },
  {
    "id": 30,
    "category": "Cooking Essentials",
    "productName": "Peanut Butter",
    "brand": "Skippy",
    "prices": {"Lotus": 15.90, "JayaGrocer": 18.90, "Mydin": 16.80},
    "unit": "340g",
  },
  {
    "id": 31,
    "category": "Snacks",
    "productName": "Potato Chips",
    "brand": "Lay's",
    "prices": {"Lotus": 6.50, "JayaGrocer": 7.20, "Mydin": 6.80},
    "unit": "160g",
  },
  {
    "id": 32,
    "category": "Snacks",
    "productName": "Chocolate Bar",
    "brand": "Cadbury",
    "prices": {"Lotus": 4.20, "JayaGrocer": 4.80, "Mydin": 4.50},
    "unit": "90g",
  },
  {
    "id": 33,
    "category": "Breakfast",
    "productName": "Cornflakes",
    "brand": "Kellogg's",
    "prices": {"Lotus": 9.90, "JayaGrocer": 11.50, "Mydin": 10.20},
    "unit": "300g",
  },
  {
    "id": 34,
    "category": "Breakfast",
    "productName": "Muesli",
    "brand": "Nestle",
    "prices": {"Lotus": 19.95, "JayaGrocer": 18.95, "Mydin": 19.50},
    "unit": "750g",
  },
  {
    "id": 35,
    "category": "Beverages",
    "productName": "Green Tea",
    "brand": "Pokko",
    "prices": {"Lotus": 2.50, "JayaGrocer": 2.90, "Mydin": 2.40},
    "unit": "500ml",
  },
  {
    "id": 36,
    "category": "Beverages",
    "productName": "Instant Coffee",
    "brand": "Nescafe",
    "prices": {"Lotus": 12.90, "JayaGrocer": 14.50, "Mydin": 13.20},
    "unit": "200g",
  },
  {
    "id": 37,
    "category": "Frozen Food",
    "productName": "Frozen French Fries",
    "brand": "McCain",
    "prices": {"Lotus": 9.90, "JayaGrocer": 11.90, "Mydin": 10.20},
    "unit": "1kg",
  },
  {
    "id": 38,
    "category": "Frozen Food",
    "productName": "Frozen Fish Balls",
    "brand": "CP",
    "prices": {"Lotus": 7.50, "JayaGrocer": 8.90, "Mydin": 7.80},
    "unit": "500g",
  },
  {
    "id": 39,
    "category": "Household",
    "productName": "Dishwashing Liquid",
    "brand": "Sunlight",
    "prices": {"Lotus": 4.90, "JayaGrocer": 5.50, "Mydin": 5.20},
    "unit": "750ml",
  },
  {
    "id": 40,
    "category": "Household",
    "productName": "Toilet Paper",
    "brand": "Scott",
    "prices": {"Lotus": 12.90, "JayaGrocer": 14.90, "Mydin": 13.50},
    "unit": "10 rolls",
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  bool _isLoadingProducts = true;
  List<UnifiedProduct> _products = [];

  // Stores that we compare prices from
  final List<String> _availableStores = [
    'NSK Grocer',
    'Jaya Grocer',
    'Lotus',
    'Mydin',
    'AEON',
  ];

  /// Get store key for internal use (maps display name to internal key)
  String _getStoreKey(String displayName) {
    switch (displayName) {
      case 'NSK Grocer':
        return 'NSK';
      case 'Jaya Grocer':
        return 'JayaGrocer';
      case 'Lotus':
        return 'Lotus';
      case 'Mydin':
        return 'Mydin';
      case 'AEON':
        return 'AEON';
      default:
        return displayName;
    }
  }

  /// Get store logo asset path
  String? _getStoreLogoAsset(String store) {
    final storeKey = _getStoreKey(store);
    switch (storeKey) {
      case 'Lotus':
        return 'assets/images/stores/lotus.png';
      case 'JayaGrocer':
        return 'assets/images/stores/jaya_grocer.png';
      case 'Mydin':
        return 'assets/images/stores/mydin.png';
      case 'NSK':
        return 'assets/images/stores/nsk_grocer.png';
      case 'AEON':
        return 'assets/images/stores/aeon.png';
      default:
        return null;
    }
  }

  /// Get store website URL
  String _getStoreWebsiteUrl(String store) {
    final storeKey = _getStoreKey(store);
    switch (storeKey) {
      case 'Lotus':
        return 'https://www.lotuss.com.my';
      case 'JayaGrocer':
        return 'https://www.jayagrocer.com';
      case 'Mydin':
        return 'https://www.mydin.com.my';
      case 'NSK':
        return 'https://www.nskgrocer.com';
      case 'AEON':
        return 'https://www.aeon.com.my';
      default:
        return 'https://www.google.com/search?q=${Uri.encodeComponent('$store Malaysia online grocery')}';
    }
  }

  /// Get Google Maps search query for nearest physical store
  String _getStoreMapsQuery(String store) {
    final storeKey = _getStoreKey(store);
    switch (storeKey) {
      case 'NSK':
        return 'NSK Grocer Malaysia';
      case 'JayaGrocer':
        return 'Jaya Grocer Malaysia';
      case 'Lotus':
        return 'Lotus Malaysia';
      case 'Mydin':
        return 'Mydin Malaysia';
      case 'AEON':
        return 'AEON Malaysia';
      default:
        return '$store Malaysia';
    }
  }

  /// Build store logo widget
  Widget _buildStoreLogo(String store) {
    final logoAsset = _getStoreLogoAsset(store);
    final containerSize = 50.0;
    final padding = 8.0;
    final imageSize = containerSize - (padding * 2);

    if (logoAsset != null && logoAsset.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Image.asset(
            logoAsset,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
            cacheWidth: imageSize.toInt(),
            cacheHeight: imageSize.toInt(),
            errorBuilder: (context, error, stackTrace) {
              // Fallback to store name text if logo asset not found
              debugPrint('❌ Error loading logo asset: $logoAsset - $error');
              debugPrint('Stack trace: $stackTrace');
              return Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: kHomeBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    store.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // Fallback to store name text if no logo asset
      return Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: kHomeBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            store.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
        ),
      );
    }
  }

  /// Navigate to nearest physical store on Google Maps
  Future<void> _navigateToNearestStore(String store) async {
    try {
      final searchQuery = _getStoreMapsQuery(store);
      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}',
      );

      debugPrint('🗺️ Opening Google Maps for nearest $store: $searchQuery');

      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Showing nearest $store locations on Google Maps'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cannot open Google Maps. Please check your internet connection.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error opening Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Google Maps: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Navigate to store - try online store first, fallback to nearest physical store
  Future<void> _navigateToStore(String store) async {
    final websiteUrl = _getStoreWebsiteUrl(store);

    try {
      debugPrint('🌐 Attempting to open $store online store: $websiteUrl');

      final url = Uri.parse(websiteUrl);

      // Check if URL can be launched
      if (await canLaunchUrl(url)) {
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          debugPrint('✅ Successfully opened $store online store');
          return; // Success, exit early
        } catch (e) {
          debugPrint('⚠️ Error launching URL, falling back to Google Maps: $e');
          // Fall through to Google Maps fallback
        }
      } else {
        debugPrint('⚠️ URL cannot be launched, falling back to Google Maps');
        // Fall through to Google Maps fallback
      }

      // If we reach here, the online store couldn't be opened - fallback to Google Maps
      debugPrint('🗺️ Falling back to Google Maps for nearest $store');
      await _navigateToNearestStore(store);
    } catch (e) {
      debugPrint('❌ Error opening store: $e');
      // On any error, try Google Maps as fallback
      await _navigateToNearestStore(store);
    }
  }

  @override
  void initState() {
    super.initState();
    // Allow guests to access home screen
    _loadProducts();
  }

  /// Check if user is a guest (not authenticated)
  bool _isGuest() {
    final user = FirebaseAuth.instance.currentUser;
    return user == null || user.isAnonymous;
  }

  /// Redirect guest users to profile screen to sign up/login
  void _redirectGuestToProfile() {
    if (_isGuest()) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.profile,
        (route) => false,
      );
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (!refresh) {
      setState(() {
        _isLoadingProducts = true;
      });
    }

    try {
      // Load products from For You data (new product data)
      final forYouProducts = _loadForYouProducts();

      // Also get some products from mock data for variety
      final allMockProducts = MockGroceryData.getMockProducts();
      final mockUnifiedProducts = _convertToUnifiedProducts(
        allMockProducts,
        limit: 20,
      );

      // Combine both sources
      final allProducts = [...forYouProducts, ...mockUnifiedProducts];

      // Shuffle for random display
      allProducts.shuffle();

      // Take 12 random products to display
      _products = allProducts.take(12).toList();

      setState(() {
        _isLoadingProducts = false;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  /// Convert GroceryStoreProduct list to UnifiedProduct list
  /// Groups products by name and creates unified products with multiple store options
  List<UnifiedProduct> _convertToUnifiedProducts(
    List<GroceryStoreProduct> products, {
    required int limit,
  }) {
    // Get all mock products to find all stores for each product
    final allMockProducts = MockGroceryData.getMockProducts();

    // Group products by name (normalized)
    final Map<String, List<GroceryStoreProduct>> grouped = {};

    for (var product in products) {
      final normalizedName = product.name.toLowerCase().trim();
      if (!grouped.containsKey(normalizedName)) {
        grouped[normalizedName] = [];
      }
      grouped[normalizedName]!.add(product);
    }

    // For each grouped product, find all stores that have it
    final List<UnifiedProduct> unifiedProducts = [];

    for (var entry in grouped.entries.take(limit)) {
      final productName = entry.key;

      // Find all stores that have this product
      final allStoresForProduct = allMockProducts
          .where((p) => p.name.toLowerCase().trim() == productName)
          .toList();

      if (allStoresForProduct.isEmpty) continue;

      // Create store options
      final storeOptions = allStoresForProduct.map((p) {
        return StoreOption(
          storeName: p.storeName,
          price: p.price,
          currency: p.currency,
          productUrl: p.productUrl,
          inStock: p.inStock,
          rating: p.rating,
          reviewCount: p.reviewCount,
        );
      }).toList();

      // Sort by price (cheapest first)
      storeOptions.sort((a, b) => a.price.compareTo(b.price));

      // Calculate prices
      final prices = storeOptions.map((s) => s.price).toList();
      final cheapestPrice = prices.isNotEmpty
          ? prices.reduce((a, b) => a < b ? a : b)
          : 0.0;
      final mostExpensivePrice = prices.isNotEmpty
          ? prices.reduce((a, b) => a > b ? a : b)
          : 0.0;
      final averagePrice = prices.isNotEmpty
          ? prices.reduce((a, b) => a + b) / prices.length
          : 0.0;

      // Get best product for metadata (use Jaya Grocer if available, otherwise cheapest)
      final bestProduct = allStoresForProduct.firstWhere(
        (p) => p.storeName.toLowerCase().contains('jaya grocer'),
        orElse: () => allStoresForProduct.first,
      );

      unifiedProducts.add(
        UnifiedProduct(
          id: 'mock_${productName.hashCode}',
          name: bestProduct.name,
          category: bestProduct.category ?? 'General',
          imageUrl: bestProduct.imageUrl.isNotEmpty
              ? bestProduct.imageUrl
              : null,
          description: bestProduct.description,
          brand: bestProduct.brand,
          unit: bestProduct.unit,
          cheapestPrice: cheapestPrice,
          mostExpensivePrice: mostExpensivePrice,
          averagePrice: averagePrice,
          currency: bestProduct.currency,
          storeCount: storeOptions.length,
          storeOptions: storeOptions,
          inStock: bestProduct.inStock,
          rating: bestProduct.rating,
          reviewCount: bestProduct.reviewCount,
        ),
      );
    }

    return unifiedProducts;
  }

  /// Load and convert For You products from new data format
  List<UnifiedProduct> _loadForYouProducts() {
    // Parse the product data
    final products = _forYouProductData
        .map((json) => ForYouProduct.fromJson(json))
        .toList();

    // Convert to UnifiedProduct format
    final List<UnifiedProduct> unifiedProducts = [];

    for (var product in products) {
      // Create store options from all prices (for price comparison)
      // If a store is selected, we still show all prices but only products available at that store
      final storeOptions = product.prices.entries.map((entry) {
        return StoreOption(
          storeName: entry.key,
          price: entry.value,
          currency: 'RM',
          productUrl: null,
          inStock: true,
          rating: null,
          reviewCount: null,
        );
      }).toList();

      // Sort by price (cheapest first)
      storeOptions.sort((a, b) => a.price.compareTo(b.price));

      // Calculate prices
      final prices = storeOptions.map((s) => s.price).toList();
      final cheapestPrice = prices.isNotEmpty
          ? prices.reduce((a, b) => a < b ? a : b)
          : 0.0;
      final mostExpensivePrice = prices.isNotEmpty
          ? prices.reduce((a, b) => a > b ? a : b)
          : 0.0;
      final averagePrice = prices.isNotEmpty
          ? prices.reduce((a, b) => a + b) / prices.length
          : 0.0;

      unifiedProducts.add(
        UnifiedProduct(
          id: 'foryou_${product.id}',
          name: product.productName,
          category: product.category,
          imageUrl: null, // No image URLs in the new data
          description: null,
          brand: product.brand,
          unit: product.unit,
          cheapestPrice: cheapestPrice,
          mostExpensivePrice: mostExpensivePrice,
          averagePrice: averagePrice,
          currency: 'RM',
          storeCount: storeOptions.length,
          storeOptions: storeOptions,
          inStock: true,
          rating: null,
          reviewCount: null,
        ),
      );
    }

    // Shuffle for variety
    unifiedProducts.shuffle();

    return unifiedProducts;
  }

  void _onSearchClick() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        // Wishlist - requires authentication
        if (_isGuest()) {
          _redirectGuestToProfile();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WishlistScreen()),
          );
        }
        break;
      case 2:
        // Expenses - requires authentication
        if (_isGuest()) {
          _redirectGuestToProfile();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MoneyTrackerOverviewScreen(),
            ),
          );
        }
        break;
      case 3:
        // Stores - can be accessed by guests
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StoresScreen()),
        );
        break;
      case 4:
        // Profile - always accessible (shows sign up/login for guests)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHomeBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadProducts(refresh: true),
                color: kHomeRed,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar and Store Filter (side by side)
                      _buildSearchAndStoreFilter(),
                      const SizedBox(height: 16),
                      // Products Section
                      _buildProductsSection(),
                      const SizedBox(height: 16),
                      // Refer a Friend
                      _buildReferFriend(),
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: kHomeWhite,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'SmartPrice',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kHomeRed,
              fontFamily: 'Roboto',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsLogScreen(),
                ),
              );
            },
            child: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: kTextLight,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kHomeRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndStoreFilter() {
    return Column(
      children: [
        // Search Bar
        GestureDetector(
          onTap: _onSearchClick,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: kHomeBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderGray),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: kTextLight, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search products...',
                    style: TextStyle(color: kTextLight, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kHomeRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: kHomeWhite,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Stores We Compare Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stores We Compare',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kTextDark,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: _availableStores.length,
                itemBuilder: (context, index) {
                  final store = _availableStores[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _availableStores.length - 1 ? 16 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => _navigateToStore(store),
                      child: Container(
                        width: 120,
                        height: 140,
                        decoration: BoxDecoration(
                          color: kHomeWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorderGray, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: _buildStoreLogo(store),
                            ),
                            // Store name (text below logo)
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                store,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kTextDark,
                                  fontFamily: 'Roboto',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextDark,
                fontFamily: 'Roboto',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: const Text(
                'VIEW ALL >>',
                style: TextStyle(
                  color: kHomeRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _isLoadingProducts
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _products.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No products available',
                    style: TextStyle(color: kTextLight),
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  // More columns on web, fewer on mobile
                  final crossAxisCount = kIsWeb
                      ? (constraints.maxWidth > 1200
                            ? 6
                            : constraints.maxWidth > 800
                            ? 4
                            : 3)
                      : 2;
                  final childAspectRatio = kIsWeb ? 0.65 : 0.75;
                  final spacing = kIsWeb ? 8.0 : 12.0;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    cacheExtent: 500,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                    ),
                    itemCount: kIsWeb
                        ? _products.length
                        : (_products.length > 8 ? 8 : _products.length),
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_products[index]);
                    },
                  );
                },
              ),
      ],
    );
  }

  Widget _buildProductCard(UnifiedProduct product) {
    // Memoize calculations to avoid recomputing on every rebuild
    final hasDiscount = product.mostExpensivePrice > product.cheapestPrice;
    final discountPercent = hasDiscount
        ? ((product.mostExpensivePrice - product.cheapestPrice) /
                  product.mostExpensivePrice *
                  100)
              .round()
        : 0;

    // Smaller sizes on web
    final borderRadius = kIsWeb ? 6.0 : 8.0;
    final padding = kIsWeb ? 6.0 : 8.0;
    final fontSize = kIsWeb ? 10.0 : 12.0;
    final priceFontSize = kIsWeb ? 12.0 : 14.0;

    // Wrap in RepaintBoundary to prevent unnecessary repaints
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: kBorderGray, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: ProductImageWidget(
                        imageUrl: product.imageUrl?.isNotEmpty == true
                            ? product.imageUrl
                            : null,
                        productName: product.name,
                        brand: product.brand,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        borderRadius: borderRadius,
                        backgroundColor: Colors.grey[100],
                        fallbackIcon: Icons.shopping_bag,
                        fallbackIconSize: kIsWeb ? 30 : 40,
                      ),
                    ),
                  ),
                  // Discount Badge
                  if (hasDiscount && discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$discountPercent% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Name (Bold, Bigger Font)
                    if (product.brand != null && product.brand!.isNotEmpty) ...[
                      Text(
                        product.brand!,
                        style: TextStyle(
                          fontSize: fontSize + (kIsWeb ? 1 : 2),
                          fontWeight: FontWeight.bold,
                          color: kHomeRed,
                          fontFamily: 'Roboto',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: kIsWeb ? 2 : 3),
                    ],
                    // Product Name (Bold, Title)
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: kIsWeb ? 2 : 4),
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product.currency} ${product.cheapestPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: priceFontSize,
                            fontWeight: FontWeight.bold,
                            color: kHomeRed,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        if (hasDiscount && product.mostExpensivePrice > 0) ...[
                          SizedBox(width: kIsWeb ? 4 : 6),
                          Text(
                            '${product.currency} ${product.mostExpensivePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: fontSize - 1,
                              color: kTextLight,
                              decoration: TextDecoration.lineThrough,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Store Name
                    SizedBox(height: kIsWeb ? 2 : 4),
                    Text(
                      product.storeOptions.isNotEmpty
                          ? product.storeOptions.first.storeName
                          : 'Multiple Stores',
                      style: TextStyle(
                        fontSize: fontSize - 1,
                        color: kTextLight,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // View Deal Button
                    SizedBox(height: kIsWeb ? 4 : 6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                productId: product.id,
                                productName: product.name,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kHomeRed,
                          foregroundColor: kHomeWhite,
                          padding: EdgeInsets.symmetric(
                            horizontal: kIsWeb ? 8 : 12,
                            vertical: kIsWeb ? 4 : 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'View Deal',
                          style: TextStyle(
                            fontSize: kIsWeb ? 9 : 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferFriend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kHomeRed, kHomeRedLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Refer a Friend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kHomeWhite,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share SmartPrice with friends and earn rewards!',
            style: TextStyle(
              fontSize: 14,
              color: kHomeWhite,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Handle share
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kHomeWhite,
              foregroundColor: kHomeRed,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Share Now',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
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
          _buildNavItem(Icons.shopping_bag, 'Deals', 0),
          _buildNavItem(Icons.favorite_border, 'Wishlist', 1),
          _buildNavItem(Icons.bar_chart, 'Expenses', 2),
          _buildNavItem(Icons.store, 'Stores', 3),
          _buildNavItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
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
}
