import 'package:firebase_auth/firebase_auth.dart';
import 'backend_client.dart';

class WishlistApiService {
  WishlistApiService({BackendClient? client}) : _client = client ?? BackendClient();

  final BackendClient _client;

  Future<void> upsertAlert({
    required String productId,
    required double targetPrice,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Please sign in to create alerts.');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Unable to fetch auth token.');
    }
    await _client.upsertWishlist(
      idToken: token,
      payload: {
        'productId': productId,
        'targetPrice': targetPrice,
      },
    );
  }
}

