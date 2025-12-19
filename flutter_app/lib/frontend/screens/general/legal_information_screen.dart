import 'package:flutter/material.dart';

const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBackground = Color(0xFFF9FAFB);

class LegalInformationScreen extends StatelessWidget {
  const LegalInformationScreen({super.key});

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
          'Legal Information',
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
            _buildSection(
              'Terms of Service',
              'By using SmartPrice, you agree to our Terms of Service. These terms govern your use of our app and services.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'User Agreement',
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Intellectual Property',
              'All content, features, and functionality of SmartPrice are owned by us and are protected by international copyright, trademark, and other intellectual property laws.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Limitation of Liability',
              'SmartPrice is provided "as is" without warranties of any kind. We are not liable for any damages arising from your use of the app.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Governing Law',
              'These terms are governed by the laws of Malaysia. Any disputes will be resolved in the courts of Malaysia.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Contact',
              'For legal inquiries, please contact us at legal@smartprice.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: kTextLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}


