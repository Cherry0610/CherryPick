# 🛒 Grocery Store API Integration Guide

This guide explains how to set up and use the grocery store API integration, similar to Trivago but for groceries.

## 📋 Overview

The grocery store API service integrates with multiple online grocery stores in Malaysia to provide real-time price comparisons. It aggregates prices from:

- **Shopee** - E-commerce platform
- **Lazada** - E-commerce platform  
- **GrabMart** - Grocery delivery service
- **Tesco Malaysia** - Hypermarket chain
- **Giant** - Hypermarket chain
- **AEON** - Hypermarket chain
- **NSK Grocer** - Hypermarket chain
- **Village Grocer** - Premium grocery chain
- **Jaya Grocer** - Premium grocery chain

## 🔧 Setup Instructions

### 1. Configure API Keys

Edit `lib/backend/config/grocery_api_config.dart` and add your API keys:

```dart
static const String shopeeApiKey = 'YOUR_SHOPEE_API_KEY';
static const String lazadaApiKey = 'YOUR_LAZADA_API_KEY';
static const String grabMartApiKey = 'YOUR_GRABMART_API_KEY';
static const String scrapingBeeApiKey = 'YOUR_SCRAPINGBEE_API_KEY'; // For web scraping
static const String foodsparkApiKey = 'YOUR_FOODSPARK_API_KEY'; // Alternative API
```

### 2. Get API Keys

#### Shopee API
- Visit [Shopee Open Platform](https://open.shopee.com/)
- Register as a developer
- Create an app and get your API key
- Note: Shopee API may require approval

#### Lazada API
- Visit [Lazada Open Platform](https://open.lazada.com/)
- Register and create an app
- Get your API credentials

#### GrabMart API
- Contact Grab for API access
- They may require a partnership agreement

#### ScrapingBee (Web Scraping Fallback)
- Sign up at [ScrapingBee](https://www.scrapingbee.com/)
- Get your API key from the dashboard
- Free tier: 1,000 requests/month

#### Foodspark (Alternative)
- Sign up at [Foodspark](https://www.foodspark.io/)
- Get your API key
- Provides grocery data from multiple sources

### 3. Enable/Disable Stores

In `grocery_api_config.dart`, you can enable or disable specific stores:

```dart
static const bool enableShopee = true;
static const bool enableLazada = true;
static const bool enableGrabMart = true;
static const bool enableTesco = true;
static const bool enableGiant = true;
static const bool enableAeon = true;
static const bool enableNsk = true;
static const bool enableVillageGrocer = true;
static const bool enableJayaGrocer = true;
```

## 💻 Usage

### Basic Product Search

```dart
import 'package:your_app/backend/services/grocery_store_api_service.dart';

final groceryService = GroceryStoreApiService();

// Search for products across all enabled stores
final products = await groceryService.searchProducts('rice');

// Products are automatically sorted by price (lowest first)
for (var product in products) {
  print('${product.name} - ${product.storeName} - RM ${product.price}');
}
```

### Price Comparison

```dart
// Get price comparison for a product
final comparison = await groceryService.compareProduct('Coca Cola 1.5L');

print('Lowest Price: RM ${comparison['lowestPrice']}');
print('Average Price: RM ${comparison['averagePrice']}');
print('Stores Found: ${comparison['storeCount']}');

// Access products by store
final stores = comparison['stores'] as Map<String, List<GroceryStoreProduct>>;
for (var storeName in stores.keys) {
  print('$storeName: ${stores[storeName]!.length} products');
}
```

### Integrated with Price Comparison Service

The `PriceComparisonService` now automatically includes grocery store prices:

```dart
import 'package:your_app/backend/services/price_comparison_service.dart';

final priceService = PriceComparisonService();

// This now includes both local Firestore data AND online grocery stores
final comparison = await priceService.getPriceComparison(productId);

// Check if results include online stores
final onlineCount = comparison['onlineStoreCount'];
final localCount = comparison['localStoreCount'];
```

## 📊 Response Format

### GroceryStoreProduct Model

```dart
{
  'id': 'product_123',
  'name': 'Coca Cola 1.5L',
  'storeName': 'Shopee',
  'price': 5.99,
  'originalPrice': '7.99', // If on sale
  'currency': 'MYR',
  'imageUrl': 'https://...',
  'productUrl': 'https://shopee.com.my/product/123',
  'brand': 'Coca Cola',
  'category': 'Beverages',
  'unit': '1.5L',
  'inStock': true,
  'rating': 4.5,
  'reviewCount': 1234,
  'description': 'Product description...',
  'discountPercentage': 25.0 // Calculated automatically
}
```

## 🔄 Caching

The service automatically caches search results for 15 minutes to:
- Reduce API calls
- Improve performance
- Save on API costs

Cache is automatically cleared when expired.

## ⚠️ Important Notes

### API Rate Limits

Each API has rate limits:
- Shopee: 60 requests/minute
- Lazada: 60 requests/minute
- GrabMart: 30 requests/minute
- ScrapingBee: 100 requests/minute

The service handles rate limiting automatically.

### Error Handling

The service gracefully handles errors:
- If one store's API fails, others continue to work
- Returns empty list for failed stores
- Logs errors for debugging

### Web Scraping

For stores without APIs (Tesco, Giant, AEON, NSK, Village Grocer, Jaya Grocer), web scraping is used:
- Requires ScrapingBee API key
- May be slower than direct APIs
- Respects robots.txt and rate limits
- HTML parsing needs to be implemented based on each store's website structure

## 🚀 Next Steps

1. **Get API Keys**: Sign up for the services you want to use
2. **Configure**: Add API keys to `grocery_api_config.dart`
3. **Test**: Try searching for a product
4. **Monitor**: Check logs for any API errors
5. **Optimize**: Adjust cache duration and rate limits as needed

## 📝 API Response Parsing

The service includes parsers for each store's API response format. You may need to adjust these based on:
- Actual API response structure
- API version changes
- Store-specific data formats

Edit the `_parseShopeeResponse`, `_parseLazadaResponse`, etc. methods in `grocery_store_api_service.dart` if needed.

## 🔐 Security

**Important**: Never commit API keys to version control!

For production:
1. Use environment variables
2. Store keys in secure storage (e.g., Flutter Secure Storage)
3. Use a backend proxy to hide API keys from the app

## 📞 Support

If you encounter issues:
1. Check API key validity
2. Verify API quotas haven't been exceeded
3. Check network connectivity
4. Review error logs in debug console

## 🎯 Example: Complete Integration

```dart
// In your search screen
final priceService = PriceComparisonService();

// Search products (includes grocery stores)
final products = await priceService.searchProducts(searchQuery);

// Get detailed comparison
final comparison = await priceService.getPriceComparison(productId);

// Display results
for (var storePrice in comparison['prices']) {
  final source = storePrice['source']; // 'local' or 'online'
  final store = storePrice['store'] as Store;
  final price = storePrice['price'] as Price;
  
  if (source == 'online') {
    final groceryProduct = storePrice['groceryProduct'] as GroceryStoreProduct;
    // Show online store with link
    print('${store.name}: RM ${price.price} - ${groceryProduct.productUrl}');
  } else {
    // Show local store
    print('${store.name}: RM ${price.price}');
  }
}
```

Happy price comparing! 🛒💰

