import 'package:flutter/foundation.dart';
import '../config/grocery_api_config.dart';
import '../models/grocery_store_product.dart';
import '../data/mock_grocery_data.dart';
import 'grocery_web_scraper.dart';

/// Service for integrating with multiple grocery store APIs
/// Similar to Trivago but for groceries - aggregates prices from multiple sources
class GroceryStoreApiService {
  final GroceryWebScraper _webScraper;
  final Map<String, List<GroceryStoreProduct>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  GroceryStoreApiService({GroceryWebScraper? webScraper})
    : _webScraper = webScraper ?? GroceryWebScraper();

  /// Search for products across all enabled grocery stores
  /// Returns a list of products from all stores, sorted by price
  /// Uses mock data for testing when web scraping is not available
  Future<List<GroceryStoreProduct>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];

    // First try to get mock data (for testing/development)
    final mockProducts = _getMockProductsForQuery(query);
    if (mockProducts.isNotEmpty) {
      debugPrint('📦 Using mock data for query: "$query" (${mockProducts.length} products)');
      return mockProducts;
    }

    // Check cache first
    if (_isCached(query)) {
      return _cache[query]!;
    }

    final List<GroceryStoreProduct> allProducts = [];

    // Search across all enabled stores in parallel
    final List<Future<List<GroceryStoreProduct>>> searches = [];

    if (GroceryApiConfig.enableShopee) {
      searches.add(_searchShopee(query));
    }
    if (GroceryApiConfig.enableLazada) {
      searches.add(_searchLazada(query));
    }
    if (GroceryApiConfig.enableGrabMart) {
      searches.add(_searchGrabMart(query));
    }
    if (GroceryApiConfig.enableTesco) {
      searches.add(_searchTesco(query));
    }
    if (GroceryApiConfig.enableGiant) {
      searches.add(_searchGiant(query));
    }
    if (GroceryApiConfig.enableAeon) {
      searches.add(_searchAeon(query));
    }
    if (GroceryApiConfig.enableAeonBig) {
      searches.add(_searchAeonBig(query));
    }
    if (GroceryApiConfig.enableNsk) {
      searches.add(_searchNsk(query));
    }
    if (GroceryApiConfig.enableVillageGrocer) {
      searches.add(_searchVillageGrocer(query));
    }
    if (GroceryApiConfig.enableJayaGrocer) {
      searches.add(_searchJayaGrocer(query));
    }
    if (GroceryApiConfig.enableMydin) {
      searches.add(_searchMydin(query));
    }
    if (GroceryApiConfig.enableSpeedmart) {
      searches.add(_searchSpeedmart(query));
    }
    if (GroceryApiConfig.enableEconsave) {
      searches.add(_searchEconsave(query));
    }
    if (GroceryApiConfig.enableHeroMarket) {
      searches.add(_searchHeroMarket(query));
    }
    if (GroceryApiConfig.enableTheStore) {
      searches.add(_searchTheStore(query));
    }
    if (GroceryApiConfig.enablePacific) {
      searches.add(_searchPacific(query));
    }
    if (GroceryApiConfig.enableHappyFresh) {
      searches.add(_searchHappyFresh(query));
    }
    if (GroceryApiConfig.enablePandamart) {
      searches.add(_searchPandamart(query));
    }
    if (GroceryApiConfig.enableLotus) {
      searches.add(_searchLotus(query));
    }
    if (GroceryApiConfig.enableBig) {
      searches.add(_searchBig(query));
    }
    if (GroceryApiConfig.enableColdStorage) {
      searches.add(_searchColdStorage(query));
    }
    if (GroceryApiConfig.enableMercato) {
      searches.add(_searchMercato(query));
    }
    if (GroceryApiConfig.enableRedMart) {
      searches.add(_searchRedMart(query));
    }
    if (GroceryApiConfig.enableTheFoodPurveyor) {
      searches.add(_searchTheFoodPurveyor(query));
    }

    // Wait for all searches to complete
    try {
      final results = await Future.wait(searches);
      for (var products in results) {
        allProducts.addAll(products);
      }
    } catch (e) {
      debugPrint('Error searching products: $e');
    }

    // Sort by price (lowest first)
    allProducts.sort((a, b) => a.price.compareTo(b.price));

    // Cache results
    _cache[query] = allProducts;
    _cacheTimestamps[query] = DateTime.now();

    return allProducts;
  }

  /// Get price comparison for a specific product across all stores
  Future<Map<String, dynamic>> compareProduct(String productName) async {
    final products = await searchProducts(productName);

    if (products.isEmpty) {
      return {
        'productName': productName,
        'stores': [],
        'lowestPrice': null,
        'highestPrice': null,
        'averagePrice': 0.0,
      };
    }

    // Group by store
    final Map<String, List<GroceryStoreProduct>> byStore = {};
    for (var product in products) {
      if (!byStore.containsKey(product.storeName)) {
        byStore[product.storeName] = [];
      }
      byStore[product.storeName]!.add(product);
    }

    // Calculate statistics
    final prices = products.map((p) => p.price).toList();
    final lowestPrice = prices.reduce((a, b) => a < b ? a : b);
    final highestPrice = prices.reduce((a, b) => a > b ? a : b);
    final averagePrice = prices.reduce((a, b) => a + b) / prices.length;

    return {
      'productName': productName,
      'stores': byStore,
      'products': products,
      'lowestPrice': lowestPrice,
      'highestPrice': highestPrice,
      'averagePrice': averagePrice,
      'storeCount': byStore.length,
      'totalResults': products.length,
    };
  }

  // Shopee integration - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchShopee(String query) async {
    try {
      // Use web scraper to get real data from Shopee
      return await _webScraper.searchShopee(query);
    } catch (e) {
      debugPrint('Shopee search error: $e');
      return [];
    }
  }

  // Lazada integration - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchLazada(String query) async {
    try {
      // Use web scraper to get real data from Lazada
      return await _webScraper.searchLazada(query);
    } catch (e) {
      debugPrint('Lazada search error: $e');
      return [];
    }
  }

  // GrabMart integration - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchGrabMart(String query) async {
    try {
      return await _webScraper.searchGrabMart(query);
    } catch (e) {
      debugPrint('GrabMart search error: $e');
      return [];
    }
  }

  // Tesco Malaysia - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchTesco(String query) async {
    try {
      return await _webScraper.searchTesco(query);
    } catch (e) {
      debugPrint('Tesco search error: $e');
      return [];
    }
  }

  // Giant Malaysia - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchGiant(String query) async {
    try {
      return await _webScraper.searchGiant(query);
    } catch (e) {
      debugPrint('Giant search error: $e');
      return [];
    }
  }

  // AEON Malaysia - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchAeon(String query) async {
    try {
      return await _webScraper.searchAeon(query);
    } catch (e) {
      debugPrint('AEON search error: $e');
      return [];
    }
  }

  // AEON Big Malaysia - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchAeonBig(String query) async {
    try {
      return await _webScraper.searchAeonBig(query);
    } catch (e) {
      debugPrint('AEON Big search error: $e');
      return [];
    }
  }

  // NSK Grocer - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchNsk(String query) async {
    try {
      return await _webScraper.searchNsk(query);
    } catch (e) {
      debugPrint('NSK search error: $e');
      return [];
    }
  }

  // Village Grocer - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchVillageGrocer(String query) async {
    try {
      return await _webScraper.searchVillageGrocer(query);
    } catch (e) {
      debugPrint('Village Grocer search error: $e');
      return [];
    }
  }

  // Jaya Grocer - uses web scraping for real data
  Future<List<GroceryStoreProduct>> _searchJayaGrocer(String query) async {
    try {
      return await _webScraper.searchJayaGrocer(query);
    } catch (e) {
      debugPrint('Jaya Grocer search error: $e');
      return [];
    }
  }

  // Mydin integration
  Future<List<GroceryStoreProduct>> _searchMydin(String query) async {
    try {
      return await _webScraper.searchMydin(query);
    } catch (e) {
      debugPrint('Mydin search error: $e');
      return [];
    }
  }

  // 99 Speedmart integration
  Future<List<GroceryStoreProduct>> _searchSpeedmart(String query) async {
    try {
      return await _webScraper.searchSpeedmart(query);
    } catch (e) {
      debugPrint('99 Speedmart search error: $e');
      return [];
    }
  }

  // Econsave integration
  Future<List<GroceryStoreProduct>> _searchEconsave(String query) async {
    try {
      return await _webScraper.searchEconsave(query);
    } catch (e) {
      debugPrint('Econsave search error: $e');
      return [];
    }
  }

  // Hero Market integration
  Future<List<GroceryStoreProduct>> _searchHeroMarket(String query) async {
    try {
      return await _webScraper.searchHeroMarket(query);
    } catch (e) {
      debugPrint('Hero Market search error: $e');
      return [];
    }
  }

  // The Store integration
  Future<List<GroceryStoreProduct>> _searchTheStore(String query) async {
    try {
      return await _webScraper.searchTheStore(query);
    } catch (e) {
      debugPrint('The Store search error: $e');
      return [];
    }
  }

  // Pacific integration
  Future<List<GroceryStoreProduct>> _searchPacific(String query) async {
    try {
      return await _webScraper.searchPacific(query);
    } catch (e) {
      debugPrint('Pacific search error: $e');
      return [];
    }
  }

  // HappyFresh integration
  Future<List<GroceryStoreProduct>> _searchHappyFresh(String query) async {
    try {
      return await _webScraper.searchHappyFresh(query);
    } catch (e) {
      debugPrint('HappyFresh search error: $e');
      return [];
    }
  }

  // Pandamart (Foodpanda) integration
  Future<List<GroceryStoreProduct>> _searchPandamart(String query) async {
    try {
      return await _webScraper.searchPandamart(query);
    } catch (e) {
      debugPrint('Pandamart search error: $e');
      return [];
    }
  }

  // Lotus's integration
  Future<List<GroceryStoreProduct>> _searchLotus(String query) async {
    try {
      return await _webScraper.searchLotus(query);
    } catch (e) {
      debugPrint('Lotus\'s search error: $e');
      return [];
    }
  }

  // B.I.G (Ben's Independent Grocer) integration
  Future<List<GroceryStoreProduct>> _searchBig(String query) async {
    try {
      return await _webScraper.searchBig(query);
    } catch (e) {
      debugPrint('B.I.G search error: $e');
      return [];
    }
  }

  // Cold Storage integration
  Future<List<GroceryStoreProduct>> _searchColdStorage(String query) async {
    try {
      return await _webScraper.searchColdStorage(query);
    } catch (e) {
      debugPrint('Cold Storage search error: $e');
      return [];
    }
  }

  // Mercato integration
  Future<List<GroceryStoreProduct>> _searchMercato(String query) async {
    try {
      return await _webScraper.searchMercato(query);
    } catch (e) {
      debugPrint('Mercato search error: $e');
      return [];
    }
  }

  // RedMart (Lazada) integration
  Future<List<GroceryStoreProduct>> _searchRedMart(String query) async {
    try {
      return await _webScraper.searchRedMart(query);
    } catch (e) {
      debugPrint('RedMart search error: $e');
      return [];
    }
  }

  // The Food Purveyor integration
  Future<List<GroceryStoreProduct>> _searchTheFoodPurveyor(String query) async {
    try {
      return await _webScraper.searchTheFoodPurveyor(query);
    } catch (e) {
      debugPrint('The Food Purveyor search error: $e');
      return [];
    }
  }

  // Check if query is cached and still valid
  bool _isCached(String query) {
    if (!_cache.containsKey(query)) return false;
    final timestamp = _cacheTimestamps[query];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) <
        GroceryApiConfig.cacheDuration;
  }

  // Clear cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  // Clear expired cache entries
  void clearExpiredCache() {
    final now = DateTime.now();
    _cacheTimestamps.removeWhere((key, timestamp) {
      if (now.difference(timestamp) >= GroceryApiConfig.cacheDuration) {
        _cache.remove(key);
        return true;
      }
      return false;
    });
  }

  /// Get mock products for a query (for testing/development)
  List<GroceryStoreProduct> _getMockProductsForQuery(String query) {
    final queryLower = query.toLowerCase();
    final allMockProducts = MockGroceryData.getMockProducts();
    
    // Filter products that match the query
    return allMockProducts.where((product) {
      final nameLower = product.name.toLowerCase();
      final categoryLower = product.category?.toLowerCase() ?? '';
      final brandLower = product.brand?.toLowerCase() ?? '';
      
      return nameLower.contains(queryLower) ||
          categoryLower.contains(queryLower) ||
          brandLower.contains(queryLower);
    }).toList();
  }
}
