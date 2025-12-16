import 'package:flutter/material.dart';
import 'barcode_scanner_screen.dart';
import 'advanced_filters_screen.dart';
import 'product_details_screen.dart';

// --- Reusing Consistent Colors ---
const Color kBackgroundColor = Colors.black;
const Color kPrimaryText = Colors.white;
const Color kSecondaryText = Colors.white70;
const Color kAccentColor = Color(0xFF6DE4E0); // Teal Accent
const Color kSearchBarFill = Color(0xFF2B2B2B); // Dark grey fill for search bar
const Color kCardColor = Color(
  0xFF1E1E1E,
); // Slightly lighter black for list background

// Data Models for Lists
class SearchItem {
  final String query;
  final bool isPopular;

  const SearchItem(this.query, {this.isPopular = false});
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  final List<SearchItem> recentSearches = const [
    SearchItem('Wireless Headphones'),
    SearchItem('Instant Noodles'),
    SearchItem('Laptop Stand'),
  ];

  final List<SearchItem> popularSearches = const [
    SearchItem('Milo 1kg', isPopular: true),
    SearchItem('Air Fryer', isPopular: true),
    SearchItem('Diapers', isPopular: true),
  ];

  // Helper Widget for Category/Store Dropdowns
  Widget _buildFilterButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kSecondaryText, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kPrimaryText, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: kPrimaryText, fontSize: 14),
          ),
          const Icon(Icons.keyboard_arrow_down, color: kPrimaryText, size: 18),
        ],
      ),
    );
  }

  // Helper Widget for the List Items (Recent/Popular)
  Widget _buildSearchListItem(BuildContext context, SearchItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1), // Minimal separation
      decoration: const BoxDecoration(color: kCardColor),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        leading: Icon(
          item.isPopular
              ? Icons.local_fire_department
              : Icons.history, // Fire for Popular, History for Recent
          color: item.isPopular ? Colors.orange : kSecondaryText,
        ),
        title: Text(
          item.query,
          style: const TextStyle(color: kPrimaryText, fontSize: 16),
        ),
        trailing: const Icon(Icons.north_east, color: kSecondaryText),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                productId: 'search-${item.query}',
                productName: item.query,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Search',
          style: TextStyle(color: kPrimaryText, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: kPrimaryText),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: kPrimaryText),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedFiltersScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Search Input Field ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: TextField(
                autofocus: true, // Focus on entry for quick searching
                style: const TextStyle(color: kPrimaryText),
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  hintStyle: TextStyle(
                    color: kSecondaryText.withAlpha((255 * 0.5).round()),
                  ),
                  filled: true,
                  fillColor: kSearchBarFill,
                  prefixIcon: const Icon(Icons.search, color: kSecondaryText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          productId: 'search-$value',
                          productName: value,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            // --- Filter Buttons Row ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  _buildFilterButton('Categories', Icons.category_outlined),
                  const SizedBox(width: 15),
                  _buildFilterButton('Stores', Icons.storefront),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // --- Your Recent Searches Section ---
            const Padding(
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
              child: Text(
                'Your Recent Searches',
                style: TextStyle(
                  color: kPrimaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Recent Search List Container (matches the rounded corners of your home screen deals)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: recentSearches
                    .map((item) => _buildSearchListItem(context, item))
                    .toList(),
              ),
            ),

            // --- Popular Searches Section ---
            const Padding(
              padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 10.0),
              child: Text(
                'Popular Searches',
                style: TextStyle(
                  color: kPrimaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Popular Search List Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: popularSearches
                    .map((item) => _buildSearchListItem(context, item))
                    .toList(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
