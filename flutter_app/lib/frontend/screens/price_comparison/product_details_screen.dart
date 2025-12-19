import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../backend/services/price_comparison_service.dart';
import '../../../backend/services/wishlist_service.dart';
import '../../../backend/models/price.dart';
import '../../../backend/models/store.dart';
import '../../../backend/models/grocery_store_product.dart';
import '../../../backend/models/wishlist_item.dart';
import '../../../backend/services/grocery_store_api_service.dart';
import '../../widgets/product_image_widget.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../config/app_routes.dart';

// Figma Design Colors
const Color kProductRed = Color(0xFFE85D5D);
const Color kProductWhite = Color(0xFFFFFFFF);
const Color kProductBackground = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBorderGray = Color(0xFFE5E7EB);

// Store Price Model
class StorePrice {
  final String name;
  final String price;
  final String? originalPrice;
  final String? shipping;
  final String delivery;
  final String? storeImage;
  final String? storeUrl; // URL to open the store

  StorePrice({
    required this.name,
    required this.price,
    this.originalPrice,
    this.shipping,
    required this.delivery,
    this.storeImage,
    this.storeUrl,
  });
}

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isWishlisted = false;
  bool _showTargetPriceModal = false;
  final _targetPriceController = TextEditingController();
  final PriceComparisonService _priceService = PriceComparisonService();
  final GroceryStoreApiService _groceryService = GroceryStoreApiService();
  final WishlistService _wishlistService = WishlistService();
  
  bool _isLoadingPrices = true;
  List<StorePrice> _stores = [];
  bool _canSetAlert = false; // Track if target price is valid
  String? _productImageUrl; // Store product image from grocery stores
  Map<String, dynamic>? _productData; // Store product data from grocery stores
  bool _isSavingWishlist = false; // Track if saving wishlist item

  @override
  void initState() {
    super.initState();
    _loadRealPrices();
    // Listen to target price text changes
    _targetPriceController.addListener(_onTargetPriceChanged);
  }

  void _onTargetPriceChanged() {
    final text = _targetPriceController.text.trim();
    final isValid = text.isNotEmpty && double.tryParse(text) != null;
    if (_canSetAlert != isValid) {
      setState(() {
        _canSetAlert = isValid;
      });
    }
  }

  // Product data based on productId - use real data if available
  Map<String, dynamic> get _product {
    if (_productData != null) {
      return _productData!;
    }
    return _getProductData(widget.productId);
  }

  // Load real prices from grocery stores
  Future<void> _loadRealPrices() async {
    setState(() => _isLoadingPrices = true);
    
    try {
      debugPrint('🔍 Loading prices for: ${widget.productName} (ID: ${widget.productId})');
      
      // Normalize product name for better matching
      final normalizedProductName = widget.productName.toLowerCase().trim();
      
      // Search for the product by name to get real data from grocery stores
      final groceryProducts = await _groceryService.searchProducts(widget.productName);
      debugPrint('📦 Found ${groceryProducts.length} grocery products');
      
      // Filter products to match the product name more accurately
      // This ensures we only use products that closely match the selected product
      final matchedProducts = groceryProducts.where((product) {
        final productNameLower = product.name.toLowerCase().trim();
        // Check if product name contains key words from the search query
        final searchWords = normalizedProductName.split(' ').where((w) => w.length > 2).toList();
        if (searchWords.isEmpty) return true; // If no meaningful words, include all
        
        // Product matches if it contains at least 50% of the search words
        final matchingWords = searchWords.where((word) => productNameLower.contains(word)).length;
        return matchingWords >= (searchWords.length * 0.5).ceil();
      }).toList();
      
      debugPrint('🎯 Filtered to ${matchedProducts.length} closely matched products');
      
      // Extract product image and data from best matching grocery product
      if (matchedProducts.isNotEmpty) {
        // Sort by name similarity to get the best match first
        matchedProducts.sort((a, b) {
          final aSimilarity = _calculateNameSimilarity(normalizedProductName, a.name.toLowerCase());
          final bSimilarity = _calculateNameSimilarity(normalizedProductName, b.name.toLowerCase());
          return bSimilarity.compareTo(aSimilarity); // Higher similarity first
        });
        
        final bestMatch = matchedProducts.first;
        _productImageUrl = bestMatch.imageUrl;
        _productData = {
          'name': bestMatch.name,
          'subtitle': bestMatch.unit ?? '',
          'image': bestMatch.imageUrl,
          'rating': bestMatch.rating ?? 0.0,
          'reviews': bestMatch.reviewCount ?? 0,
        };
        debugPrint('✅ Loaded product data: ${_productData!['name']}, Image: $_productImageUrl');
      } else if (groceryProducts.isNotEmpty) {
        // Fallback to first product if no close matches
        final firstProduct = groceryProducts.first;
        _productImageUrl = firstProduct.imageUrl;
        _productData = {
          'name': firstProduct.name,
          'subtitle': firstProduct.unit ?? '',
          'image': firstProduct.imageUrl,
          'rating': firstProduct.rating ?? 0.0,
          'reviews': firstProduct.reviewCount ?? 0,
        };
        debugPrint('⚠️ Using first product as fallback: ${_productData!['name']}');
      } else {
        debugPrint('⚠️ No grocery products found, using fallback data');
      }
      
      // Convert matched grocery products to StorePrice format
      // Group by store name to avoid duplicates and use the best match for each store
      final Map<String, GroceryStoreProduct> bestProductPerStore = {};
      
      for (var product in matchedProducts.isNotEmpty ? matchedProducts : groceryProducts) {
        if (product.price <= 0) continue; // Skip invalid prices
        
        final storeName = product.storeName;
        // Keep the product with the best name match for each store
        if (!bestProductPerStore.containsKey(storeName)) {
          bestProductPerStore[storeName] = product;
        } else {
          final existing = bestProductPerStore[storeName]!;
          final existingSimilarity = _calculateNameSimilarity(normalizedProductName, existing.name.toLowerCase());
          final currentSimilarity = _calculateNameSimilarity(normalizedProductName, product.name.toLowerCase());
          
          if (currentSimilarity > existingSimilarity) {
            bestProductPerStore[storeName] = product;
          }
        }
      }
      
      if (bestProductPerStore.isNotEmpty) {
        _stores = bestProductPerStore.values.map((groceryProduct) {
          debugPrint('🏪 Store: ${groceryProduct.storeName}, Product: ${groceryProduct.name}, Price: RM${groceryProduct.price}, URL: ${groceryProduct.productUrl}');
          
          return StorePrice(
            name: groceryProduct.storeName,
            price: 'RM${groceryProduct.price.toStringAsFixed(2)}',
            shipping: null,
            delivery: groceryProduct.inStock ? 'In Stock' : 'Check availability',
            storeUrl: groceryProduct.productUrl, // This is the specific product URL
          );
        }).toList();
        
        // Sort stores by price (cheapest first) - extract numeric price for sorting
        _stores.sort((a, b) {
          final aPrice = double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          final bPrice = double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          return aPrice.compareTo(bPrice);
        });
        
        debugPrint('✅ Created ${_stores.length} store prices sorted by price (cheapest first)');
      } else {
        debugPrint('⚠️ No valid grocery products found for: ${widget.productName}');
      }
      
      // Also try to get price comparison from Firestore (for local stores)
      try {
        final comparison = await _priceService.getPriceComparison(widget.productId);
        
        if (comparison['prices'] != null && (comparison['prices'] as List).isNotEmpty) {
          final firestoreStores = (comparison['prices'] as List).map((item) {
            final store = item['store'] as Store?;
            final price = item['price'] as Price?;
            final isAvailable = item['isAvailable'] as bool? ?? true;
            
            // Get product URL from grocery product if available
            final productUrl = item['productUrl'] as String?;
            final groceryProduct = item['groceryProduct'];
            
            String? storeUrl;
            
            if (productUrl != null && productUrl.isNotEmpty) {
              storeUrl = productUrl;
            } else if (groceryProduct != null) {
              try {
                if (groceryProduct is GroceryStoreProduct) {
                  storeUrl = groceryProduct.productUrl;
                } else if (groceryProduct is Map) {
                  storeUrl = groceryProduct['productUrl'] as String?;
                }
              } catch (e) {
                debugPrint('Error extracting product URL: $e');
              }
            }
            
            if (storeUrl == null || storeUrl.isEmpty) {
              storeUrl = store?.website;
            }
            
            return StorePrice(
              name: store?.name ?? 'Unknown Store',
              price: price != null ? 'RM${price.price.toStringAsFixed(2)}' : 'RM0.00',
              shipping: null,
              delivery: isAvailable ? 'In Stock' : 'Check availability',
              storeUrl: storeUrl,
            );
          }).toList();
          
          // Merge Firestore stores with grocery stores (avoid duplicates)
          for (var fsStore in firestoreStores) {
            if (!_stores.any((s) => s.name == fsStore.name)) {
              _stores.add(fsStore);
            }
          }
          
          // Re-sort all stores by price after merging
          _stores.sort((a, b) {
            final aPrice = double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
            final bPrice = double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
            return aPrice.compareTo(bPrice);
          });
        }
      } catch (e) {
        debugPrint('⚠️ Error getting Firestore prices: $e');
      }
      
      // If still no prices found, use fallback hardcoded prices
      if (_stores.isEmpty) {
        debugPrint('⚠️ No prices found, using fallback');
        _stores = _getStorePrices(widget.productId);
      }
    } catch (e) {
      debugPrint('❌ Error loading real prices: $e');
      // Fallback to hardcoded prices on error
      _stores = _getStorePrices(widget.productId);
    } finally {
      setState(() => _isLoadingPrices = false);
    }
  }

  // Get product data based on productId
  Map<String, dynamic> _getProductData(String productId) {
    final productMap = {
      '1': {
    'name': 'Organic Whole Milk',
    'subtitle': '(1 Gallon)',
    'rating': 4.51,
    'reviews': 78,
    'image': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=600&h=600&fit=crop',
      },
      '2': {
        'name': 'Fresh Salmon Fillet',
        'subtitle': '(500g)',
        'rating': 4.8,
        'reviews': 124,
        'image': 'https://images.unsplash.com/photo-1574781330855-d0db8cc6a79c?w=600&h=600&fit=crop',
      },
      '7': {
        'name': 'Fresh Avocados',
        'subtitle': '(Pack of 4)',
        'rating': 4.6,
        'reviews': 89,
        'image': 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=600&h=600&fit=crop',
      },
      '11': {
        'name': 'Fresh Strawberries',
        'subtitle': '(250g)',
        'rating': 4.5,
        'reviews': 67,
        'image': 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=600&h=600&fit=crop',
      },
      '12': {
        'name': 'Chicken Breast',
        'subtitle': '(1lb)',
        'rating': 4.4,
        'reviews': 156,
        'image': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=600&h=600&fit=crop',
      },
    };

    // Default product data
    return productMap[productId] ?? {
      'name': widget.productName.isNotEmpty ? widget.productName : 'Product',
      'subtitle': '',
      'rating': 4.0,
      'reviews': 0,
      'image': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=600&h=600&fit=crop',
    };
  }

  // Get store prices based on productId
  List<StorePrice> _getStorePrices(String productId) {
    final storeMap = {
      '1': [
    StorePrice(
      name: 'Jaya Grocer (Delivery)',
      price: 'RM9.90',
      originalPrice: 'RM12.00',
      shipping: 'RM4.99',
      delivery: 'Est. Delivery: Tomorrow',
          storeUrl: 'https://www.jayagrocer.com',
    ),
    StorePrice(
      name: 'AEON',
      price: 'RM18.50',
      delivery: 'Family Pack (bulk)',
          storeUrl: 'https://www.aeonretail.com.my',
    ),
    StorePrice(
      name: 'Village Grocer',
      price: 'RM9.90',
      shipping: 'RM4.99',
      delivery: 'Est. Delivery: Tomorrow',
          storeUrl: 'https://www.villagegrocer.com',
        ),
      ],
      '7': [
        StorePrice(
          name: 'Jaya Grocer (Delivery)',
          price: 'RM4.99',
          originalPrice: 'RM6.99',
          shipping: 'RM4.99',
          delivery: 'Est. Delivery: Tomorrow',
          storeUrl: 'https://www.jayagrocer.com',
        ),
        StorePrice(
          name: 'AEON',
          price: 'RM5.50',
          delivery: 'In-store only',
          storeUrl: 'https://www.aeonretail.com.my',
        ),
        StorePrice(
          name: 'Village Grocer',
          price: 'RM5.90',
          shipping: 'RM4.99',
          delivery: 'Est. Delivery: Tomorrow',
          storeUrl: 'https://www.villagegrocer.com',
        ),
        StorePrice(
          name: 'NSK Grocer',
          price: 'RM4.50',
          delivery: 'In-store only',
          storeUrl: 'https://www.nskgrocer.com',
        ),
      ],
      '11': [
        StorePrice(
          name: 'Jaya Grocer (Delivery)',
          price: 'RM4.49',
          shipping: 'RM4.99',
          delivery: 'Est. Delivery: Tomorrow',
          storeUrl: 'https://www.jayagrocer.com',
        ),
        StorePrice(
          name: 'AEON',
          price: 'RM5.00',
          delivery: 'In-store only',
          storeUrl: 'https://www.aeonretail.com.my',
        ),
      ],
      '2': [
        StorePrice(
          name: 'Jaya Grocer (Delivery)',
          price: 'RM24.90',
          shipping: 'RM4.99',
          delivery: 'Est. Delivery: Tomorrow',
          storeUrl: 'https://www.jayagrocer.com',
        ),
        StorePrice(
          name: 'AEON',
          price: 'RM22.50',
          delivery: 'In-store only',
          storeUrl: 'https://www.aeonretail.com.my',
        ),
      ],
    };

    return storeMap[productId] ?? [
      StorePrice(
        name: 'Jaya Grocer',
        price: 'RM0.00',
        delivery: 'Check availability',
        storeUrl: 'https://www.jayagrocer.com',
      ),
    ];
  }

  @override
  void dispose() {
    _targetPriceController.removeListener(_onTargetPriceChanged);
    _targetPriceController.dispose();
    super.dispose();
  }

  void _handleWishlistClick() {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user == null || user.isAnonymous;
    
    if (isGuest) {
      // Redirect guest to profile screen to sign up/login
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.profile,
        (route) => false,
      );
      return;
    }
    
    if (!_isWishlisted) {
      // Show Yes/No dialog first
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add to Wishlist'),
          content: const Text('Do you want to set a target price for this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Just add to wishlist without target price
                _addToWishlistWithoutTargetPrice();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
      setState(() {
        _isWishlisted = true;
        _showTargetPriceModal = true;
      });
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _isWishlisted = false;
      });
      // Remove from wishlist
      _removeFromWishlist();
    }
  }

  Future<void> _addToWishlistWithoutTargetPrice() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to add to wishlist')),
        );
      }
      return;
    }

    try {
      final productName = widget.productName;
      final productImage = _productImageUrl ?? _product['image'] as String? ?? '';

      final wishlistItem = WishlistItem(
        id: '',
        userId: user.uid,
        productId: widget.productId,
        productName: productName,
        productImageUrl: productImage.isNotEmpty ? productImage : null,
        targetPrice: 0.0, // No target price set (0 means no alert)
        currency: 'MYR',
        isActive: true,
        preferredStores: _stores.map((s) => s.name).toList(),
        notes: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastNotifiedAt: null,
      );

      await _wishlistService.addToWishlist(wishlistItem);
      
      if (mounted) {
        setState(() {
          _isWishlisted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to wishlist')),
        );
      }
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add to wishlist')),
        );
      }
    }
  }

  Future<void> _removeFromWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final wishlistItems = await _wishlistService.getUserWishlist(user.uid);
      final item = wishlistItems.firstWhere(
        (item) => item.productId == widget.productId,
        orElse: () => wishlistItems.first,
      );
      
      if (item.id.isNotEmpty) {
        await _wishlistService.removeFromWishlist(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from wishlist')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
    }
  }

  Future<void> _handleSetTargetPrice() async {
    if (_targetPriceController.text.isEmpty) return;
    
    final targetPriceText = _targetPriceController.text.trim();
    final targetPrice = double.tryParse(targetPriceText);
    
    if (targetPrice == null || targetPrice <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid price')),
        );
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to add to wishlist')),
        );
      }
      return;
    }

    setState(() {
      _isSavingWishlist = true;
    });

    try {
      // Get current product data
      final productName = widget.productName;
      final productImage = _productImageUrl ?? _product['image'] as String? ?? '';

      // Create wishlist item
      final wishlistItem = WishlistItem(
        id: '', // Will be set by Firestore
        userId: user.uid,
        productId: widget.productId,
        productName: productName,
        productImageUrl: productImage.isNotEmpty ? productImage : null,
        targetPrice: targetPrice,
        currency: 'MYR',
        isActive: true,
        preferredStores: _stores.map((s) => s.name).toList(),
        notes: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastNotifiedAt: null,
      );

      // Save to Firestore
      await _wishlistService.addToWishlist(wishlistItem);
      
      debugPrint('✅ Wishlist item saved: $productName, Target: RM$targetPrice');

      if (mounted) {
      setState(() {
        _showTargetPriceModal = false;
          _targetPriceController.clear();
          _isSavingWishlist = false;
          _isWishlisted = true;
      });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Price alert set! You\'ll be notified when $productName drops to RM${targetPrice.toStringAsFixed(2)}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to product screen after setting target price
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Error saving wishlist item: $e');
      if (mounted) {
        setState(() {
          _isSavingWishlist = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving wishlist: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Calculate similarity between two strings (simple Levenshtein-like approach)
  int _calculateNameSimilarity(String str1, String str2) {
    if (str1 == str2) return 100;
    if (str1.isEmpty || str2.isEmpty) return 0;
    
    // Check if one contains the other
    if (str1.contains(str2) || str2.contains(str1)) {
      return 80;
    }
    
    // Count common words
    final words1 = str1.split(' ').where((w) => w.length > 2).toSet();
    final words2 = str2.split(' ').where((w) => w.length > 2).toSet();
    final commonWords = words1.intersection(words2).length;
    final totalWords = words1.union(words2).length;
    
    if (totalWords == 0) return 0;
    return (commonWords / totalWords * 100).round();
  }

  /// Get Google Maps search query for a store name
  String _getStoreMapsQuery(String storeName) {
    final storeNameLower = storeName.toLowerCase();
    
    // Map store names to their Google Maps search queries
    if (storeNameLower.contains('nsk') || storeNameLower.contains('nsk grocer')) {
      return 'NSK Grocer Malaysia';
    } else if (storeNameLower.contains('jaya grocer') || storeNameLower.contains('jayagrocer')) {
      return 'Jaya Grocer Malaysia';
    } else if (storeNameLower.contains('lotus')) {
      return 'Lotus Malaysia';
    } else if (storeNameLower.contains('mydin')) {
      return 'Mydin Malaysia';
    } else if (storeNameLower.contains('village grocer')) {
      return 'Village Grocer Malaysia';
    } else if (storeNameLower.contains('aeon')) {
      return 'AEON Malaysia';
    } else if (storeNameLower.contains('tesco')) {
      return 'Tesco Malaysia';
    } else if (storeNameLower.contains('giant')) {
      return 'Giant Malaysia';
    } else if (storeNameLower.contains('speedmart') || storeNameLower.contains('99')) {
      return '99 Speedmart Malaysia';
    } else if (storeNameLower.contains('econsave')) {
      return 'Econsave Malaysia';
    } else if (storeNameLower.contains('cold storage')) {
      return 'Cold Storage Malaysia';
    } else if (storeNameLower.contains('big') || storeNameLower.contains('ben')) {
      return 'B.I.G Malaysia';
    } else {
      // Default: use store name as-is
      return '$storeName Malaysia';
    }
  }

  /// Open Google Maps with nearest store location
  Future<void> _openNearestStoreOnMaps(String storeName) async {
    try {
      final searchQuery = _getStoreMapsQuery(storeName);
      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}',
      );
      
      debugPrint('🗺️ Opening Google Maps for nearest $storeName: $searchQuery');
      
      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
        debugPrint('✅ Successfully opened Google Maps');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Showing nearest $storeName locations on Google Maps'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open Google Maps. Please check your internet connection.'),
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

  Future<void> _openStoreUrl(String? url, String storeName) async {
    // If no URL provided, directly open Google Maps
    if (url == null || url.isEmpty) {
      debugPrint('⚠️ No store URL available, opening Google Maps for nearest store');
      await _openNearestStoreOnMaps(storeName);
      return;
    }

    try {
      // Ensure URL has proper protocol
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }
      
      debugPrint('🌐 Attempting to open store URL: $finalUrl');
      
      final uri = Uri.parse(finalUrl);
      
      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          debugPrint('✅ Successfully opened URL: $finalUrl');
          return; // Success, exit early
        } catch (e) {
          debugPrint('⚠️ Error launching URL, falling back to Google Maps: $e');
          // Fall through to Google Maps fallback
        }
      } else {
        debugPrint('⚠️ URL cannot be launched, falling back to Google Maps');
        // Fall through to Google Maps fallback
      }
      
      // If we reach here, the URL couldn't be opened - fallback to Google Maps
      debugPrint('🗺️ Falling back to Google Maps for nearest $storeName');
      await _openNearestStoreOnMaps(storeName);
      
    } catch (e) {
      debugPrint('❌ Error opening store URL: $e');
      // On any error, try Google Maps as fallback
      await _openNearestStoreOnMaps(storeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate price statistics
    final prices = _stores.map((s) {
      final priceStr = s.price.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(priceStr) ?? 0.0;
    }).where((p) => p > 0).toList();
    
    final lowestPrice = prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0;
    final averagePrice = prices.isNotEmpty ? prices.reduce((a, b) => a + b) / prices.length : 0.0;
    final usualPrice = averagePrice; // Use average as "usually" price
    
    // Get product unit for per-unit price calculation
    final productUnit = _productData?['unit'] as String? ?? _product['subtitle'] as String? ?? '';
    
    return Scaffold(
      backgroundColor: kProductBackground,
      appBar: AppBar(
        backgroundColor: kProductWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: kTextDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              _buildProductImage(),
              const SizedBox(height: 20),

              // Product Header (Brand, Name, Size)
              _buildProductHeader(),
              const SizedBox(height: 24),

              // Today's Price Section
              if (lowestPrice > 0) _buildTodaysPrice(lowestPrice, usualPrice),
              if (lowestPrice > 0) const SizedBox(height: 24),

              // Where To Buy Section
              _buildWhereToBuySection(productUnit),
              const SizedBox(height: 24),

              // Product Details Section
              _buildProductDetailsSection(),
              const SizedBox(height: 24),

              // Reviews Section
              _buildReviewsSection(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      // Target Price Modal
      bottomSheet: _showTargetPriceModal ? _buildTargetPriceModal() : null,
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildProductImage() {
    // Use real product image if available, otherwise fallback to hardcoded
    final imageUrl = _productImageUrl ?? _product['image'] as String? ?? '';
    
    debugPrint('🖼️ Building product image. URL: $imageUrl, Has URL: ${imageUrl.isNotEmpty}');
    
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: ProductImageWidget(
              imageUrl: imageUrl,
              productName: (_product as Map<String, dynamic>?)?['name'] as String? ?? 'Product',
              brand: (_product as Map<String, dynamic>?)?['brand'] as String?,
              fit: BoxFit.contain,
              borderRadius: 16.0,
              backgroundColor: Colors.grey[200],
              fallbackIcon: Icons.shopping_bag,
              fallbackIconSize: 80,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: _handleWishlistClick,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kProductWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: _isWishlisted ? kProductRed : kTextLight,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    final brand = _productData?['brand'] as String?;
    final productName = _productData?['name'] as String? ?? _product['name'] as String;
    final unit = _productData?['unit'] as String? ?? _product['subtitle'] as String? ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Name
        if (brand != null && brand.isNotEmpty) ...[
          Text(
            brand,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextLight,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Product Name
        Text(
          productName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kTextDark,
            fontFamily: 'Roboto',
          ),
        ),
        // Unit/Size
        if (unit.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 16,
              color: kTextLight,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTodaysPrice(double lowestPrice, double usualPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Price",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lowest',
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextLight,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MYR ${lowestPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kProductRed,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: kBorderGray,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Usually',
                        style: TextStyle(
                          fontSize: 12,
                          color: kTextLight,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MYR ${usualPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhereToBuySection(String productUnit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where To Buy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kTextDark,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingPrices)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_stores.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No stores available',
                style: TextStyle(color: kTextLight),
              ),
            ),
          )
        else
          ..._stores.asMap().entries.map((entry) {
            final index = entry.key;
            final store = entry.value;
            final isCheapest = index == 0; // First store is cheapest (sorted)
            return _buildTrolleyStoreCard(store, productUnit, isCheapest);
          }),
        const SizedBox(height: 8),
        Text(
          'The prices shown above are available online and may not reflect in store.',
          style: TextStyle(
            fontSize: 11,
            color: kTextLight,
            fontStyle: FontStyle.italic,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  Widget _buildTrolleyStoreCard(StorePrice store, String productUnit, bool isCheapest) {
    // Parse prices
    final priceStr = store.price.replaceAll(RegExp(r'[^\d.]'), '');
    final price = double.tryParse(priceStr) ?? 0.0;
    final originalPriceStr = store.originalPrice?.replaceAll(RegExp(r'[^\d.]'), '') ?? '';
    final originalPrice = originalPriceStr.isNotEmpty ? double.tryParse(originalPriceStr) : null;
    
    // Calculate per-unit price if unit is available
    String? perUnitPrice;
    if (productUnit.isNotEmpty && price > 0) {
      // Extract numeric value from unit (e.g., "500g" -> 500, "1kg" -> 1000)
      final unitMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(kg|g|l|ml|piece|pieces)', caseSensitive: false).firstMatch(productUnit);
      if (unitMatch != null) {
        final unitValue = double.tryParse(unitMatch.group(1) ?? '') ?? 0;
        final unitType = unitMatch.group(2)?.toLowerCase() ?? '';
        double baseUnit = unitValue;
        if (unitType == 'kg') baseUnit = unitValue * 1000; // Convert kg to g
        if (unitType == 'l') baseUnit = unitValue * 1000; // Convert L to ml
        if (baseUnit > 0) {
          final per100g = (price / baseUnit) * 100;
          perUnitPrice = 'MYR ${per100g.toStringAsFixed(2)} per 100g';
        }
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: isCheapest ? Border.all(color: kProductRed, width: 2) : Border.all(color: kBorderGray),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Name
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'MYR ${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        if (originalPrice != null && originalPrice > price) ...[
                          const SizedBox(width: 8),
                          Text(
                            'MYR ${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: kTextLight,
                              decoration: TextDecoration.lineThrough,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Per Unit Price
                    if (perUnitPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        perUnitPrice,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kTextLight,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                    // Delivery Info
                    const SizedBox(height: 8),
                    Text(
                      store.delivery,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextLight,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              // Visit Button
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () => _openStoreUrl(store.storeUrl, store.name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kProductRed,
                    foregroundColor: kProductWhite,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'VISIT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsSection() {
    final description = _productData?['description'] as String? ?? 
                       'High quality product from trusted stores.';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good to know',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: kTextDark,
              fontFamily: 'Roboto',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final rating = _productData?['rating'] as double? ?? _product['rating'] as double? ?? 0.0;
    final reviewCount = _productData?['reviews'] as int? ?? _product['reviews'] as int? ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Icon(Icons.star, size: 20, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                '$reviewCount reviews from ${_stores.length} shops',
                style: const TextStyle(
                  fontSize: 12,
                  color: kTextLight,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildTargetPriceModal() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Set Target Price',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                    fontFamily: 'Roboto',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: kTextLight),
                  onPressed: () {
                    setState(() {
                      _showTargetPriceModal = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Get notified when the price drops to your target',
              style: TextStyle(
                fontSize: 14,
                color: kTextLight,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Target Price (RM)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kTextDark,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 8.50',
                filled: true,
                fillColor: kProductBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kProductRed, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSavingWishlist
                        ? null
                        : () {
                      setState(() {
                        _showTargetPriceModal = false;
                              _targetPriceController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorderGray),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: kTextDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_canSetAlert && !_isSavingWishlist) ? _handleSetTargetPrice : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kProductRed,
                      foregroundColor: kProductWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Set Alert',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
