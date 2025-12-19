import 'package:flutter/foundation.dart';
import 'grocery_store_api_service.dart';
import '../models/grocery_store_product.dart';

/// Unified Grocery Catalog Service
/// Aggregates products from all Malaysian grocery stores into a single catalog
/// Makes it feel like browsing one unified online grocery store
class UnifiedGroceryCatalogService {
  final GroceryStoreApiService _groceryService = GroceryStoreApiService();

  /// Get trending/popular products with promotions from all stores
  /// Returns products that have discounts or promotions
  Future<List<UnifiedProduct>> getTrendingProducts({int limit = 20}) async {
    try {
      // Search for popular grocery items across all stores
      final popularQueries = [
        'milk',
        'bread',
        'eggs',
        'chicken',
        'rice',
        'oil',
        'vegetables',
        'fruits',
        'yogurt',
        'cheese',
        'promotion',
        'sale',
        'discount',
        'offer',
      ];

      final List<GroceryStoreProduct> allProducts = [];

      // Search all popular items in parallel
      final searches = popularQueries.map((query) => _groceryService.searchProducts(query));
      final results = await Future.wait(searches);

      for (var products in results) {
        allProducts.addAll(products);
      }

      // Filter products with promotions (have originalPrice or discount indicators)
      final productsWithPromotions = allProducts.where((product) {
        // Check if product has original price (indicating discount)
        if (product.originalPrice != null && product.originalPrice!.isNotEmpty) {
          try {
            final originalPrice = double.tryParse(product.originalPrice!.replaceAll(RegExp(r'[^\d.]'), ''));
            if (originalPrice != null && originalPrice > product.price) {
              return true; // Has discount
            }
          } catch (e) {
            // Continue checking
          }
        }
        
        // Check product name for promotion keywords
        final nameLower = product.name.toLowerCase();
        if (nameLower.contains('promo') || 
            nameLower.contains('sale') || 
            nameLower.contains('discount') ||
            nameLower.contains('offer') ||
            nameLower.contains('% off')) {
          return true;
        }
        
        return false;
      }).toList();

      // If we have products with promotions, use them; otherwise use all products
      final productsToUse = productsWithPromotions.isNotEmpty 
          ? productsWithPromotions 
          : allProducts;

      // Group by product name and create unified products
      final unifiedProducts = _createUnifiedProducts(productsToUse, limit: limit * 2);
      
      // Sort by max savings percentage (best deals first)
      unifiedProducts.sort((a, b) => b.maxSavingsPercentage.compareTo(a.maxSavingsPercentage));
      
      return unifiedProducts.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting trending products: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<UnifiedProduct>> getProductsByCategory(String category, {int limit = 20}) async {
    try {
      final products = await _groceryService.searchProducts(category);
      return _createUnifiedProducts(products, limit: limit);
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  /// Get all products (browse catalog)
  Future<List<UnifiedProduct>> browseAllProducts({
    String? searchQuery,
    String? category,
    int limit = 50,
  }) async {
    try {
      List<GroceryStoreProduct> products;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        products = await _groceryService.searchProducts(searchQuery);
      } else if (category != null) {
        products = await _groceryService.searchProducts(category);
      } else {
        // Get a mix of products from different categories
        final categories = ['milk', 'bread', 'chicken', 'vegetables', 'fruits', 'rice'];
        final searches = categories.map((cat) => _groceryService.searchProducts(cat));
        final results = await Future.wait(searches);
        products = [];
        for (var result in results) {
          products.addAll(result);
        }
      }

      return _createUnifiedProducts(products, limit: limit);
    } catch (e) {
      debugPrint('Error browsing products: $e');
      return [];
    }
  }

  /// Get product categories
  List<String> getCategories() {
    return [
      'Fruits & Vegetables',
      'Meat & Seafood',
      'Dairy & Eggs',
      'Beverages',
      'Snacks & Sweets',
      'Pantry Staples',
      'Frozen Foods',
      'Health & Beauty',
      'Household Items',
    ];
  }

  /// Create unified products from grocery store products
  /// Groups same products from different stores together
  List<UnifiedProduct> _createUnifiedProducts(
    List<GroceryStoreProduct> products, {
    int limit = 50,
  }) {
    // Group products by name (normalized)
    final Map<String, List<GroceryStoreProduct>> productsByName = {};

    for (var product in products) {
      final key = _normalizeProductName(product.name);
      if (!productsByName.containsKey(key)) {
        productsByName[key] = [];
      }
      productsByName[key]!.add(product);
    }

    // Create unified products
    final List<UnifiedProduct> unifiedProducts = [];

    for (var entry in productsByName.entries) {
      final storeProducts = entry.value;
      if (storeProducts.isEmpty) continue;

      // Sort by price (lowest first)
      storeProducts.sort((a, b) => a.price.compareTo(b.price));

      final cheapest = storeProducts.first;
      final mostExpensive = storeProducts.last;

      // Find the best image URL - prioritize products with complete image URLs
      String? bestImageUrl;
      String? bestDescription;
      String? bestBrand;
      String? bestUnit;
      
      // First, try to find a product with a complete image URL
      for (var product in storeProducts) {
        if (product.imageUrl.isNotEmpty && 
            product.imageUrl.startsWith('http')) {
          bestImageUrl = product.imageUrl;
          if (product.description != null && product.description!.isNotEmpty) {
            bestDescription = product.description;
          }
          if (product.brand != null && product.brand!.isNotEmpty) {
            bestBrand = product.brand;
          }
          if (product.unit != null && product.unit!.isNotEmpty) {
            bestUnit = product.unit;
          }
          break; // Use the first product with a complete image URL
        }
      }
      
      // If no complete image URL found, try to fix incomplete ones
      if (bestImageUrl == null || bestImageUrl.isEmpty) {
        for (var product in storeProducts) {
          if (product.imageUrl.isNotEmpty) {
            var imageUrl = product.imageUrl;
            // Try to make it a complete URL if it's not
            if (!imageUrl.startsWith('http')) {
              // Try common base URLs based on store
              switch (product.storeName.toLowerCase()) {
                case 'tesco':
                  imageUrl = 'https://www.tesco.com.my$imageUrl';
                  break;
                case 'giant':
                  imageUrl = 'https://www.giant.com.my$imageUrl';
                  break;
                case 'aeon':
                  imageUrl = 'https://www.aeon.com.my$imageUrl';
                  break;
                case 'nsk':
                  imageUrl = 'https://www.nskgrocer.com$imageUrl';
                  break;
                case 'village grocer':
                  imageUrl = 'https://www.villagegrocer.com$imageUrl';
                  break;
                case 'jaya grocer':
                  imageUrl = 'https://www.jayagrocer.com$imageUrl';
                  break;
                case 'happyfresh':
                  imageUrl = 'https://www.happyfresh.my$imageUrl';
                  break;
                case 'pandamart':
                  imageUrl = 'https://www.foodpanda.com.my$imageUrl';
                  break;
                case 'lotus\'s':
                case 'lotus':
                  imageUrl = 'https://www.lotuss.com.my$imageUrl';
                  break;
                case 'b.i.g':
                case 'big':
                  imageUrl = 'https://www.big.com.my$imageUrl';
                  break;
                case 'cold storage':
                  imageUrl = 'https://www.coldstorage.com.my$imageUrl';
                  break;
                case 'mercato':
                  imageUrl = 'https://www.mercato.com.my$imageUrl';
                  break;
                case 'redmart':
                  imageUrl = 'https://www.redmart.com$imageUrl';
                  break;
                case 'the food purveyor':
                  imageUrl = 'https://www.thefoodpurveyor.com$imageUrl';
                  break;
              }
            }
            if (imageUrl.startsWith('http')) {
              bestImageUrl = imageUrl;
              if (product.description != null && product.description!.isNotEmpty) {
                bestDescription = product.description;
              }
              if (product.brand != null && product.brand!.isNotEmpty) {
                bestBrand = product.brand;
              }
              if (product.unit != null && product.unit!.isNotEmpty) {
                bestUnit = product.unit;
              }
              break;
            }
          }
        }
      }
      
      // Fallback to cheapest product's image if still no image found
      if (bestImageUrl == null || bestImageUrl.isEmpty) {
        if (cheapest.imageUrl.isNotEmpty) {
          // Try to fix the cheapest product's image URL if it's relative
          var fallbackUrl = cheapest.imageUrl;
          if (!fallbackUrl.startsWith('http')) {
            switch (cheapest.storeName.toLowerCase()) {
              case 'tesco':
                fallbackUrl = 'https://www.tesco.com.my$fallbackUrl';
                break;
              case 'giant':
                fallbackUrl = 'https://www.giant.com.my$fallbackUrl';
                break;
              case 'aeon':
                fallbackUrl = 'https://www.aeon.com.my$fallbackUrl';
                break;
              case 'nsk':
                fallbackUrl = 'https://www.nskgrocer.com$fallbackUrl';
                break;
              case 'village grocer':
                fallbackUrl = 'https://www.villagegrocer.com$fallbackUrl';
                break;
              case 'jaya grocer':
                fallbackUrl = 'https://www.jayagrocer.com$fallbackUrl';
                break;
              case 'happyfresh':
                fallbackUrl = 'https://www.happyfresh.my$fallbackUrl';
                break;
              case 'pandamart':
                fallbackUrl = 'https://www.foodpanda.com.my$fallbackUrl';
                break;
              case 'lotus\'s':
              case 'lotus':
                fallbackUrl = 'https://www.lotuss.com.my$fallbackUrl';
                break;
              case 'b.i.g':
              case 'big':
                fallbackUrl = 'https://www.big.com.my$fallbackUrl';
                break;
              case 'cold storage':
                fallbackUrl = 'https://www.coldstorage.com.my$fallbackUrl';
                break;
              case 'mercato':
                fallbackUrl = 'https://www.mercato.com.my$fallbackUrl';
                break;
              case 'redmart':
                fallbackUrl = 'https://www.redmart.com$fallbackUrl';
                break;
              case 'the food purveyor':
                fallbackUrl = 'https://www.thefoodpurveyor.com$fallbackUrl';
                break;
            }
          }
          if (fallbackUrl.startsWith('http')) {
            bestImageUrl = fallbackUrl;
          }
        }
      }
      if ((bestDescription == null || bestDescription.isEmpty) && cheapest.description != null) {
        bestDescription = cheapest.description;
      }
      if ((bestBrand == null || bestBrand.isEmpty) && cheapest.brand != null) {
        bestBrand = cheapest.brand;
      }
      if ((bestUnit == null || bestUnit.isEmpty) && cheapest.unit != null) {
        bestUnit = cheapest.unit;
      }

      // Get all store options
      final storeOptions = storeProducts.map((p) {
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

      unifiedProducts.add(UnifiedProduct(
        id: 'unified_${cheapest.id}',
        name: cheapest.name,
        category: cheapest.category ?? 'Grocery',
        imageUrl: bestImageUrl,
        description: bestDescription,
        brand: bestBrand,
        unit: bestUnit,
        cheapestPrice: cheapest.price,
        mostExpensivePrice: mostExpensive.price,
        averagePrice: storeProducts.map((p) => p.price).reduce((a, b) => a + b) / storeProducts.length,
        currency: cheapest.currency,
        storeCount: storeProducts.length,
        storeOptions: storeOptions,
        inStock: storeProducts.any((p) => p.inStock),
        rating: cheapest.rating,
        reviewCount: cheapest.reviewCount,
      ));
    }

    // Sort by cheapest price
    unifiedProducts.sort((a, b) => a.cheapestPrice.compareTo(b.cheapestPrice));

    return unifiedProducts.take(limit).toList();
  }

  /// Normalize product name for grouping
  String _normalizeProductName(String name) {
    return name.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
  }
}

/// Unified Product Model
/// Represents a product available from multiple stores
class UnifiedProduct {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final String? description;
  final String? brand;
  final String? unit;
  final double cheapestPrice;
  final double mostExpensivePrice;
  final double averagePrice;
  final String currency;
  final int storeCount;
  final List<StoreOption> storeOptions;
  final bool inStock;
  final double? rating;
  final int? reviewCount;

  UnifiedProduct({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    this.description,
    this.brand,
    this.unit,
    required this.cheapestPrice,
    required this.mostExpensivePrice,
    required this.averagePrice,
    required this.currency,
    required this.storeCount,
    required this.storeOptions,
    required this.inStock,
    this.rating,
    this.reviewCount,
  });

  /// Get the cheapest store option
  StoreOption get cheapestStore => storeOptions.first;

  /// Check if product has discount (price variation)
  bool get hasPriceVariation => mostExpensivePrice > cheapestPrice;

  /// Get discount percentage (savings from cheapest to most expensive)
  double get maxSavingsPercentage {
    if (mostExpensivePrice == 0) return 0;
    return ((mostExpensivePrice - cheapestPrice) / mostExpensivePrice) * 100;
  }
}

/// Store Option Model
/// Represents a product available at a specific store
class StoreOption {
  final String storeName;
  final double price;
  final String currency;
  final String? productUrl;
  final bool inStock;
  final double? rating;
  final int? reviewCount;

  StoreOption({
    required this.storeName,
    required this.price,
    required this.currency,
    this.productUrl,
    required this.inStock,
    this.rating,
    this.reviewCount,
  });
}

