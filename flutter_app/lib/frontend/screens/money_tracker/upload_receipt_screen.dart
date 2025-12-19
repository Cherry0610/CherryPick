import 'package:flutter/material.dart';

class ReceiptUploadScreen extends StatelessWidget {
  const ReceiptUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the active index for the BottomNavigationBar based on the image
    const int currentTabIndex = 2; // Assuming 'Scan Receipt' is index 2

    return Scaffold(
      // Set the overall background to black for the dark theme
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Instructions
            const Text(
              'Take a photo of your receipt or upload one from your gallery.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Image Placeholder Area
            _buildReceiptImagePlaceholder(),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButton(
              icon: Icons.camera_alt_outlined,
              text: 'Take Photo',
              onPressed: () {
                // Implement photo taking logic
                debugPrint('Take Photo pressed');
              },
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              icon: Icons.image_outlined,
              text: 'Choose from Gallery',
              onPressed: () {
                // Implement gallery selection logic
                debugPrint('Choose from Gallery pressed');
              },
            ),
            const SizedBox(height: 30),

            // Manual Input Fields
            _buildLabel('Store Name'),
            const SizedBox(height: 8),
            _buildTextField(hint: 'Enter store name', keyboardType: TextInputType.text),
            const SizedBox(height: 20),

            // Total Amount and Date (Row layout)
            Row(
              children: <Widget>[
                // Total Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Total Amount'),
                      const SizedBox(height: 8),
                      _buildTextField(hint: '0.00', keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Date'),
                      const SizedBox(height: 8),
                      _buildDateTextField(context),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category Dropdown
            _buildLabel('Category'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(currentTabIndex),
    );
  }

  // --- Widget Builders ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black, // Match the body background
      iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      title: const Text(
        'Upload Receipt',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildReceiptImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Colors.white54,
          style: BorderStyle.solid,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Center(
        child: Text(
          'Your receipt image will appear here.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // White background for the buttons
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextInputType keyboardType,
  }) {
    return TextField(
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900], // Darker fill color for input fields
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none, // Hide default border
        ),
      ),
    );
  }

  Widget _buildDateTextField(BuildContext context) {
    return TextField(
      readOnly: true, // Prevents keyboard from appearing
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'mm/dd/yyyy',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white54, size: 20),
          onPressed: () async {
            // Implement Date Picker logic
            await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    // Simple placeholder for the DropdownButton
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        hint: const Text('Select a category', style: TextStyle(color: Colors.grey)),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        dropdownColor: Colors.grey[900],
        items: <String>['Groceries', 'Food', 'Gas', 'Entertainment']
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          // Handle category selection
          debugPrint('Selected category: $newValue');
        },
      ),
    );
  }

  Widget _buildBottomNavBar(int currentIndex) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white, // Selected icon is white
      unselectedItemColor: Colors.grey, // Unselected icons are grey
      type: BottomNavigationBarType.fixed, // Ensure icons are visible on dark background
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: 'Stores'),
        // The selected item is bolded in the image, use a slightly thicker icon
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan Receipt'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      onTap: (index) {
        // Handle navigation changes
      },
    );
  }
}