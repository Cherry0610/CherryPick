import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details_screen.dart';
import '../../../backend/services/grocery_store_api_service.dart';
import '../../../backend/services/user_recommendation_service.dart';
import '../../../backend/models/grocery_store_product.dart';
import '../../widgets/product_image_widget.dart';
import '../../widgets/bottom_navigation_bar.dart';

// Figma Design Colors
const Color kSearchRed = Color(0xFFE85D5D);
const Color kSearchWhite = Color(0xFFFFFFFF);
const Color kSearchBackground = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBorderGray = Color(0xFFE5E7EB);
const Color kCheapestGreen = Color(0xFF10B981);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final GroceryStoreApiService _groceryService = GroceryStoreApiService();
  final UserRecommendationService _recommendationService = UserRecommendationService();
  
  final List<String> _searchHistory = [
    'Organic Milk',
    'Fresh Salmon',
    'Whole Wheat Bread',
    'Greek Yogurt',
    'Bananas',
  ];
  final List<String> _trendingSearches = [
    'Avocados',
    'Chicken Breast',
    'Brown Rice',
    'Almond Milk',
    'Fresh Berries',
    'Olive Oil',
  ];

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _sortBy = 'price'; // 'price', 'store', 'rating'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeFromHistory(String item) {
    setState(() {
      _searchHistory.remove(item);
    });
  }

  void _clearAllHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  // Search across all grocery stores with proper filtering
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Normalize search query
      final normalizedQuery = query.toLowerCase().trim();
      final queryWords = normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList();
      
      // Save search to user history
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous) {
        _recommendationService.saveSearchHistory(user.uid, query);
      }
      
      // Search all grocery stores simultaneously
      final groceryProducts = await _groceryService.searchProducts(query);
      
      // Filter products to ensure they're related to the search query
      final filteredProducts = groceryProducts.where((product) {
        final productName = product.name.toLowerCase();
        final productDescription = (product.description ?? '').toLowerCase();
        final productBrand = (product.brand ?? '').toLowerCase();
        final productCategory = (product.category ?? '').toLowerCase();
        
        // Check if any query word appears in product name, description, brand, or category
        for (var word in queryWords) {
          if (productName.contains(word) || 
              productDescription.contains(word) ||
              productBrand.contains(word) ||
              productCategory.contains(word)) {
            return true; // Product is related to search
          }
        }
        return false; // Product doesn't match search
      }).toList();
      
      debugPrint('✅ Search "$query": Found ${filteredProducts.length} related products out of ${groceryProducts.length} total');
      
      // Group products by normalized name (combine same products from different stores)
      final Map<String, List<GroceryStoreProduct>> productsByName = {};
      
      for (var product in filteredProducts) {
        // Normalize product name for grouping (remove extra spaces, special chars)
        final normalizedName = product.name
            .toLowerCase()
            .trim()
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .replaceAll(RegExp(r'\s+'), ' ');
        
        if (!productsByName.containsKey(normalizedName)) {
          productsByName[normalizedName] = [];
        }
        productsByName[normalizedName]!.add(product);
      }

      // Convert to unified results format
      final List<Map<String, dynamic>> results = [];
      
      for (var entry in productsByName.entries) {
        final products = entry.value;
        if (products.isEmpty) continue;

        // Sort stores by price (lowest first)
        products.sort((a, b) => a.price.compareTo(b.price));
        
        final cheapestProduct = products.first;
        final allStores = products.map((p) => {
          'storeName': p.storeName,
          'price': p.price,
          'currency': p.currency,
          'productUrl': p.productUrl,
          'inStock': p.inStock,
          'imageUrl': p.imageUrl,
        }).toList();

        // Use the best image available (prefer non-empty imageUrl)
        String? bestImageUrl;
        for (var p in products) {
          if (p.imageUrl.isNotEmpty) {
            bestImageUrl = p.imageUrl;
            break;
          }
        }

        results.add({
          'id': 'unified_${cheapestProduct.id}',
          'name': cheapestProduct.name,
          'image': bestImageUrl ?? '', // Use best available image
          'cheapestPrice': cheapestProduct.price,
          'currency': cheapestProduct.currency,
          'storeCount': products.length,
          'allStores': allStores,
          'cheapestStore': cheapestProduct.storeName,
          'rating': cheapestProduct.rating,
          'reviewCount': cheapestProduct.reviewCount,
        });
      }

      // Sort results based on selected sort option
      _sortResults(results);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching products: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _sortResults(List<Map<String, dynamic>> results) {
    switch (_sortBy) {
      case 'price':
        results.sort((a, b) => (a['cheapestPrice'] as double).compareTo(b['cheapestPrice'] as double));
        break;
      case 'store':
        results.sort((a, b) => (a['storeCount'] as int).compareTo(b['storeCount'] as int));
        break;
      case 'rating':
        results.sort((a, b) {
          final ratingA = a['rating'] as double? ?? 0.0;
          final ratingB = b['rating'] as double? ?? 0.0;
          return ratingB.compareTo(ratingA); // Descending
        });
        break;
    }
  }

  void _onProductClick(Map<String, dynamic> product) {
    // Use product name as ID if ID is not available or is a generic ID
    final productId = product['id'] as String? ?? product['name'] as String;
    final productName = product['name'] as String;
    
    debugPrint('🔍 Navigating to product: $productName (ID: $productId)');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          productId: productId,
          productName: productName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: kSearchBackground,
      appBar: AppBar(
        backgroundColor: kSearchWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Products',
          style: TextStyle(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 16),

              // Search History
              if (!hasQuery && _searchHistory.isNotEmpty) ...[
                _buildSearchHistory(),
                const SizedBox(height: 16),
              ],

              // Trending Searches
              if (!hasQuery) ...[
                _buildTrendingSearches(),
                const SizedBox(height: 16),
              ],

              // Search Results
              if (hasQuery) ...[
                if (_searchResults.isNotEmpty) _buildSortOptions(),
                _buildSearchResults(),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderGray),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (value) {
          setState(() {});
          // Debounce search
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              _performSearch(value);
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Search products across all stores...',
          hintStyle: const TextStyle(color: kTextLight),
          prefixIcon: const Icon(Icons.search, color: kTextLight),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kSearchRed),
                    ),
                  ),
                )
              : _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: kTextLight),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                        });
                      },
                    )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 20, color: kTextLight),
                const SizedBox(width: 8),
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _clearAllHistory,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: kSearchRed,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._searchHistory.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _searchController.text = item;
                      setState(() {});
                    },
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: kTextDark,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: kTextLight),
                  onPressed: () => _removeFromHistory(item),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrendingSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, size: 20, color: kSearchRed),
            const SizedBox(width: 8),
            const Text(
              'Trending Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextDark,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trendingSearches.map((item) {
            return GestureDetector(
              onTap: () {
                _searchController.text = item;
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: kTextDark,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 14,
              color: kTextLight,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                _buildSortChip('price', 'Price'),
                const SizedBox(width: 8),
                _buildSortChip('store', 'Stores'),
                const SizedBox(width: 8),
                _buildSortChip('rating', 'Rating'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
          _sortResults(_searchResults);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? kSearchRed : kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kSearchRed : kBorderGray,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : kTextDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kSearchRed),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
      children: [
              const Icon(Icons.search_off, size: 64, color: kTextLight),
              const SizedBox(height: 16),
        Text(
                'No products found',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kTextDark,
            fontFamily: 'Roboto',
          ),
        ),
              const SizedBox(height: 8),
              Text(
                'Try searching for something else',
                style: const TextStyle(
                  fontSize: 14,
                  color: kTextLight,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Found ${_searchResults.length} products across all stores',
              style: const TextStyle(
                fontSize: 14,
                color: kTextLight,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ..._searchResults.map((product) {
          return _buildUnifiedProductCard(product);
        }),
      ],
    );
  }

  Widget _buildUnifiedProductCard(Map<String, dynamic> product) {
    final allStores = product['allStores'] as List<dynamic>;
    final cheapestPrice = product['cheapestPrice'] as double;
    final currency = product['currency'] as String;
    final storeCount = product['storeCount'] as int;
    final cheapestStore = product['cheapestStore'] as String;

          return GestureDetector(
      onTap: () => _onProductClick(product),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderGray),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(
                    product['image'] as String? ?? '',
                    product['name'] as String,
                  ),
                  ),
                  const SizedBox(width: 12),
                // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        product['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kTextDark,
                            fontFamily: 'Roboto',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 6),
                      // Cheapest Price Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kCheapestGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_offer,
                              size: 14,
                              color: kCheapestGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Best: $currency ${cheapestPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: kCheapestGreen,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Store Count
                      Row(
                        children: [
                          const Icon(Icons.store, size: 14, color: kTextLight),
                          const SizedBox(width: 4),
                        Text(
                            '$storeCount stores available',
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
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Store Price List
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kSearchBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ...allStores.take(3).map((store) {
                    final isCheapest = store['storeName'] == cheapestStore;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isCheapest ? kCheapestGreen : kTextLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                        Text(
                                store['storeName'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isCheapest ? FontWeight.w600 : FontWeight.normal,
                                  color: isCheapest ? kCheapestGreen : kTextDark,
                            fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${store['currency']} ${store['price'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCheapest ? FontWeight.bold : FontWeight.normal,
                              color: isCheapest ? kCheapestGreen : kTextDark,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (storeCount > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+ ${storeCount - 3} more stores',
                        style: const TextStyle(
                          fontSize: 11,
                          color: kTextLight,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Roboto',
                        ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildProductImage(String imageUrl, String productName) {
    return ProductImageWidget(
      imageUrl: imageUrl,
      productName: productName,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      borderRadius: 8.0,
      backgroundColor: Colors.grey[200],
      fallbackIcon: Icons.shopping_bag,
      fallbackIconSize: 40,
    );
  }
}
