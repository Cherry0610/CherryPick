import 'package:flutter/material.dart';

const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBackground = Color(0xFFF9FAFB);

class ThirdPartyLicensesScreen extends StatelessWidget {
  const ThirdPartyLicensesScreen({super.key});

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
          'Third Party Licenses',
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
            _buildLicenseItem(
              'Flutter',
              'BSD 3-Clause License',
              'Copyright (c) 2014, the Flutter project authors',
            ),
            const SizedBox(height: 12),
            _buildLicenseItem(
              'Firebase',
              'Apache License 2.0',
              'Copyright (c) Google LLC',
            ),
            const SizedBox(height: 12),
            _buildLicenseItem(
              'HTTP',
              'BSD 3-Clause License',
              'Copyright (c) the Dart project authors',
            ),
            const SizedBox(height: 12),
            _buildLicenseItem(
              'HTML Parser',
              'MIT License',
              'Copyright (c) Dart Team',
            ),
            const SizedBox(height: 12),
            _buildLicenseItem(
              'FL Chart',
              'Apache License 2.0',
              'Copyright (c) FL Chart contributors',
            ),
            const SizedBox(height: 12),
            _buildLicenseItem(
              'URL Launcher',
              'BSD 3-Clause License',
              'Copyright (c) the Dart project authors',
            ),
            const SizedBox(height: 12),
            _buildLicenseItem(
              'Shared Preferences',
              'MIT License',
              'Copyright (c) Flutter Team',
            ),
            const SizedBox(height: 24),
            Container(
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
                  const Text(
                    'Open Source Notice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SmartPrice uses open source software. Full license texts are available in the app package or can be requested at licenses@smartprice.com.',
                    style: TextStyle(
                      fontSize: 14,
                      color: kTextLight,
                      height: 1.5,
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

  Widget _buildLicenseItem(String name, String license, String copyright) {
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
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            license,
            style: const TextStyle(
              fontSize: 14,
              color: kTextLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            copyright,
            style: TextStyle(
              fontSize: 12,
              color: kTextLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}


