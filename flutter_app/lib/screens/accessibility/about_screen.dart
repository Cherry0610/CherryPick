import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: <Widget>[
          // App Icon and Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: kBlack,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.touch_app, size: 60, color: kWhite),
                ),
                const SizedBox(height: 24),
                const Text(
                  'One-Handed Cursor',
                  style: TextStyle(
                    color: kBlack,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: kMediumGray, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Description
          const Text(
            'An accessibility-focused app that enables one-handed cursor control on your device. Perfect for users who need an alternative way to interact with their device.',
            style: TextStyle(color: kBlack, fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Links
          _buildLinkTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          _buildLinkTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              // TODO: Open terms of service
            },
          ),
          _buildLinkTile(
            icon: Icons.bug_report_outlined,
            title: 'Report a Bug',
            onTap: () {
              // TODO: Open bug report
            },
          ),
          _buildLinkTile(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            onTap: () {
              // TODO: Open feedback form
            },
          ),
          const SizedBox(height: 32),

          // Credits
          const Divider(color: kLightGray),
          const SizedBox(height: 16),
          const Text(
            'Credits',
            style: TextStyle(
              color: kBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Developed with ❤️ for accessibility',
            style: TextStyle(color: kMediumGray, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '© 2025 CherryPick. All rights reserved.',
            style: TextStyle(color: kMediumGray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kLightGray, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: kBlack, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: kBlack,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: kMediumGray,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
