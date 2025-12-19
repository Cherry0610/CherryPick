import 'package:flutter/material.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class NavigationScreen extends StatefulWidget {
  final String storeName;
  final double destinationLat;
  final double destinationLng;

  const NavigationScreen({
    super.key,
    required this.storeName,
    required this.destinationLat,
    required this.destinationLng,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  String _selectedRoute = 'Fastest'; // Fastest, Shortest, Cheapest
  bool _avoidTolls = false;
  bool _avoidHighways = false;

  // Mock route data
  final List<RouteOption> _routes = [
    RouteOption(
      name: 'Fastest Route',
      distance: 8.5,
      duration: 15,
      tollFee: 2.50,
      traffic: 'Moderate',
    ),
    RouteOption(
      name: 'Shortest Route',
      distance: 6.2,
      duration: 18,
      tollFee: 0.00,
      traffic: 'Heavy',
    ),
    RouteOption(
      name: 'Cheapest Route',
      distance: 9.1,
      duration: 20,
      tollFee: 0.00,
      traffic: 'Light',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Navigation',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: kBlack),
            onPressed: _showRouteOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Preview (Placeholder)
          Container(
            height: 300,
            width: double.infinity,
            color: kLightGray,
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.map, size: 60, color: kMediumGray),
                ),
                // Start marker
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kBlack,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: kWhite,
                      size: 20,
                    ),
                  ),
                ),
                // End marker
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kBlack,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.place, color: kWhite, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Route Info
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kLightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store, color: kBlack, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Destination',
                                style: TextStyle(
                                  color: kMediumGray,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.storeName,
                                style: const TextStyle(
                                  color: kBlack,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selected Route Details
                  _buildSelectedRouteCard(),
                  const SizedBox(height: 24),

                  // Alternative Routes
                  const Text(
                    'Alternative Routes',
                    style: TextStyle(
                      color: kBlack,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._routes
                      .where((r) => r.name != _selectedRoute)
                      .map((route) => _buildRouteCard(route)),
                ],
              ),
            ),
          ),

          // Start Navigation Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              border: Border(
                top: BorderSide(color: kMediumGray.withValues(alpha: 0.2)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlack,
                  foregroundColor: kWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.navigation, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Start Navigation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedRouteCard() {
    final route = _routes.firstWhere((r) => r.name.contains(_selectedRoute));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBlack,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildRouteStat(
                  Icons.straighten,
                  '${route.distance.toStringAsFixed(1)} km',
                  'Distance',
                ),
              ),
              Container(width: 1, height: 40, color: kWhite.withValues(alpha: 0.2)),
              Expanded(
                child: _buildRouteStat(
                  Icons.access_time,
                  '${route.duration} min',
                  'Duration',
                ),
              ),
              Container(width: 1, height: 40, color: kWhite.withValues(alpha: 0.2)),
              Expanded(
                child: _buildRouteStat(
                  Icons.toll,
                  'RM ${route.tollFee.toStringAsFixed(2)}',
                  'Toll',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getTrafficIcon(route.traffic), size: 16, color: kWhite),
                const SizedBox(width: 6),
                Text(
                  'Traffic: ${route.traffic}',
                  style: const TextStyle(
                    color: kWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: kWhite, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: kWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: kWhite.withValues(alpha: 0.7), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildRouteCard(RouteOption route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kMediumGray.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRoute = route.name.split(' ').first;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRouteInfo(
                          Icons.straighten,
                          '${route.distance.toStringAsFixed(1)} km',
                        ),
                        const SizedBox(width: 16),
                        _buildRouteInfo(
                          Icons.access_time,
                          '${route.duration} min',
                        ),
                        const SizedBox(width: 16),
                        _buildRouteInfo(
                          Icons.toll,
                          'RM ${route.tollFee.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getTrafficIcon(route.traffic),
                          size: 14,
                          color: kMediumGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Traffic: ${route.traffic}',
                          style: const TextStyle(
                            color: kMediumGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kMediumGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kMediumGray),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: kMediumGray, fontSize: 12)),
      ],
    );
  }

  IconData _getTrafficIcon(String traffic) {
    switch (traffic) {
      case 'Light':
        return Icons.check_circle;
      case 'Moderate':
        return Icons.info;
      case 'Heavy':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  void _showRouteOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kWhite,
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
              'Route Options',
              style: TextStyle(
                color: kBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              value: _avoidTolls,
              onChanged: (value) {
                setState(() {
                  _avoidTolls = value;
                });
                Navigator.pop(context);
              },
              title: const Text('Avoid Tolls'),
              activeThumbColor: kBlack,
            ),
            SwitchListTile(
              value: _avoidHighways,
              onChanged: (value) {
                setState(() {
                  _avoidHighways = value;
                });
                Navigator.pop(context);
              },
              title: const Text('Avoid Highways'),
              activeThumbColor: kBlack,
            ),
          ],
        ),
      ),
    );
  }

  void _startNavigation() {
    // TODO: Open external navigation app (Waze, Google Maps)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening navigation app...'),
        backgroundColor: kBlack,
      ),
    );
  }
}

class RouteOption {
  final String name;
  final double distance;
  final int duration;
  final double tollFee;
  final String traffic;

  RouteOption({
    required this.name,
    required this.distance,
    required this.duration,
    required this.tollFee,
    required this.traffic,
  });
}


