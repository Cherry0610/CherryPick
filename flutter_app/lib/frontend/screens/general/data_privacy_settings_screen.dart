import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBackground = Color(0xFFF9FAFB);

class DataPrivacySettingsScreen extends StatefulWidget {
  const DataPrivacySettingsScreen({super.key});

  @override
  State<DataPrivacySettingsScreen> createState() => _DataPrivacySettingsScreenState();
}

class _DataPrivacySettingsScreenState extends State<DataPrivacySettingsScreen> {
  bool _analyticsEnabled = true;
  bool _personalizedAds = false;
  bool _dataSharing = false;
  bool _locationTracking = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _personalizedAds = prefs.getBool('personalized_ads') ?? false;
      _dataSharing = prefs.getBool('data_sharing') ?? false;
      _locationTracking = prefs.getBool('location_tracking') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

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
          'Data Privacy Settings',
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
            _buildSettingItem(
              'Analytics & Usage Data',
              'Help us improve the app by sharing anonymous usage data',
              _analyticsEnabled,
              (value) {
                setState(() => _analyticsEnabled = value);
                _saveSetting('analytics_enabled', value);
              },
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              'Personalized Ads',
              'Show ads based on your interests and activity',
              _personalizedAds,
              (value) {
                setState(() => _personalizedAds = value);
                _saveSetting('personalized_ads', value);
              },
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              'Data Sharing',
              'Share data with third-party partners for better services',
              _dataSharing,
              (value) {
                setState(() => _dataSharing = value);
                _saveSetting('data_sharing', value);
              },
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              'Location Tracking',
              'Allow app to access your location for nearby stores',
              _locationTracking,
              (value) {
                setState(() => _locationTracking = value);
                _saveSetting('location_tracking', value);
              },
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
                    'Your Privacy Rights',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have the right to access, modify, or delete your personal data at any time. Contact us at privacy@smartprice.com for assistance.',
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

  Widget _buildSettingItem(String title, String description, bool value, ValueChanged<bool> onChanged) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}



