import 'package:flutter/material.dart';

class ReceiptDetailsScreen extends StatelessWidget {
  const ReceiptDetailsScreen({super.key});

  // Mock Data (using Malaysian Ringgit - RM, as shown in the image)
  final String storeName = 'Jaya Grocer';
  final double totalAmount = 125.50;
  final String dateTime = '25 October 2023, 08:45 PM';
  final String category = 'Groceries';
  // Use a temporary placeholder for the image path. In a real project, ensure this asset exists.
  final String receiptImageUrl = 'assets/receipt_image.jpg';

  final List<Map<String, dynamic>> items = const [
    {'name': 'Milk', 'quantity': 1, 'price': 7.50, 'icon': Icons.local_bar},
    {'name': 'Bread', 'quantity': 1, 'price': 4.20, 'icon': Icons.bakery_dining},
    {'name': 'Apples', 'quantity': 5, 'price': 10.00, 'icon': Icons.shopping_basket},
    {'name': 'Organic Eggs (12-pack)', 'quantity': 1, 'price': 12.80, 'icon': Icons.egg},
  ];

  // A bright accent color, similar to the previous component
  static const Color accentColor = Color(0xFF6DE4E0);

  @override
  Widget build(BuildContext context) {
    // NOTE: This screen usually sits on top of the main navigation structure.
    // Including a full bottom bar here is redundant, but kept for completeness
    // based on the previous screen's code.
    const int currentTabIndex = 2;

    return Scaffold(
      // 1. Black background
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Receipt Image Area
            _buildReceiptImageArea(context),

            // Store & Total Details
            _buildStoreDetailsSection(context),

            // Itemized List
            _buildItemsSection(),

            // Category Tag
            _buildCategorySection(),

            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(currentTabIndex),
    );
  }

  // --- Widget Builders ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Receipt Details',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        // Delete Icon
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            // Implement Delete functionality
            debugPrint('Delete button pressed');
          },
        ),
      ],
    );
  }

  Widget _buildReceiptImageArea(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        // Use a descriptive placeholder image if the asset is missing
        child: Image.asset(
          receiptImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 50, color: Colors.white30),
                const SizedBox(height: 8),
                Text('Receipt Image: $receiptImageUrl', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Store Name and Label
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Store Name', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(
                    storeName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24, // Explicit font size for clarity
                    ),
                  ),
                ],
              ),
              // Total Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Amount', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: accentColor, // Use accent color
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date & Time
          const Text('Date & Time', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            dateTime,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Items',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Use map to generate item tiles
        ...items.map((item) => _buildItemTile(item)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: Colors.white10),
        ),
      ],
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Icon(
              item['icon'] as IconData, // Cast to IconData
              color: accentColor, // Use accent color for item icons
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Name and Quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String, // Cast to String
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Quantity: ${item['quantity']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Price
          Text(
            'RM ${(item['price'] as double).toStringAsFixed(2)}', // Cast and format price
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Category Tag (Pill shape)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: accentColor.withAlpha((255 * 0.1).round()), // Subtle accent background
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: accentColor.withAlpha((255 * 0.5).round())),
            ),
            child: Text(
              category,
              style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Edit Details Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: accentColor, // Use accent color for the main action
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              debugPrint('Edit Details pressed');
            },
            child: const Text(
              'Edit Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Delete Receipt Button
          TextButton(
            onPressed: () {
              debugPrint('Delete Receipt pressed (from text button)');
            },
            child: const Text(
              'Delete Receipt',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Improvement: Use a simpler BottomAppBar if this screen is not the main container
  Widget _buildBottomNavBar(int currentIndex) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: accentColor, // Use the accent color here
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: 'Stores'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      onTap: (index) {
        // Handle navigation changes
      },
    );
  }
}
