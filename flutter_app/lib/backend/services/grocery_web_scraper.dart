import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import '../models/grocery_store_product.dart';

/// Web scraper for Malaysian grocery stores
/// Fetches real product data from store websites
class GroceryWebScraper {
  final http.Client _client;

  GroceryWebScraper({http.Client? client}) : _client = client ?? http.Client();

  /// Search products on Shopee Malaysia
  Future<List<GroceryStoreProduct>> searchShopee(String query) async {
    try {
      final url = Uri.parse(
        'https://shopee.com.my/api/v4/search/search_items?by=relevancy&keyword=${Uri.encodeComponent(query)}&limit=20&newest=0&order=desc&page_type=search&scenario=PAGE_GLOBAL_SEARCH&version=2',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Referer': 'https://shopee.com.my/',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseShopeeResponse(data);
      }
    } catch (e) {
      debugPrint('Shopee search error: $e');
    }
    return [];
  }

  /// Search products on Lazada Malaysia
  Future<List<GroceryStoreProduct>> searchLazada(String query) async {
    try {
      final url = Uri.parse(
        'https://www.lazada.com.my/catalog/?q=${Uri.encodeComponent(query)}&_keyori=ss&from=input&spm=a2o4k.searchlist.search.go',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseLazadaHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('Lazada search error: $e');
    }
    return [];
  }

  /// Search products on GrabMart (via web scraping)
  Future<List<GroceryStoreProduct>> searchGrabMart(String query) async {
    try {
      // GrabMart doesn't have a public API, so we'll use web scraping
      // Note: This is a placeholder - actual implementation would need to inspect GrabMart's website structure
      final url = Uri.parse(
        'https://food.grab.com/my/en/restaurants?search=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseGrabMartHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('GrabMart search error: $e');
    }
    return [];
  }

  /// Search products on Tesco Malaysia
  Future<List<GroceryStoreProduct>> searchTesco(String query) async {
    try {
      final url = Uri.parse(
        'https://www.tesco.com.my/groceries/en-GB/search?query=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseTescoHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('Tesco search error: $e');
    }
    return [];
  }

  /// Search products on Giant Malaysia
  Future<List<GroceryStoreProduct>> searchGiant(String query) async {
    try {
      final url = Uri.parse(
        'https://www.giant.com.my/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseGiantHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('Giant search error: $e');
    }
    return [];
  }

  /// Search products on AEON Malaysia
  Future<List<GroceryStoreProduct>> searchAeon(String query) async {
    try {
      // Try multiple search URL patterns
      final urls = [
        'https://www.aeon.com.my/en/groceries/search?q=${Uri.encodeComponent(query)}',
        'https://www.aeon.com.my/search?q=${Uri.encodeComponent(query)}',
        'https://www.aeonretail.com.my/search?q=${Uri.encodeComponent(query)}',
        'https://www.aeon.com.my/en/search?q=${Uri.encodeComponent(query)}',
      ];

      for (var urlStr in urls) {
        try {
          final url = Uri.parse(urlStr);
          final response = await _client.get(
            url,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              'Accept-Language': 'en-US,en;q=0.9',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final products = _parseAeonHTML(response.body, query);
            if (products.isNotEmpty) {
              debugPrint('✅ AEON: Found ${products.length} products using $urlStr');
              return products;
            }
          }
        } catch (e) {
          debugPrint('AEON URL $urlStr error: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('AEON search error: $e');
    }
    return [];
  }

  /// Search products on AEON Big Malaysia
  Future<List<GroceryStoreProduct>> searchAeonBig(String query) async {
    try {
      // Try multiple search URL patterns for AEON Big
      final urls = [
        'https://www.aeonbig.com.my/search?q=${Uri.encodeComponent(query)}',
        'https://www.aeonbig.com.my/en/search?q=${Uri.encodeComponent(query)}',
        'https://www.aeonbig.com.my/groceries/search?q=${Uri.encodeComponent(query)}',
        'https://aeonbig.com.my/search?q=${Uri.encodeComponent(query)}',
      ];

      for (var urlStr in urls) {
        try {
          final url = Uri.parse(urlStr);
          final response = await _client.get(
            url,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              'Accept-Language': 'en-US,en;q=0.9',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final products = _parseAeonBigHTML(response.body, query);
            if (products.isNotEmpty) {
              debugPrint('✅ AEON Big: Found ${products.length} products using $urlStr');
              return products;
            }
          }
        } catch (e) {
          debugPrint('AEON Big URL $urlStr error: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('AEON Big search error: $e');
    }
    return [];
  }

  /// Search products on NSK Grocer
  Future<List<GroceryStoreProduct>> searchNsk(String query) async {
    try {
      final url = Uri.parse(
        'https://www.nskgrocer.com/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseNskHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('NSK search error: $e');
    }
    return [];
  }

  /// Search products on Village Grocer
  Future<List<GroceryStoreProduct>> searchVillageGrocer(String query) async {
    try {
      final url = Uri.parse(
        'https://www.villagegrocer.com/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseVillageGrocerHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('Village Grocer search error: $e');
    }
    return [];
  }

  /// Search products on Jaya Grocer
  Future<List<GroceryStoreProduct>> searchJayaGrocer(String query) async {
    try {
      // Try multiple search URL patterns
      final urls = [
        'https://www.jayagrocer.com/search?q=${Uri.encodeComponent(query)}',
        'https://www.jayagrocer.com/products?search=${Uri.encodeComponent(query)}',
        'https://www.jayagrocer.com/en/search?q=${Uri.encodeComponent(query)}',
        'https://jayagrocer.com/search?q=${Uri.encodeComponent(query)}',
      ];

      for (var urlStr in urls) {
        try {
          final url = Uri.parse(urlStr);
          final response = await _client.get(
            url,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              'Accept-Language': 'en-US,en;q=0.9',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final products = _parseJayaGrocerHTML(response.body, query);
            if (products.isNotEmpty) {
              debugPrint('✅ Jaya Grocer: Found ${products.length} products using $urlStr');
              return products;
            }
          }
        } catch (e) {
          debugPrint('Jaya Grocer URL $urlStr error: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('Jaya Grocer search error: $e');
    }
    return [];
  }

  // Parse Shopee API response
  List<GroceryStoreProduct> _parseShopeeResponse(Map<String, dynamic> data) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final items = data['items'] as List<dynamic>? ?? [];
      
      for (var item in items) {
        try {
          final itemBasic = item['item_basic'] as Map<String, dynamic>?;
          if (itemBasic == null) continue;

          final price = (itemBasic['price'] as num? ?? 0) ~/ 100000; // Shopee prices in cents
          final originalPrice = itemBasic['price_before_discount'] != null
              ? ((itemBasic['price_before_discount'] as num) ~/ 100000).toString()
              : null;

          products.add(GroceryStoreProduct(
            id: itemBasic['itemid']?.toString() ?? '',
            name: itemBasic['name'] ?? '',
            storeName: 'Shopee',
            price: price.toDouble(),
            originalPrice: originalPrice,
            currency: 'MYR',
            imageUrl: 'https://cf.shopee.com.my/file/${itemBasic['image']}',
            productUrl: 'https://shopee.com.my/product/${itemBasic['shopid']}/${itemBasic['itemid']}',
            brand: itemBasic['brand'],
            category: itemBasic['catid']?.toString(),
            unit: itemBasic['package_info'],
            inStock: (itemBasic['stock'] as num? ?? 0) > 0,
            rating: itemBasic['item_rating']?['rating_star'] != null
                ? (itemBasic['item_rating']!['rating_star'] as num).toDouble()
                : null,
            reviewCount: itemBasic['item_rating']?['rating_count']?[0] as int?,
            metadata: itemBasic,
          ));
        } catch (e) {
          debugPrint('Error parsing Shopee product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing Shopee response: $e');
    }
    
    return products;
  }

  // Parse Lazada HTML with multiple selector fallbacks
  List<GroceryStoreProduct> _parseLazadaHTML(String html, String query) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      // Try multiple selector patterns
      var productCards = document.querySelectorAll('[data-qa-locator="product-item"]');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-item');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-spm="product"]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.c-product-card');
      }
      
      // Increase limit to get more products
      for (var card in productCards.take(50)) {
        try {
          // Try multiple selectors for name
          var nameElement = card.querySelector('[data-qa-locator="product-title"]') ??
              card.querySelector('.product-title') ??
              card.querySelector('h2') ??
              card.querySelector('.title') ??
              card.querySelector('[data-spm="product-title"]');
          
          // Try multiple selectors for price
          var priceElement = card.querySelector('[data-qa-locator="product-price"]') ??
              card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('[data-spm="product-price"]') ??
              card.querySelector('.c-product-card__price');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a[href*="/products/"]') ??
              card.querySelector('a[href*="/product/"]') ??
              card.querySelector('a');

          if (nameElement == null || priceElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty) continue;
          
          final priceText = priceElement.text.trim().replaceAll(RegExp(r'[^\d.]'), '');
          final price = double.tryParse(priceText) ?? 0.0;
          if (price <= 0) continue;
          
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? 
                        imageElement?.attributes['data-lazy-src'] ?? '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          // Clean and fix URLs
          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
            imageUrl = 'https://www.lazada.com.my$imageUrl';
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = 'https://www.lazada.com.my$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: 'Lazada',
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl,
            productUrl: productUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing Lazada product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing Lazada HTML: $e');
    }
    
    return products;
  }

  // Parse GrabMart HTML
  List<GroceryStoreProduct> _parseGrabMartHTML(String html, String query) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      // Try multiple selector patterns
      var productCards = document.querySelectorAll('.restaurant-item');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-item');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-testid="restaurant-card"]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.restaurantCard');
      }
      
      // Increase limit to get more products
      for (var card in productCards.take(50)) {
        try {
          var nameElement = card.querySelector('.restaurant-name') ??
              card.querySelector('.product-name') ??
              card.querySelector('h3') ??
              card.querySelector('h2');
          
          var priceElement = card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('[data-testid="price"]');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a');

          if (nameElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty) continue;
          
          final priceText = priceElement?.text.trim().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
          final price = double.tryParse(priceText) ?? 0.0;
          
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? 
                        imageElement?.attributes['data-lazy-src'] ?? '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
            imageUrl = 'https://food.grab.com$imageUrl';
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = 'https://food.grab.com$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: 'GrabMart',
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl,
            productUrl: productUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing GrabMart product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing GrabMart HTML: $e');
    }
    
    return products;
  }

  // Parse Tesco HTML
  List<GroceryStoreProduct> _parseTescoHTML(String html, String query) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      var productCards = document.querySelectorAll('.product-tile');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-item');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-testid="product-tile"]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.tile-content');
      }
      
      // Increase limit to get more products
      for (var card in productCards.take(50)) {
        try {
          var nameElement = card.querySelector('.product-title') ??
              card.querySelector('.product-name') ??
              card.querySelector('h3') ??
              card.querySelector('h2') ??
              card.querySelector('[data-testid="product-title"]');
          
          var priceElement = card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('[data-testid="price"]') ??
              card.querySelector('.value');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a[href*="/groceries/"]') ??
              card.querySelector('a');

          if (nameElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty) continue;
          
          final priceText = priceElement?.text.trim().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
          final price = double.tryParse(priceText) ?? 0.0;
          
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? 
                        imageElement?.attributes['data-lazy-src'] ?? '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
            imageUrl = 'https://www.tesco.com.my$imageUrl';
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = 'https://www.tesco.com.my$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: 'Tesco',
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl,
            productUrl: productUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing Tesco product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing Tesco HTML: $e');
    }
    
    return products;
  }

  // Parse Giant HTML
  List<GroceryStoreProduct> _parseGiantHTML(String html, String query) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      var productCards = document.querySelectorAll('.product-item');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-card');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-product-id]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-tile');
      }
      
      // Increase limit to get more products
      for (var card in productCards.take(50)) {
        try {
          var nameElement = card.querySelector('.product-name') ??
              card.querySelector('.product-title') ??
              card.querySelector('h3') ??
              card.querySelector('h2') ??
              card.querySelector('h4');
          
          var priceElement = card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('.current-price') ??
              card.querySelector('[class*="price"]');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a[href*="/product"]') ??
              card.querySelector('a[href*="/p/"]') ??
              card.querySelector('a');

          if (nameElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty) continue;
          
          final priceText = priceElement?.text.trim().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
          final price = double.tryParse(priceText) ?? 0.0;
          
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? 
                        imageElement?.attributes['data-lazy-src'] ?? '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
            imageUrl = 'https://www.giant.com.my$imageUrl';
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = 'https://www.giant.com.my$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: 'Giant',
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl,
            productUrl: productUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing Giant product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing Giant HTML: $e');
    }
    
    return products;
  }

  // Parse AEON HTML with extensive selector patterns
  List<GroceryStoreProduct> _parseAeonHTML(String html, String query) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      // Try many selector patterns to find products
      var productCards = document.querySelectorAll('.product-item');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-card');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-product]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-tile');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[class*="product"]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[class*="item"]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('article');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-testid*="product"]');
      }
      
      // Also try to find JSON data in script tags
      final scriptTags = document.querySelectorAll('script');
      for (var script in scriptTags) {
        try {
          final scriptText = script.text;
          if (scriptText.contains('product') || scriptText.contains('items') || scriptText.contains(query.toLowerCase())) {
            // Try to find JSON objects with product data
            final jsonMatches = RegExp(r'\{[^{}]*"product[s]?":\s*\[.*?\]', dotAll: true).allMatches(scriptText);
            for (var match in jsonMatches) {
              try {
                final jsonStr = match.group(0);
                if (jsonStr != null) {
                  final jsonData = jsonDecode(jsonStr);
                  if (jsonData is Map && jsonData.containsKey('products')) {
                    final jsonProducts = jsonData['products'] as List?;
                    if (jsonProducts != null) {
                      for (var item in jsonProducts.take(50)) {
                        try {
                          if (item is Map) {
                            final name = item['name']?.toString() ?? item['title']?.toString() ?? '';
                            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                            final imageUrl = item['image']?.toString() ?? item['imageUrl']?.toString() ?? '';
                            final productUrl = item['url']?.toString() ?? item['link']?.toString() ?? '';
                            
                            if (name.isNotEmpty && price > 0) {
                              products.add(GroceryStoreProduct(
                                id: item['id']?.toString() ?? item['sku']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: name,
                                storeName: 'AEON',
                                price: price,
                                currency: 'MYR',
                                imageUrl: imageUrl,
                                productUrl: productUrl.isNotEmpty && productUrl.startsWith('http') 
                                    ? productUrl 
                                    : 'https://www.aeon.com.my$productUrl',
                                inStock: item['inStock'] as bool? ?? item['available'] as bool? ?? true,
                              ));
                            }
                          }
                        } catch (e) {
                          debugPrint('Error parsing AEON JSON product: $e');
                        }
                      }
                    }
                  }
                }
              } catch (e) {
                // Not valid JSON, continue
              }
            }
          }
        } catch (e) {
          // Continue to next script tag
        }
      }
      
      // Increase limit to get more products
      for (var card in productCards.take(50)) {
        try {
          var nameElement = card.querySelector('.product-name') ??
              card.querySelector('.product-title') ??
              card.querySelector('h3') ??
              card.querySelector('h2') ??
              card.querySelector('h4');
          
          var priceElement = card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('.current-price') ??
              card.querySelector('[class*="price"]');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a[href*="/product"]') ??
              card.querySelector('a[href*="/p/"]') ??
              card.querySelector('a');

          if (nameElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty) continue;
          
          final priceText = priceElement?.text.trim().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
          final price = double.tryParse(priceText) ?? 0.0;
          
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? 
                        imageElement?.attributes['data-lazy-src'] ??
                        imageElement?.attributes['data-original'] ??
                        imageElement?.attributes['data-image'] ??
                        '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          // Clean up image URL - remove query parameters that might break the URL
          if (imageUrl.isNotEmpty) {
            // Remove leading slashes if present
            imageUrl = imageUrl.trim();
            if (imageUrl.startsWith('//')) {
              imageUrl = 'https:$imageUrl';
            } else if (!imageUrl.startsWith('http')) {
              // Ensure proper path format
              if (!imageUrl.startsWith('/')) {
                imageUrl = '/$imageUrl';
              }
              imageUrl = 'https://www.aeon.com.my$imageUrl';
            }
            // Remove any query parameters that might cause issues
            if (imageUrl.contains('?')) {
              final uri = Uri.tryParse(imageUrl);
              if (uri != null) {
                imageUrl = '${uri.scheme}://${uri.host}${uri.path}';
              }
            }
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = 'https://www.aeon.com.my$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: 'AEON',
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl,
            productUrl: productUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing AEON product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing AEON HTML: $e');
    }
    
    debugPrint('✅ AEON: Found ${products.length} products for "$query"');
    return products;
  }

  // Parse AEON Big HTML (similar structure to AEON)
  List<GroceryStoreProduct> _parseAeonBigHTML(String html, String query) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      // Try multiple selector patterns for AEON Big
      var productCards = document.querySelectorAll('.product-item');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-card');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-product-id]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-tile');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product');
      }
      
      // Try to extract JSON data from script tags (common in modern e-commerce)
      try {
        final scriptTags = document.querySelectorAll('script[type="application/json"]');
        for (var script in scriptTags) {
          try {
            final jsonData = jsonDecode(script.text);
            if (jsonData is Map && jsonData.containsKey('products')) {
              final productsList = jsonData['products'] as List?;
              if (productsList != null) {
                for (var product in productsList) {
                  try {
                    final productData = product as Map<String, dynamic>;
                    final name = productData['name']?.toString() ?? '';
                    final price = (productData['price'] as num?)?.toDouble() ?? 0.0;
                    final imageUrl = productData['image']?.toString() ?? productData['imageUrl']?.toString() ?? '';
                    final productUrl = productData['url']?.toString() ?? productData['link']?.toString() ?? '';
                    
                    if (name.isNotEmpty && price > 0) {
                      products.add(GroceryStoreProduct(
                        id: productData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        storeName: 'AEON Big',
                        price: price,
                        currency: 'MYR',
                        imageUrl: imageUrl.isNotEmpty && imageUrl.startsWith('http') 
                            ? imageUrl 
                            : imageUrl.isNotEmpty 
                                ? 'https://www.aeonbig.com.my$imageUrl'
                                : '',
                        productUrl: productUrl.isNotEmpty && productUrl.startsWith('http')
                            ? productUrl
                            : productUrl.isNotEmpty
                                ? 'https://www.aeonbig.com.my$productUrl'
                                : '',
                        inStock: productData['inStock'] as bool? ?? true,
                      ));
                    }
                  } catch (e) {
                    debugPrint('Error parsing AEON Big JSON product: $e');
                  }
                }
              }
            }
          } catch (e) {
            // Not valid JSON, continue
          }
        }
      } catch (e) {
        debugPrint('Error parsing AEON Big JSON: $e');
      }
      
      // Parse HTML product cards
      for (var card in productCards.take(50)) {
        try {
          var nameElement = card.querySelector('.product-name') ??
              card.querySelector('.product-title') ??
              card.querySelector('h3') ??
              card.querySelector('h2') ??
              card.querySelector('h4') ??
              card.querySelector('[class*="name"]');
          
          var priceElement = card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('.current-price') ??
              card.querySelector('[class*="price"]');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a[href*="/product"]') ??
              card.querySelector('a[href*="/p/"]') ??
              card.querySelector('a');

          if (nameElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty) continue;
          
          final priceText = priceElement?.text.trim().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
          final price = double.tryParse(priceText) ?? 0.0;
          if (price <= 0) continue;
          
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? 
                        imageElement?.attributes['data-lazy-src'] ??
                        imageElement?.attributes['data-original'] ??
                        imageElement?.attributes['data-image'] ??
                        '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          // Clean up image URL
          if (imageUrl.isNotEmpty) {
            imageUrl = imageUrl.trim();
            if (imageUrl.startsWith('//')) {
              imageUrl = 'https:$imageUrl';
            } else if (!imageUrl.startsWith('http')) {
              if (!imageUrl.startsWith('/')) {
                imageUrl = '/$imageUrl';
              }
              imageUrl = 'https://www.aeonbig.com.my$imageUrl';
            }
            if (imageUrl.contains('?')) {
              final uri = Uri.tryParse(imageUrl);
              if (uri != null) {
                imageUrl = '${uri.scheme}://${uri.host}${uri.path}';
              }
            }
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = 'https://www.aeonbig.com.my$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: 'AEON Big',
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl,
            productUrl: productUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing AEON Big product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing AEON Big HTML: $e');
    }
    
    debugPrint('✅ AEON Big: Found ${products.length} products for "$query"');
    return products;
  }

  // Parse NSK Grocer HTML
  List<GroceryStoreProduct> _parseNskHTML(String html, String query) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      var productCards = document.querySelectorAll('.product-item');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-card');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-product-id]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-tile');
      }
      
      // Increase limit to get more products
      for (var card in productCards.take(50)) {
        try {
          var nameElement = card.querySelector('.product-name') ??
              card.querySelector('.product-title') ??
              card.querySelector('h3') ??
              card.querySelector('h2') ??
              card.querySelector('h4');
          
          var priceElement = card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('.current-price') ??
              card.querySelector('[class*="price"]');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a[href*="/product"]') ??
              card.querySelector('a[href*="/p/"]') ??
              card.querySelector('a');

          if (nameElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty) continue;
          
          final priceText = priceElement?.text.trim().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
          final price = double.tryParse(priceText) ?? 0.0;
          
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? 
                        imageElement?.attributes['data-lazy-src'] ?? '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
            imageUrl = 'https://www.nskgrocer.com$imageUrl';
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = 'https://www.nskgrocer.com$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: 'NSK Grocer',
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl,
            productUrl: productUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing NSK product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing NSK HTML: $e');
    }
    
    return products;
  }

  // Parse Village Grocer HTML
  List<GroceryStoreProduct> _parseVillageGrocerHTML(String html, String query) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      var productCards = document.querySelectorAll('.product-item');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-card');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-product-id]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-tile');
      }
      
      // Increase limit to get more products
      for (var card in productCards.take(50)) {
        try {
          var nameElement = card.querySelector('.product-name') ??
              card.querySelector('.product-title') ??
              card.querySelector('h3') ??
              card.querySelector('h2') ??
              card.querySelector('h4');
          
          var priceElement = card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('.current-price') ??
              card.querySelector('[class*="price"]');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a[href*="/product"]') ??
              card.querySelector('a[href*="/p/"]') ??
              card.querySelector('a');

          if (nameElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty) continue;
          
          final priceText = priceElement?.text.trim().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
          final price = double.tryParse(priceText) ?? 0.0;
          
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? 
                        imageElement?.attributes['data-lazy-src'] ?? '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
            imageUrl = 'https://www.villagegrocer.com$imageUrl';
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = 'https://www.villagegrocer.com$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: 'Village Grocer',
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl,
            productUrl: productUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing Village Grocer product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing Village Grocer HTML: $e');
    }
    
    return products;
  }

  // Parse Jaya Grocer HTML with extensive selector patterns
  List<GroceryStoreProduct> _parseJayaGrocerHTML(String html, String query) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      // Try many selector patterns to find products
      var productCards = document.querySelectorAll('.product-item');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-card');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-product-id]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-tile');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[class*="product"]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[class*="item"]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('article');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-testid*="product"]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.grid-item');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.card');
      }
      
      // Also try to find JSON data in script tags
      final scriptTags = document.querySelectorAll('script');
      for (var script in scriptTags) {
        try {
          final jsonText = script.text;
          if (jsonText.contains('product') || jsonText.contains('items') || jsonText.contains(query.toLowerCase())) {
            // Try to find JSON objects with product data
            final jsonMatch = RegExp(r'\{[^{}]*"product[s]?":\s*\[.*?\]', dotAll: true).firstMatch(jsonText);
            if (jsonMatch != null) {
              try {
                final jsonData = jsonDecode(jsonMatch.group(0)!);
                if (jsonData is Map && jsonData.containsKey('products')) {
                  final jsonProducts = jsonData['products'] as List?;
                  if (jsonProducts != null) {
                    for (var item in jsonProducts.take(50)) {
                      try {
                        if (item is Map) {
                          final name = item['name']?.toString() ?? item['title']?.toString() ?? item['productName']?.toString() ?? '';
                          final price = (item['price'] as num?)?.toDouble() ?? 
                                      double.tryParse(item['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0.0;
                          var imageUrl = item['image']?.toString() ?? 
                                        item['imageUrl']?.toString() ?? 
                                        item['img']?.toString() ?? 
                                        item['thumbnail']?.toString() ?? 
                                        item['photo']?.toString() ?? '';
                          final productUrl = item['url']?.toString() ?? item['link']?.toString() ?? item['href']?.toString() ?? '';
                          
                          // Normalize image URL from JSON
                          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                            if (!imageUrl.startsWith('/')) {
                              imageUrl = '/$imageUrl';
                            }
                            imageUrl = 'https://www.jayagrocer.com$imageUrl';
                          }
                          
                          if (name.isNotEmpty && price > 0) {
                            products.add(GroceryStoreProduct(
                              id: item['id']?.toString() ?? item['sku']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              name: name,
                              storeName: 'Jaya Grocer',
                              price: price,
                              currency: 'MYR',
                              imageUrl: imageUrl,
                              productUrl: productUrl.isNotEmpty && productUrl.startsWith('http') 
                                  ? productUrl 
                                  : 'https://www.jayagrocer.com$productUrl',
                              inStock: item['inStock'] as bool? ?? item['available'] as bool? ?? true,
                            ));
                          }
                        }
                      } catch (e) {
                        debugPrint('Error parsing Jaya Grocer JSON product: $e');
                      }
                    }
                  }
                }
              } catch (e) {
                // Not valid JSON, continue
              }
            }
          }
        } catch (e) {
          // Continue to next script tag
        }
      }
      
      // Increase limit to get more products from HTML
      for (var card in productCards.take(50)) {
        try {
          var nameElement = card.querySelector('.product-name') ??
              card.querySelector('.product-title') ??
              card.querySelector('h3') ??
              card.querySelector('h2') ??
              card.querySelector('h4');
          
          var priceElement = card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('.current-price') ??
              card.querySelector('[class*="price"]');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a[href*="/product"]') ??
              card.querySelector('a[href*="/p/"]') ??
              card.querySelector('a');

          if (nameElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty) continue;
          
          final priceText = priceElement?.text.trim().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
          final price = double.tryParse(priceText) ?? 0.0;
          
          // Try multiple image attributes (Jaya Grocer may use different ones)
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? 
                        imageElement?.attributes['data-lazy-src'] ??
                        imageElement?.attributes['data-original'] ??
                        imageElement?.attributes['data-image'] ??
                        imageElement?.attributes['srcset']?.split(' ').first ?? '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          // Clean and normalize image URL
          if (imageUrl.isNotEmpty) {
            imageUrl = imageUrl.trim();
            // Handle protocol-relative URLs
            if (imageUrl.startsWith('//')) {
              imageUrl = 'https:$imageUrl';
            }
            // Handle relative URLs
            else if (!imageUrl.startsWith('http')) {
              if (!imageUrl.startsWith('/')) {
                imageUrl = '/$imageUrl';
              }
              imageUrl = 'https://www.jayagrocer.com$imageUrl';
            }
            // Remove query parameters that might cause issues
            if (imageUrl.contains('?')) {
              final uri = Uri.tryParse(imageUrl);
              if (uri != null) {
                imageUrl = '${uri.scheme}://${uri.host}${uri.path}';
              }
            }
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = 'https://www.jayagrocer.com$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: 'Jaya Grocer',
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl,
            productUrl: productUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing Jaya Grocer product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing Jaya Grocer HTML: $e');
    }
    
    return products;
  }

  /// Search products on Mydin
  Future<List<GroceryStoreProduct>> searchMydin(String query) async {
    try {
      final urls = [
        'https://www.mydin.com.my/search?q=${Uri.encodeComponent(query)}',
        'https://mydin.com.my/en/search?q=${Uri.encodeComponent(query)}',
      ];

      for (var urlStr in urls) {
        try {
          final url = Uri.parse(urlStr);
          final response = await _client.get(
            url,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final products = _parseMydinHTML(response.body, query);
            if (products.isNotEmpty) {
              debugPrint('✅ Mydin: Found ${products.length} products');
              return products;
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      debugPrint('Mydin search error: $e');
    }
    return [];
  }

  /// Search products on 99 Speedmart
  Future<List<GroceryStoreProduct>> searchSpeedmart(String query) async {
    try {
      final url = Uri.parse(
        'https://www.99speedmart.com.my/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseSpeedmartHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('99 Speedmart search error: $e');
    }
    return [];
  }

  /// Search products on Econsave
  Future<List<GroceryStoreProduct>> searchEconsave(String query) async {
    try {
      final url = Uri.parse(
        'https://www.econsave.com.my/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseEconsaveHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('Econsave search error: $e');
    }
    return [];
  }

  /// Search products on Hero Market
  Future<List<GroceryStoreProduct>> searchHeroMarket(String query) async {
    try {
      final url = Uri.parse(
        'https://www.heromarket.com.my/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseHeroMarketHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('Hero Market search error: $e');
    }
    return [];
  }

  /// Search products on The Store
  Future<List<GroceryStoreProduct>> searchTheStore(String query) async {
    try {
      final url = Uri.parse(
        'https://www.thestore.com.my/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseTheStoreHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('The Store search error: $e');
    }
    return [];
  }

  /// Search products on Pacific
  Future<List<GroceryStoreProduct>> searchPacific(String query) async {
    try {
      final url = Uri.parse(
        'https://www.pacific.com.my/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parsePacificHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('Pacific search error: $e');
    }
    return [];
  }

  // Parse Mydin HTML
  List<GroceryStoreProduct> _parseMydinHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'Mydin', 'https://www.mydin.com.my');
  }

  // Parse 99 Speedmart HTML
  List<GroceryStoreProduct> _parseSpeedmartHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, '99 Speedmart', 'https://www.99speedmart.com.my');
  }

  // Parse Econsave HTML
  List<GroceryStoreProduct> _parseEconsaveHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'Econsave', 'https://www.econsave.com.my');
  }

  // Parse Hero Market HTML
  List<GroceryStoreProduct> _parseHeroMarketHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'Hero Market', 'https://www.heromarket.com.my');
  }

  // Parse The Store HTML
  List<GroceryStoreProduct> _parseTheStoreHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'The Store', 'https://www.thestore.com.my');
  }

  // Parse Pacific HTML
  List<GroceryStoreProduct> _parsePacificHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'Pacific', 'https://www.pacific.com.my');
  }

  // Generic parser for stores with similar HTML structure
  List<GroceryStoreProduct> _parseGenericStoreHTML(String html, String query, String storeName, String baseUrl) {
    final List<GroceryStoreProduct> products = [];
    
    try {
      final document = html_parser.parse(html);
      
      // Try common product card selectors
      var productCards = document.querySelectorAll('.product-item');
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product-card');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[data-product]');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('.product');
      }
      if (productCards.isEmpty) {
        productCards = document.querySelectorAll('[class*="product"]');
      }
      
      for (var card in productCards.take(30)) {
        try {
          var nameElement = card.querySelector('.product-name') ??
              card.querySelector('.product-title') ??
              card.querySelector('h3') ??
              card.querySelector('h2');
          
          var priceElement = card.querySelector('.price') ??
              card.querySelector('.product-price') ??
              card.querySelector('[class*="price"]');
          
          final imageElement = card.querySelector('img');
          var linkElement = card.querySelector('a');

          if (nameElement == null) continue;

          final name = nameElement.text.trim();
          if (name.isEmpty || !name.toLowerCase().contains(query.toLowerCase())) continue;
          
          final priceText = priceElement?.text.trim().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
          final price = double.tryParse(priceText) ?? 0.0;
          if (price <= 0) continue;
          
          var imageUrl = imageElement?.attributes['src'] ?? 
                        imageElement?.attributes['data-src'] ?? '';
          var productUrl = linkElement?.attributes['href'] ?? '';

          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
            imageUrl = '$baseUrl$imageUrl';
          }
          if (productUrl.isNotEmpty && !productUrl.startsWith('http')) {
            productUrl = '$baseUrl$productUrl';
          }

          products.add(GroceryStoreProduct(
            id: productUrl.isNotEmpty ? productUrl.split('/').last : DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            storeName: storeName,
            price: price,
            currency: 'MYR',
            imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/400',
            productUrl: productUrl.isNotEmpty ? productUrl : baseUrl,
            inStock: true,
          ));
        } catch (e) {
          debugPrint('Error parsing $storeName product: $e');
        }
      }
    } catch (e) {
      debugPrint('Error parsing $storeName HTML: $e');
    }
    
    debugPrint('✅ $storeName: Found ${products.length} products for "$query"');
    return products;
  }

  /// Search products on HappyFresh
  Future<List<GroceryStoreProduct>> searchHappyFresh(String query) async {
    try {
      final urls = [
        'https://www.happyfresh.my/search?q=${Uri.encodeComponent(query)}',
        'https://happyfresh.com.my/search?q=${Uri.encodeComponent(query)}',
      ];

      for (var urlStr in urls) {
        try {
          final url = Uri.parse(urlStr);
          final response = await _client.get(
            url,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final products = _parseHappyFreshHTML(response.body, query);
            if (products.isNotEmpty) {
              debugPrint('✅ HappyFresh: Found ${products.length} products');
              return products;
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      debugPrint('HappyFresh search error: $e');
    }
    return [];
  }

  /// Search products on Pandamart (Foodpanda)
  Future<List<GroceryStoreProduct>> searchPandamart(String query) async {
    try {
      final urls = [
        'https://www.foodpanda.com.my/groceries/search?q=${Uri.encodeComponent(query)}',
        'https://www.foodpanda.my/groceries/search?q=${Uri.encodeComponent(query)}',
      ];

      for (var urlStr in urls) {
        try {
          final url = Uri.parse(urlStr);
          final response = await _client.get(
            url,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final products = _parsePandamartHTML(response.body, query);
            if (products.isNotEmpty) {
              debugPrint('✅ Pandamart: Found ${products.length} products');
              return products;
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      debugPrint('Pandamart search error: $e');
    }
    return [];
  }

  /// Search products on Lotus's
  Future<List<GroceryStoreProduct>> searchLotus(String query) async {
    try {
      final urls = [
        'https://www.lotuss.com.my/search?q=${Uri.encodeComponent(query)}',
        'https://lotuss.com.my/en/search?q=${Uri.encodeComponent(query)}',
      ];

      for (var urlStr in urls) {
        try {
          final url = Uri.parse(urlStr);
          final response = await _client.get(
            url,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final products = _parseLotusHTML(response.body, query);
            if (products.isNotEmpty) {
              debugPrint('✅ Lotus\'s: Found ${products.length} products');
              return products;
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      debugPrint('Lotus\'s search error: $e');
    }
    return [];
  }

  /// Search products on B.I.G (Ben's Independent Grocer)
  Future<List<GroceryStoreProduct>> searchBig(String query) async {
    try {
      final url = Uri.parse(
        'https://www.big.com.my/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseBigHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('B.I.G search error: $e');
    }
    return [];
  }

  /// Search products on Cold Storage
  Future<List<GroceryStoreProduct>> searchColdStorage(String query) async {
    try {
      final urls = [
        'https://www.coldstorage.com.my/search?q=${Uri.encodeComponent(query)}',
        'https://coldstorage.com.sg/search?q=${Uri.encodeComponent(query)}',
      ];

      for (var urlStr in urls) {
        try {
          final url = Uri.parse(urlStr);
          final response = await _client.get(
            url,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final products = _parseColdStorageHTML(response.body, query);
            if (products.isNotEmpty) {
              debugPrint('✅ Cold Storage: Found ${products.length} products');
              return products;
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      debugPrint('Cold Storage search error: $e');
    }
    return [];
  }

  /// Search products on Mercato
  Future<List<GroceryStoreProduct>> searchMercato(String query) async {
    try {
      final url = Uri.parse(
        'https://www.mercato.com.my/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseMercatoHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('Mercato search error: $e');
    }
    return [];
  }

  /// Search products on RedMart (Lazada)
  Future<List<GroceryStoreProduct>> searchRedMart(String query) async {
    try {
      // RedMart is part of Lazada, so we can use similar parsing
      final url = Uri.parse(
        'https://www.redmart.com/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseRedMartHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('RedMart search error: $e');
    }
    return [];
  }

  /// Search products on The Food Purveyor
  Future<List<GroceryStoreProduct>> searchTheFoodPurveyor(String query) async {
    try {
      final url = Uri.parse(
        'https://www.thefoodpurveyor.com/search?q=${Uri.encodeComponent(query)}',
      );

      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseTheFoodPurveyorHTML(response.body, query);
      }
    } catch (e) {
      debugPrint('The Food Purveyor search error: $e');
    }
    return [];
  }

  // Parse methods for new stores (using generic parsing pattern)
  List<GroceryStoreProduct> _parseHappyFreshHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'HappyFresh', 'https://www.happyfresh.my');
  }

  List<GroceryStoreProduct> _parsePandamartHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'Pandamart', 'https://www.foodpanda.com.my');
  }

  List<GroceryStoreProduct> _parseLotusHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'Lotus\'s', 'https://www.lotuss.com.my');
  }

  List<GroceryStoreProduct> _parseBigHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'B.I.G', 'https://www.big.com.my');
  }

  List<GroceryStoreProduct> _parseColdStorageHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'Cold Storage', 'https://www.coldstorage.com.my');
  }

  List<GroceryStoreProduct> _parseMercatoHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'Mercato', 'https://www.mercato.com.my');
  }

  List<GroceryStoreProduct> _parseRedMartHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'RedMart', 'https://www.redmart.com');
  }

  List<GroceryStoreProduct> _parseTheFoodPurveyorHTML(String html, String query) {
    return _parseGenericStoreHTML(html, query, 'The Food Purveyor', 'https://www.thefoodpurveyor.com');
  }
}

