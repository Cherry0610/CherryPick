import 'backend_client.dart';

class NavigationService {
  NavigationService({BackendClient? client}) : _client = client ?? BackendClient();

  final BackendClient _client;

  Future<List<Map<String, dynamic>>> getNearby({
    required double lat,
    required double lng,
    int limit = 10,
  }) async {
    final res = await _client.getNearbyStores(lat: lat, lng: lng, limit: limit);
    return res.cast<Map<String, dynamic>>();
  }
}


