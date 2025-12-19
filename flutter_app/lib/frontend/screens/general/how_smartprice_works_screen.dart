import 'package:flutter/material.dart';

const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBackground = Color(0xFFF9FAFB);
const Color kPrimaryRed = Color(0xFFE85D5D);

class HowSmartPriceWorksScreen extends StatelessWidget {
  const HowSmartPriceWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kCardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'How SmartPrice Works',
          style: TextStyle(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStep(
              '1',
              'Search Products',
              'Search for any grocery product across all Malaysian online stores.',
              Icons.search,
            ),
            const SizedBox(height: 16),
            _buildStep(
              '2',
              'Compare Prices',
              'View prices from multiple stores side by side to find the best deal.',
              Icons.compare_arrows,
            ),
            const SizedBox(height: 16),
            _buildStep(
              '3',
              'Set Price Alerts',
              'Add products to your wishlist and get notified when prices drop.',
              Icons.notifications_active,
            ),
            const SizedBox(height: 16),
            _buildStep(
              '4',
              'Track Expenses',
              'Scan receipts or manually add expenses to track your grocery spending.',
              Icons.receipt_long,
            ),
            const SizedBox(height: 16),
            _buildStep(
              '5',
              'Find Nearby Stores',
              'Locate physical stores near you with directions and store information.',
              Icons.location_on,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 48, color: kPrimaryRed),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart Savings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save time and money by comparing prices across all major Malaysian grocery stores in one place.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: kTextLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPrimaryRed,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: kPrimaryRed, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTextDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: kTextLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


