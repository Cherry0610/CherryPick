import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/navigation_service.dart';
import 'store_details_screen.dart';
import 'navigation_screen.dart';

const Color accentColor = Color(0xFF6DE4E0);
const Color darkCardColor = Color(0xFF1E1E1E);
const Color darkTextColor = Colors.white;

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final _navService = NavigationService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _stores = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await _getPosition();
      final data = await _navService.getNearby(
        lat: position?.latitude ?? 3.139,
        lng: position?.longitude ?? 101.6869,
        limit: 15,
      );
      setState(() {
        _stores = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Position?> _getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return null;
    }
    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Wrap the content in SafeArea to avoid notch/status bar issues
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header Title
            _buildHeaderTitle(),
            const SizedBox(height: 10),

            // Search Bar
            _buildSearchBar(context),
            const SizedBox(height: 15),

            // Sort By Row
            _buildSortByRow(),
            const SizedBox(height: 10),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _stores.length,
                      itemBuilder: (context, index) {
                        return _buildStoreTile(_stores[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeaderTitle() {
    return const Padding(
      padding: EdgeInsets.only(top: 20.0, left: 20.0),
      child: Text(
        'Nearby Stores',
        style: TextStyle(
          color: darkTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: darkCardColor, // Use dark card color for the search field
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: const TextField(
          style: TextStyle(color: darkTextColor),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white70),
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSortByRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Sort by',
            style: TextStyle(
              color: darkTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: darkTextColor,
              size: 28,
            ),
            onPressed: () {
              _showSortOptions(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoreTile(Map<String, dynamic> store) {
    final name = (store['name'] ?? 'Store').toString();
    final distance = (store['distanceKm'] ?? 0).toDouble();
    final eta = (store['etaMinutes'] ?? 0).toInt();
    final toll = (store['tollRm'] ?? 0).toDouble();
    final isCheapest = store == (_stores.isNotEmpty ? _stores.first : store);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: darkCardColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoreDetailsScreen(
                storeId: store['id']?.toString() ?? '',
                storeName: name,
              ),
            ),
          );
        },
        child: Row(
          children: <Widget>[
            // Store Icon
            const Icon(
              Icons.storefront_outlined,
              color: darkTextColor,
              size: 30,
            ),
            const SizedBox(width: 15),
            // Store Details (Name & Distance)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: const TextStyle(
                      color: darkTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Using the same accent color for visual cue
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: accentColor.withAlpha((255 * 0.8).round()),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Distance: ${distance.toStringAsFixed(1)} km • $eta min • Toll RM ${toll.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isCheapest) _buildCheapestTag(),
            IconButton(
              icon: const Icon(
                Icons.directions_outlined,
                color: Colors.white70,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavigationScreen(
                      storeName: name,
                      destinationLat: store['lat']?.toDouble() ?? 3.139,
                      destinationLng: store['lng']?.toDouble() ?? 101.6869,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheapestTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.green, // Bright green for the tag
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: const Text(
        'Cheapest\nToday',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: darkCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort Stores By',
              style: TextStyle(
                color: darkTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(context, 'Distance', Icons.straighten),
            _buildSortOption(context, 'Price', Icons.attach_money),
            _buildSortOption(context, 'Rating', Icons.star),
            _buildSortOption(context, 'Name', Icons.sort_by_alpha),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: darkTextColor),
      title: Text(label, style: const TextStyle(color: darkTextColor)),
      onTap: () {
        Navigator.pop(context);
        // TODO: Implement sorting
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sorting by $label...'),
            backgroundColor: accentColor,
          ),
        );
      },
    );
  }
}
