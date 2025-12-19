import 'dart:async';
import 'backend_client.dart';

/// PriceService talks to the Node backend for search and price comparison.
class PriceService {
  PriceService({BackendClient? client}) : _client = client ?? BackendClient();

  final BackendClient _client;

  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final results = await _client.searchProducts(query);
    return results.cast<Map<String, dynamic>>();
  }

  /// Returns {product, prices, lowestPrice, highestPrice, averagePrice}
  Future<Map<String, dynamic>?> compare(String productId) async {
    if (productId.isEmpty) return null;
    final data = await _client.getPriceComparison(productId);
    return data;
  }
}

