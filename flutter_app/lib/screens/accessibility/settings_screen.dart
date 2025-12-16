import 'package:flutter/material.dart';
import 'accessibility_theme.dart';
import 'gesture_customization_screen.dart';
import 'visual_settings_screen.dart';
import 'sensitivity_settings_screen.dart';
import 'exclusion_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildSectionHeader('Core Settings'),
          _buildSettingsTile(
            context,
            icon: Icons.gesture,
            title: 'Gesture Customization',
            subtitle: 'Map cursor actions to gestures',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GestureCustomizationScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.palette,
            title: 'Visual Settings',
            subtitle: 'Customize cursor and touchpad appearance',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VisualSettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.tune,
            title: 'Sensitivity Settings',
            subtitle: 'Fine-tune responsiveness',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SensitivitySettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.block,
            title: 'Exclusion List',
            subtitle: 'Apps where cursor is disabled',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExclusionListScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Support'),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Tutorial',
            subtitle: 'Learn how to use all features',
            onTap: () {
              Navigator.pushNamed(context, '/help-tutorial');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.question_answer,
            title: 'FAQ',
            subtitle: 'Common questions and answers',
            onTap: () {
              Navigator.pushNamed(context, '/faq');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.star_outline,
            title: 'Premium Features',
            subtitle: 'Unlock advanced customization',
            onTap: () {
              Navigator.pushNamed(context, '/premium');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: kMediumGray,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kLightGray, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kLightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kBlack, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: kBlack,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: kMediumGray, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: kMediumGray),
        onTap: onTap,
      ),
    );
  }
}
