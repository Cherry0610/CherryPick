import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../wishlist/notifications_log_screen.dart';
import '../../config/app_routes.dart';
import '../../widgets/bottom_navigation_bar.dart';

// Figma Design Colors
const Color kStoreRed = Color(0xFFE85D5D);
const Color kStoreWhite = Color(0xFFFFFFFF);
const Color kStoreBackground = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBorderGray = Color(0xFFE5E7EB);

// Store Model
class Store {
  final String id;
  final String name;
  final String type;
  final double distance;
  final String estimatedTime;
  final String address;
  final String phone;
  final String hours;
  final double rating;
  final String icon; // Keep for fallback
  final String? logoUrl; // URL to the store's logo image
  final Color color;
  final String? onlineStoreUrl; // URL to the store's online website
  final double? latitude; // For accurate map positioning
  final double? longitude; // For accurate map positioning

  Store({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.estimatedTime,
    required this.address,
    required this.phone,
    required this.hours,
    required this.rating,
    required this.icon,
    this.logoUrl,
    required this.color,
    this.onlineStoreUrl,
    this.latitude,
    this.longitude,
  });
}

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  bool _viewMode = false; // false = list, true = map
  Position? _currentPosition;
  String _currentLocationName = 'Getting location...';
  bool _isLoadingLocation = false;
  bool _locationPermissionGranted = false;
  List<Store> _sortedStores = [];
  final TextEditingController _locationController = TextEditingController();
  bool _isManualLocation = false;

  final List<Store> _stores = [
    Store(
      id: '1',
      name: 'Jaya Grocer',
      type: 'Groceries',
      distance: 1.2,
      estimatedTime: '5 min',
      address: 'Pavilion KL, Bukit Bintang',
      phone: '+60 3-2141 6868',
      hours: 'Open until 10 PM',
      rating: 4.5,
      icon: '🥬',
      logoUrl:
          'https://www.jayagrocer.com/wp-content/uploads/2020/06/jaya-grocer-logo.png',
      color: const Color(0xFF50C878),
      onlineStoreUrl: 'https://www.jayagrocer.com',
      latitude: 3.1490,
      longitude: 101.7138,
    ),
    Store(
      id: '2',
      name: 'Village Grocer',
      type: 'Groceries',
      distance: 2.5,
      estimatedTime: '10 min',
      address: 'Bangsar Village II',
      phone: '+60 3-2287 1216',
      hours: 'Open until 11 PM',
      rating: 4.3,
      icon: '🛒',
      logoUrl: 'https://www.villagegrocer.com/images/logo.png',
      color: kStoreRed,
      onlineStoreUrl: 'https://www.villagegrocer.com',
      latitude: 3.1589,
      longitude: 101.6674,
    ),
    Store(
      id: '3',
      name: 'AEON',
      type: 'Supermarket',
      distance: 3.2,
      estimatedTime: '12 min',
      address: 'Mid Valley Megamall',
      phone: '+60 3-2938 3288',
      hours: 'Open until 10 PM',
      rating: 4.4,
      icon: '🏪',
      logoUrl:
          'https://www.aeon.com.my/wp-content/uploads/2020/01/aeon-logo.png',
      color: const Color(0xFF4A90E2),
      onlineStoreUrl: 'https://www.aeon.com.my',
      latitude: 3.1180,
      longitude: 101.6769,
    ),
    Store(
      id: '4',
      name: 'Tesco',
      type: 'Hypermarket',
      distance: 4.1,
      estimatedTime: '15 min',
      address: 'Mutiara Damansara',
      phone: '+60 3-7725 9200',
      hours: 'Open 24/7',
      rating: 4.2,
      icon: '🛍️',
      logoUrl: 'https://www.tesco.com.my/images/tesco-logo.png',
      color: const Color(0xFFF5A623),
      onlineStoreUrl: 'https://www.tesco.com.my',
      latitude: 3.1615,
      longitude: 101.6156,
    ),
    Store(
      id: '5',
      name: 'NSK Grocer',
      type: 'Groceries',
      distance: 5.0,
      estimatedTime: '18 min',
      address: 'Publika Shopping Gallery',
      phone: '+60 3-6211 7119',
      hours: 'Open until 10 PM',
      rating: 4.6,
      icon: '🥑',
      logoUrl: 'https://www.nskgrocer.com/images/nsk-logo.png',
      color: const Color(0xFF8B4513),
      onlineStoreUrl: 'https://www.nskgrocer.com',
      latitude: 3.1700,
      longitude: 101.6200,
    ),
  ];

  Future<void> _handleNavigate(Store store) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(store.address)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Get Google Maps search query for a store name
  String _getStoreMapsQuery(String storeName) {
    final storeNameLower = storeName.toLowerCase();

    if (storeNameLower.contains('nsk') ||
        storeNameLower.contains('nsk grocer')) {
      return 'NSK Grocer Malaysia';
    } else if (storeNameLower.contains('jaya grocer') ||
        storeNameLower.contains('jayagrocer')) {
      return 'Jaya Grocer Malaysia';
    } else if (storeNameLower.contains('lotus')) {
      return 'Lotus Malaysia';
    } else if (storeNameLower.contains('mydin')) {
      return 'Mydin Malaysia';
    } else if (storeNameLower.contains('village grocer')) {
      return 'Village Grocer Malaysia';
    } else if (storeNameLower.contains('aeon')) {
      return 'AEON Malaysia';
    } else if (storeNameLower.contains('tesco')) {
      return 'Tesco Malaysia';
    } else if (storeNameLower.contains('giant')) {
      return 'Giant Malaysia';
    } else if (storeNameLower.contains('speedmart') ||
        storeNameLower.contains('99')) {
      return '99 Speedmart Malaysia';
    } else if (storeNameLower.contains('econsave')) {
      return 'Econsave Malaysia';
    } else if (storeNameLower.contains('cold storage')) {
      return 'Cold Storage Malaysia';
    } else if (storeNameLower.contains('big') ||
        storeNameLower.contains('ben')) {
      return 'B.I.G Malaysia';
    } else {
      return '$storeName Malaysia';
    }
  }

  /// Open Google Maps with nearest store location
  Future<void> _openNearestStoreOnMaps(String storeName) async {
    try {
      final searchQuery = _getStoreMapsQuery(storeName);
      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}',
      );

      debugPrint(
        '🗺️ Opening Google Maps for nearest $storeName: $searchQuery',
      );

      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Showing nearest $storeName locations on Google Maps',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cannot open Google Maps. Please check your internet connection.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error opening Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Google Maps: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleVisitStore(Store store) async {
    // Use the store's online URL if available, otherwise fallback to Google Maps
    String? urlString;
    if (store.onlineStoreUrl != null && store.onlineStoreUrl!.isNotEmpty) {
      urlString = store.onlineStoreUrl!;
    } else {
      // Fallback to store-specific URLs based on store name
      final storeNameLower = store.name.toLowerCase();
      if (storeNameLower.contains('jaya grocer')) {
        urlString = 'https://www.jayagrocer.com';
      } else if (storeNameLower.contains('village grocer')) {
        urlString = 'https://www.villagegrocer.com';
      } else if (storeNameLower.contains('aeon')) {
        urlString = 'https://www.aeon.com.my';
      } else if (storeNameLower.contains('tesco')) {
        urlString = 'https://www.tesco.com.my';
      } else if (storeNameLower.contains('nsk')) {
        urlString = 'https://www.nskgrocer.com';
      } else if (storeNameLower.contains('giant')) {
        urlString = 'https://www.giant.com.my';
      } else if (storeNameLower.contains('mydin')) {
        urlString = 'https://www.mydin.com.my';
      } else if (storeNameLower.contains('speedmart') ||
          storeNameLower.contains('99')) {
        urlString = 'https://www.99speedmart.com.my';
      } else if (storeNameLower.contains('econsave')) {
        urlString = 'https://www.econsave.com.my';
      } else if (storeNameLower.contains('lotus')) {
        urlString = 'https://www.lotuss.com.my';
      } else if (storeNameLower.contains('cold storage')) {
        urlString = 'https://www.coldstorage.com.my';
      } else if (storeNameLower.contains('big') ||
          storeNameLower.contains('ben')) {
        urlString = 'https://www.big.com.my';
      }
    }

    // If no URL found, directly open Google Maps
    if (urlString == null || urlString.isEmpty) {
      await _openNearestStoreOnMaps(store.name);
      return;
    }

    try {
      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return; // Success, exit early
        } catch (e) {
          debugPrint('⚠️ Error launching URL, falling back to Google Maps: $e');
          // Fall through to Google Maps fallback
        }
      } else {
        debugPrint('⚠️ URL cannot be launched, falling back to Google Maps');
        // Fall through to Google Maps fallback
      }

      // If we reach here, the URL couldn't be opened - fallback to Google Maps
      await _openNearestStoreOnMaps(store.name);
    } catch (e) {
      debugPrint('❌ Error opening store website: $e');
      // On any error, try Google Maps as fallback
      await _openNearestStoreOnMaps(store.name);
    }
  }

  @override
  void initState() {
    super.initState();
    _sortedStores = List.from(_stores);
    _locationController.text = _currentLocationName;
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please enable location services in your device settings',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
          _currentLocationName = 'Location services disabled';
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location permission is required to find nearby stores',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() {
            _isLoadingLocation = false;
            _currentLocationName = 'Permission denied';
            _locationPermissionGranted = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission is permanently denied. Please enable it in settings.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
          _currentLocationName = 'Permission denied';
          _locationPermissionGranted = false;
        });
        return;
      }

      // Permission granted, get current location
      _locationPermissionGranted = true;
      await _getCurrentLocation();
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      setState(() {
        _isLoadingLocation = false;
        _currentLocationName = 'Error getting location';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _currentLocationName = 'Getting location...';
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() => _currentPosition = position);

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');

          final addressText = address.isNotEmpty ? address : 'Current Location';
          setState(() {
            _currentLocationName = addressText;
            _locationController.text = addressText;
            _isManualLocation = false;
          });

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Location found: $addressText'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          final locationText =
              'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          setState(() {
            _currentLocationName = locationText;
            _locationController.text = locationText;
            _isManualLocation = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location found. You can edit the address above.',
                ),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _currentLocationName = 'Current Location';
          _locationController.text = 'Current Location';
          _isManualLocation = false;
        });
      }

      // Calculate distances and sort stores
      _calculateDistancesAndSort();

      setState(() => _isLoadingLocation = false);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      setState(() {
        _isLoadingLocation = false;
        _currentLocationName = 'Unable to get location';
      });
    }
  }

  void _calculateDistancesAndSort() {
    if (_currentPosition == null) {
      _sortedStores = List.from(_stores);
      return;
    }

    // Calculate distance for each store
    final storesWithDistance = _stores.map((store) {
      double distance = 0.0;
      if (store.latitude != null && store.longitude != null) {
        distance =
            Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              store.latitude!,
              store.longitude!,
            ) /
            1000; // Convert to kilometers
      }
      return Store(
        id: store.id,
        name: store.name,
        type: store.type,
        distance: distance,
        estimatedTime: _calculateEstimatedTime(distance),
        address: store.address,
        phone: store.phone,
        hours: store.hours,
        rating: store.rating,
        icon: store.icon,
        logoUrl: store.logoUrl,
        color: store.color,
        onlineStoreUrl: store.onlineStoreUrl,
        latitude: store.latitude,
        longitude: store.longitude,
      );
    }).toList();

    // Sort by distance (closest first)
    storesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() => _sortedStores = storesWithDistance);
  }

  String _calculateEstimatedTime(double distanceKm) {
    // Assume average speed of 30 km/h in city
    final minutes = (distanceKm / 30 * 60).round();
    if (minutes < 1) return '< 1 min';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '$hours h $mins min' : '$hours h';
  }

  Future<void> _showLocationPicker() async {
    // Show dialog to manually set location
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => const _LocationPickerDialog(),
    );

    if (result != null) {
      setState(() {
        _currentPosition = Position(
          latitude: result['lat']!,
          longitude: result['lng']!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        _currentLocationName = 'Custom Location';
        _locationController.text = 'Custom Location';
        _isManualLocation = true;
        _isLoadingLocation = false;
      });
      _calculateDistancesAndSort();
    }
  }

  /// Search location by address using geocoding
  Future<void> _searchLocationByAddress(String address) async {
    if (address.trim().isEmpty) return;

    setState(() {
      _isLoadingLocation = true;
      _currentLocationName = address;
    });

    try {
      // Use geocoding to convert address to coordinates
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _currentPosition = Position(
            latitude: location.latitude,
            longitude: location.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
          _currentLocationName = address;
          _locationController.text = address;
          _isManualLocation = true;
        });

        // Try to get a more detailed address
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final detailedAddress = [
              place.street,
              place.subLocality,
              place.locality,
              place.administrativeArea,
            ].where((e) => e != null && e.isNotEmpty).join(', ');

            if (detailedAddress.isNotEmpty) {
              setState(() {
                _currentLocationName = detailedAddress;
                _locationController.text = detailedAddress;
              });
            }
          }
        } catch (e) {
          debugPrint('Error getting detailed address: $e');
        }

        // Calculate distances and sort stores
        _calculateDistancesAndSort();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location set to: $address'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not find location: $address'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error searching location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finding location: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kStoreBackground,
      appBar: AppBar(
        backgroundColor: kStoreWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          ),
        ),
        title: const Text(
          'Nearby Stores',
          style: TextStyle(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: kTextLight),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kStoreRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsLogScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Bar
              _buildLocationBar(),
              const SizedBox(height: 16),
              // View Toggle
              _buildViewToggle(),
              const SizedBox(height: 16),

              // Map View or List View
              if (_viewMode)
                _buildMapView()
              else
                _buildListView(
                  _sortedStores.isNotEmpty ? _sortedStores : _stores,
                ),

              const SizedBox(height: 16),

              // Store Info Note
              _buildStoreInfoNote(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildLocationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isLoadingLocation ? Icons.location_searching : Icons.location_on,
            color: (_locationPermissionGranted || _isManualLocation)
                ? kStoreRed
                : kTextLight,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoadingLocation
                      ? 'Getting location...'
                      : (_isManualLocation
                            ? 'Search Location'
                            : 'Current Location'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextLight,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: _locationController,
                  enabled: !_isLoadingLocation,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (_locationPermissionGranted || _isManualLocation)
                        ? kTextDark
                        : kTextLight,
                    fontFamily: 'Roboto',
                  ),
                  decoration: InputDecoration(
                    hintText: _isLoadingLocation
                        ? 'Getting location...'
                        : 'Enter address or tap GPS button',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: kTextLight.withValues(alpha: 0.5),
                      fontFamily: 'Roboto',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _searchLocationByAddress(value.trim());
                    }
                  },
                  onChanged: (value) {
                    // Update location name as user types
                    if (value.isNotEmpty) {
                      setState(() {
                        _currentLocationName = value;
                        _isManualLocation = true;
                      });
                    } else {
                      setState(() {
                        _isManualLocation = false;
                      });
                    }
                  },
                  onTap: () {
                    // When user taps the field, ensure it's editable
                    if (_locationController.text.isEmpty) {
                      _locationController.text = '';
                    }
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_location_alt, color: kStoreRed, size: 20),
            onPressed: _showLocationPicker,
            tooltip: 'Set location manually',
          ),
          IconButton(
            icon: Icon(
              _isManualLocation ? Icons.my_location : Icons.refresh,
              color: kStoreRed,
              size: 20,
            ),
            onPressed: _isLoadingLocation
                ? null
                : (_isManualLocation
                      ? () {
                          // Switch back to GPS location
                          _isManualLocation = false;
                          _requestLocationPermission();
                        }
                      : () {
                          // Get current GPS location and show in bar
                          _requestLocationPermission();
                        }),
            tooltip: _isManualLocation
                ? 'Use GPS location'
                : 'Get current location',
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton('List View', false)),
          Expanded(child: _buildToggleButton('Map View', true)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isMap) {
    final isActive = _viewMode == isMap;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = isMap),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? kStoreRed : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMap) const Icon(Icons.map, size: 16, color: kStoreWhite),
            if (isMap) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? kStoreWhite : kTextDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    // Calculate map bounds based on store locations
    final storesWithLocation = _stores
        .where((s) => s.latitude != null && s.longitude != null)
        .toList();
    double? minLat, maxLat, minLng, maxLng;

    if (storesWithLocation.isNotEmpty) {
      minLat = storesWithLocation
          .map((s) => s.latitude!)
          .reduce((a, b) => a < b ? a : b);
      maxLat = storesWithLocation
          .map((s) => s.latitude!)
          .reduce((a, b) => a > b ? a : b);
      minLng = storesWithLocation
          .map((s) => s.longitude!)
          .reduce((a, b) => a < b ? a : b);
      maxLng = storesWithLocation
          .map((s) => s.longitude!)
          .reduce((a, b) => a > b ? a : b);
    }

    // Default to KL city center if no locations
    final centerLat = minLat != null ? (minLat + maxLat!) / 2 : 3.1390;
    final centerLng = minLng != null ? (minLng + maxLng!) / 2 : 101.6869;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Map with Google Maps integration
          GestureDetector(
            onTap: () async {
              // Open Google Maps with center location
              final url = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=$centerLat,$centerLng',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[100]!, Colors.grey[200]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 64, color: kStoreRed),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap to open in Google Maps',
                      style: TextStyle(
                        color: kTextLight,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Text(
                      '${_stores.length} stores nearby',
                      style: TextStyle(
                        color: kTextLight.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Store markers positioned based on actual coordinates
          ...storesWithLocation.asMap().entries.map((entry) {
            final store = entry.value;
            // Normalize coordinates to container size (400x400)
            final normalizedLat = ((store.latitude! - centerLat) * 10000) + 200;
            final normalizedLng =
                ((store.longitude! - centerLng) * 10000) + 200;

            return Positioned(
              left: normalizedLng.clamp(20.0, 380.0),
              top: normalizedLat.clamp(20.0, 380.0),
              child: GestureDetector(
                onTap: () {
                  // Show store details
                  _showStoreDetails(store);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: store.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: kStoreWhite, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: _buildStoreLogo(store, size: 24)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showStoreDetails(Store store) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: store.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: _buildStoreLogo(store, size: 32)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                        ),
                      ),
                      Text(
                        store.type,
                        style: const TextStyle(fontSize: 14, color: kTextLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStoreDetail(Icons.location_on, store.address),
            const SizedBox(height: 8),
            _buildStoreDetail(Icons.access_time, store.hours),
            const SizedBox(height: 8),
            _buildStoreDetail(Icons.phone, store.phone),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleNavigate(store);
                    },
                    icon: const Icon(Icons.navigation, size: 16),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kStoreRed,
                      foregroundColor: kStoreWhite,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleVisitStore(store);
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Visit Store'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorderGray),
                      foregroundColor: kTextDark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Store> stores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${stores.length} Stores Nearby',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kTextDark,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 12),
        ...stores.map((store) => _buildStoreCard(store)),
      ],
    );
  }

  Widget _buildStoreCard(Store store) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Logo
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: store.color.withValues(alpha: 0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildStoreLogo(store, size: 56),
            ),
          ),
          const SizedBox(width: 16),
          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kTextDark,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          Text(
                            store.type,
                            style: const TextStyle(
                              fontSize: 12,
                              color: kTextLight,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${store.distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kStoreRed,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          store.estimatedTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kTextLight,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Store Details
                _buildStoreDetail(Icons.location_on, store.address),
                const SizedBox(height: 8),
                _buildStoreDetail(Icons.access_time, store.hours),
                const SizedBox(height: 8),
                _buildStoreDetail(Icons.phone, store.phone),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleNavigate(store),
                        icon: const Icon(Icons.navigation, size: 16),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kStoreRed,
                          foregroundColor: kStoreWhite,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleVisitStore(store),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Visit Store'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kBorderGray),
                          foregroundColor: kTextDark,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get store logo asset path based on store name
  String? _getStoreLogoAsset(String storeName) {
    final storeNameLower = storeName.toLowerCase();

    if (storeNameLower.contains('jaya grocer') ||
        storeNameLower.contains('jayagrocer')) {
      return 'assets/images/stores/jaya_grocer.png';
    } else if (storeNameLower.contains('lotus')) {
      return 'assets/images/stores/lotus.png';
    } else if (storeNameLower.contains('mydin')) {
      return 'assets/images/stores/mydin.png';
    } else if (storeNameLower.contains('nsk') ||
        storeNameLower.contains('nsk grocer')) {
      return 'assets/images/stores/nsk_grocer.png';
    } else if (storeNameLower.contains('aeon')) {
      return 'assets/images/stores/aeon.png';
    } else if (storeNameLower.contains('tesco')) {
      return 'assets/images/stores/tesco.png';
    } else if (storeNameLower.contains('village grocer')) {
      return 'assets/images/stores/village_grocer.png';
    }

    return null;
  }

  Widget _buildStoreLogo(Store store, {double size = 40}) {
    // Priority: 1. Local asset, 2. Network logo URL, 3. Fallback icon
    final localAssetPath = _getStoreLogoAsset(store.name);

    // Try local asset first
    if (localAssetPath != null && localAssetPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorderGray, width: 1),
          ),
          child: Image.asset(
            localAssetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to network logo if asset fails
              return _buildNetworkLogo(store, size);
            },
          ),
        ),
      );
    }

    // Try network logo if no local asset
    return _buildNetworkLogo(store, size);
  }

  Widget _buildNetworkLogo(Store store, double size) {
    // Get logo URL with fallback to a more reliable source
    String? logoUrl = store.logoUrl;

    // If no logo URL provided, try to get a default one based on store name
    if (logoUrl == null || logoUrl.isEmpty) {
      logoUrl = _getDefaultLogoUrl(store.name);
    }

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorderGray, width: 1),
          ),
          child: Image.network(
            logoUrl,
            width: size,
            height: size,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: size * 0.5,
                  height: size * 0.5,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // Fallback to store name initial if logo fails to load
              return _buildFallbackLogo(store, size);
            },
          ),
        ),
      );
    } else {
      // Fallback to store name initial if no logo URL
      return _buildFallbackLogo(store, size);
    }
  }

  Widget _buildFallbackLogo(Store store, double size) {
    // Use store name initial instead of emoji icon
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: store.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderGray, width: 1),
      ),
      child: Center(
        child: Text(
          store.name.isNotEmpty ? store.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: store.color,
          ),
        ),
      ),
    );
  }

  String? _getDefaultLogoUrl(String storeName) {
    // Map store names to their logo URLs
    final storeNameLower = storeName.toLowerCase();

    if (storeNameLower.contains('jaya grocer')) {
      return 'https://www.jayagrocer.com/wp-content/uploads/2020/06/jaya-grocer-logo.png';
    } else if (storeNameLower.contains('village grocer')) {
      return 'https://www.villagegrocer.com/images/logo.png';
    } else if (storeNameLower.contains('aeon')) {
      return 'https://www.aeon.com.my/wp-content/uploads/2020/01/aeon-logo.png';
    } else if (storeNameLower.contains('tesco')) {
      return 'https://www.tesco.com.my/images/tesco-logo.png';
    } else if (storeNameLower.contains('nsk')) {
      return 'https://www.nskgrocer.com/images/nsk-logo.png';
    } else if (storeNameLower.contains('giant')) {
      return 'https://www.giant.com.my/images/giant-logo.png';
    } else if (storeNameLower.contains('mydin')) {
      return 'https://www.mydin.com.my/images/mydin-logo.png';
    } else if (storeNameLower.contains('speedmart') ||
        storeNameLower.contains('99')) {
      return 'https://www.99speedmart.com.my/images/logo.png';
    } else if (storeNameLower.contains('econsave')) {
      return 'https://www.econsave.com.my/images/logo.png';
    } else if (storeNameLower.contains('hero market')) {
      return 'https://www.heromarket.com.my/images/logo.png';
    } else if (storeNameLower.contains('the store')) {
      return 'https://www.thestore.com.my/images/logo.png';
    } else if (storeNameLower.contains('pacific')) {
      return 'https://www.pacific.com.my/images/logo.png';
    } else if (storeNameLower.contains('lotus')) {
      return 'https://www.lotuss.com.my/images/logo.png';
    } else if (storeNameLower.contains('cold storage')) {
      return 'https://www.coldstorage.com.my/images/logo.png';
    } else if (storeNameLower.contains('big') ||
        storeNameLower.contains('ben')) {
      return 'https://www.big.com.my/images/logo.png';
    }

    return null;
  }

  Widget _buildStoreDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kTextLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: kTextLight,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, size: 16, color: kTextLight),
              const SizedBox(width: 8),
              const Text(
                'Tolls may apply',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated times are based on current traffic conditions',
            style: TextStyle(
              color: kTextLight.withValues(alpha: 0.7),
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

// Location Picker Dialog
class _LocationPickerDialog extends StatefulWidget {
  const _LocationPickerDialog();

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  final _latController = TextEditingController(text: '3.1390'); // Default KL
  final _lngController = TextEditingController(text: '101.6869');

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Custom Location'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _latController,
            decoration: const InputDecoration(
              labelText: 'Latitude',
              hintText: 'e.g., 3.1390',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lngController,
            decoration: const InputDecoration(
              labelText: 'Longitude',
              hintText: 'e.g., 101.6869',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final lat = double.tryParse(_latController.text);
            final lng = double.tryParse(_lngController.text);
            if (lat != null &&
                lng != null &&
                lat >= -90 &&
                lat <= 90 &&
                lng >= -180 &&
                lng <= 180) {
              Navigator.pop(context, {'lat': lat, 'lng': lng});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter valid coordinates'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kStoreRed,
            foregroundColor: kStoreWhite,
          ),
          child: const Text('Set Location'),
        ),
      ],
    );
  }
}
