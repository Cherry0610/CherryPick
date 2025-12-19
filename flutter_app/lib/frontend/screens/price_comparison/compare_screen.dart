import 'package:flutter/material.dart';
import '../../../backend/services/price_service.dart';
import '../../../backend/services/wishlist_api_service.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _priceService = PriceService();
  final _wishlistService = WishlistApiService();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _targetCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _product;
  List<Map<String, dynamic>> _storePrices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSearchBar(),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: Colors.white)),
              )
            else ...[
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ),
              if (_product != null) ...[
                _buildProductHeader(context),
                const Divider(color: Colors.white54),
                _buildAvailabilitySection(),
                const Divider(color: Colors.white54),
                _buildActionsRow(),
                _buildAddToWishlistCard(),
              ] else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Search for a product to compare prices.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search groceries (e.g., Milo 1kg, ayam, beras)...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onSubmitted: _loadForQuery,
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    final productName = _product?['name'] ?? 'Product';
    final details = [
      _product?['brand'],
      _product?['size'],
    ].where((e) => (e ?? '').toString().isNotEmpty).join(' • ');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.local_grocery_store, color: Colors.white54, size: 60),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSaveTag('Latest prices'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  productName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color set to white
                  ),
                ),
                Text(
                  details.isEmpty ? 'Product detail' : details,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white, // Text color set to white
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[700],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Available near you',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Text color set to white
            ),
          ),
          const SizedBox(height: 10),
          if (_storePrices.isEmpty)
            const Text('No prices found yet.', style: TextStyle(color: Colors.white70))
          else
            ..._storePrices.map(_buildStorePriceTile),
        ],
      ),
    );
  }

  Widget _buildStorePriceTile(Map<String, dynamic> entry) {
    final price = entry['price'] as Map<String, dynamic>? ?? {};
    final store = entry['store'] as Map<String, dynamic>? ?? {};
    final storeName = (store['name'] ?? 'Store').toString();
    final priceValue = (price['price'] ?? 0).toDouble();
    final currency = (price['currency'] ?? 'RM').toString();
    final isCheapest = identical(entry, _storePrices.isNotEmpty ? _storePrices.first : entry);
    final distanceKm = store['distanceKm'];
    final etaMinutes = store['etaMinutes'];
    final tollRm = store['tollRm'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: isCheapest
            ? Border.all(color: Colors.greenAccent, width: 1)
            : Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(storeName.isNotEmpty ? storeName[0] : '?', style: const TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('$currency ${priceValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isCheapest ? Colors.greenAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(width: 8),
                    if (distanceKm != null && etaMinutes != null && tollRm != null)
                      Text(
                        '• ${distanceKm.toStringAsFixed(1)} km • $etaMinutes min • Toll RM ${tollRm.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.directions_outlined, color: Colors.white),
            onPressed: () {
              // TODO: open Maps/Waze deep link with store location
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              label: const Text('Set price alert', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // TODO: open target price bottom sheet
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout, color: Colors.black),
              label: const Text('Buy / Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // TODO: choose store then open navigation
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToWishlistCard() {
    final productId = _product?['id'] as String?;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track price drops',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set a target price and get notified when any store hits it.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: 'RM ',
                      prefixStyle: const TextStyle(color: Colors.white),
                      hintText: 'e.g. 6.00',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF111111),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    onSubmitted: (_) {
                      // TODO: save alert
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: productId == null ? null : () => _createAlert(productId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('Create alert'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadForQuery(String query) async {
    setState(() {
      _loading = true;
      _error = null;
      _product = null;
      _storePrices = [];
    });
    try {
      final results = await _priceService.search(query);
      if (results.isEmpty) {
        setState(() {
          _error = 'No products found for "$query".';
        });
        return;
      }
      final first = results.first;
      final comparison = await _priceService.compare(first['id'] as String);
      setState(() {
        _product = comparison?['product']?.cast<String, dynamic>() ?? first.cast<String, dynamic>();
        final prices = (comparison?['prices'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        _storePrices = prices;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _createAlert(String productId) async {
    final text = _targetCtrl.text.trim();
    final target = double.tryParse(text);
    if (target == null || target <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid target price')),
        );
      }
      return;
    }
    try {
      await _wishlistService.upsertAlert(productId: productId, targetPrice: target);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
