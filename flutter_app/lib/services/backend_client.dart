import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Thin wrapper over the backend REST API.
class BackendClient {
  BackendClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _base = AppConfig.apiBaseUrl;

  Uri _u(String path, [Map<String, String>? params]) =>
      Uri.parse('$_base$path').replace(queryParameters: params);

  Future<List<dynamic>> searchProducts(String query) async {
    final res = await _client.get(_u('/products/search', {'q': query}));
    _ensureOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>?> getProduct(String id) async {
    final res = await _client.get(_u('/products/$id'));
    _ensureOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>?;
  }

  Future<List<dynamic>> getProductPrices(String productId) async {
    final res = await _client.get(_u('/prices/product/$productId'));
    _ensureOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>?> getPriceComparison(String productId) async {
    final res = await _client.get(_u('/prices/compare/$productId'));
    _ensureOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>?;
  }

  Future<List<dynamic>> getNearbyStores({
    required double lat,
    required double lng,
    int limit = 10,
  }) async {
    final res = await _client.get(_u('/navigation/nearby', {
      'lat': '$lat',
      'lng': '$lng',
      'limit': '$limit',
    }));
    _ensureOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> getWishlist({required String idToken}) async {
    final res = await _client.get(
      _u('/wishlist'),
      headers: {'Authorization': 'Bearer $idToken'},
    );
    _ensureOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>? ?? [];
  }

  Future<void> upsertWishlist({
    required String idToken,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _client.post(
      _u('/wishlist'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    _ensureOk(res);
  }

  Future<List<dynamic>> getExpenses({
    required String idToken,
    String? month,
  }) async {
    final params = <String, String>{};
    if (month != null) params['month'] = month;
    final res = await _client.get(
      _u('/expenses', params),
      headers: {'Authorization': 'Bearer $idToken'},
    );
    _ensureOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>? ?? [];
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}

