/// Configuration for grocery store API integrations
class GroceryApiConfig {
  // Enable/disable specific grocery store APIs
  static const bool enableShopee = true;
  static const bool enableLazada = true;
  static const bool enableGrabMart = true;
  static const bool enableTesco = true;
  static const bool enableGiant = true;
  static const bool enableAeon = true;
  static const bool enableAeonBig = true;
  static const bool enableNsk = true;
  static const bool enableVillageGrocer = true;
  static const bool enableJayaGrocer = true;
  static const bool enableMydin = true;
  static const bool enableSpeedmart = true;
  static const bool enableEconsave = true;
  static const bool enableHeroMarket = true;
  static const bool enableTheStore = true;
  static const bool enablePacific = true;
  static const bool enableHappyFresh = true;
  static const bool enablePandamart = true;
  static const bool enableLotus = true;
  static const bool enableBig = true; // Ben's Independent Grocer
  static const bool enableColdStorage = true;
  static const bool enableMercato = true;
  static const bool enableRedMart = true;
  static const bool enableTheFoodPurveyor = true;

  // API Keys (Add your API keys here)
  // For production, use environment variables or secure storage
  static const String shopeeApiKey = ''; // Add your Shopee API key
  static const String lazadaApiKey = ''; // Add your Lazada API key
  static const String grabMartApiKey = ''; // Add your GrabMart API key

  // ScrapingBee API (for web scraping fallback)
  static const String scrapingBeeApiKey = ''; // Add your ScrapingBee API key

  // Foodspark API (alternative grocery data API)
  static const String foodsparkApiKey = ''; // Add your Foodspark API key

  // API Base URLs
  static const String shopeeApiBaseUrl = 'https://open.shopee.com/api/v2';
  static const String lazadaApiBaseUrl = 'https://api.lazada.com.my/rest';
  static const String grabMartApiBaseUrl = 'https://api.grab.com/grabmart/v1';
  static const String scrapingBeeApiBaseUrl =
      'https://app.scrapingbee.com/api/v1';
  static const String foodsparkApiBaseUrl = 'https://api.foodspark.io/v1';

  // Rate limiting (requests per minute)
  static const int shopeeRateLimit = 60;
  static const int lazadaRateLimit = 60;
  static const int grabMartRateLimit = 30;
  static const int scrapingBeeRateLimit = 100;

  // Timeout settings (in seconds)
  static const int requestTimeout = 10;
  static const int connectionTimeout = 5;

  // Retry settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Cache settings
  static const Duration cacheDuration = Duration(
    minutes: 15,
  ); // Cache results for 15 minutes

  /// Get list of enabled stores
  static List<String> get enabledStores {
    final List<String> stores = [];
    if (enableShopee) stores.add('Shopee');
    if (enableLazada) stores.add('Lazada');
    if (enableGrabMart) stores.add('GrabMart');
    if (enableTesco) stores.add('Tesco');
    if (enableGiant) stores.add('Giant');
    if (enableAeon) stores.add('AEON');
    if (enableAeonBig) stores.add('AEON Big');
    if (enableNsk) stores.add('NSK');
    if (enableVillageGrocer) stores.add('Village Grocer');
    if (enableJayaGrocer) stores.add('Jaya Grocer');
    if (enableMydin) stores.add('Mydin');
    if (enableSpeedmart) stores.add('99 Speedmart');
    if (enableEconsave) stores.add('Econsave');
    if (enableHeroMarket) stores.add('Hero Market');
    if (enableTheStore) stores.add('The Store');
    if (enablePacific) stores.add('Pacific');
    if (enableHappyFresh) stores.add('HappyFresh');
    if (enablePandamart) stores.add('Pandamart');
    if (enableLotus) stores.add('Lotus\'s');
    if (enableBig) stores.add('B.I.G');
    if (enableColdStorage) stores.add('Cold Storage');
    if (enableMercato) stores.add('Mercato');
    if (enableRedMart) stores.add('RedMart');
    if (enableTheFoodPurveyor) stores.add('The Food Purveyor');
    return stores;
  }

  /// Check if API key is configured for a store
  static bool hasApiKey(String storeName) {
    switch (storeName.toLowerCase()) {
      case 'shopee':
        return shopeeApiKey.isNotEmpty;
      case 'lazada':
        return lazadaApiKey.isNotEmpty;
      case 'grabmart':
        return grabMartApiKey.isNotEmpty;
      default:
        return false;
    }
  }
}
