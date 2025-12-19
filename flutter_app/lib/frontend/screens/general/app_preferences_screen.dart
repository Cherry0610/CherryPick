import 'package:flutter/material.dart';

// Modern Black & White Theme
const Color kBlack = Color(0xFF000000);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkGray = Color(0xFF1A1A1A);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kMediumGray = Color(0xFF808080);

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  String _selectedCurrency = 'MYR (RM)';
  String _defaultStore = 'NSK Grocer';
  bool _notificationsEnabled = true;
  bool _priceAlertsEnabled = true;
  bool _locationServicesEnabled = true;

  final List<String> _currencies = [
    'MYR (RM)',
    'USD (US\$)',
    'SGD (S\$)',
    'THB (฿)',
  ];

  final List<String> _stores = [
    'NSK Grocer',
    'Tesco',
    'Giant',
    'AEON',
    'Jaya Grocer',
    'Village Grocer',
  ];

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
          'App Preferences',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Currency Preference
          _buildSection('Currency', Icons.attach_money, [
            _buildDropdownSetting(
              'Preferred Currency',
              _selectedCurrency,
              _currencies,
              (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
          ]),
          const SizedBox(height: 24),

          // Store Preference
          _buildSection('Default Store', Icons.store, [
            _buildDropdownSetting(
              'Default Grocery Store',
              _defaultStore,
              _stores,
              (value) {
                setState(() {
                  _defaultStore = value!;
                });
              },
            ),
          ]),
          const SizedBox(height: 24),

          // Notifications
          _buildSection('Notifications', Icons.notifications, [
            _buildSwitchSetting('Enable Notifications', _notificationsEnabled, (
              value,
            ) {
              setState(() {
                _notificationsEnabled = value;
              });
            }),
            _buildSwitchSetting('Price Drop Alerts', _priceAlertsEnabled, (
              value,
            ) {
              setState(() {
                _priceAlertsEnabled = value;
              });
            }),
          ]),
          const SizedBox(height: 24),

          // Location Services
          _buildSection('Location', Icons.location_on, [
            _buildSwitchSetting('Location Services', _locationServicesEnabled, (
              value,
            ) {
              setState(() {
                _locationServicesEnabled = value;
              });
            }),
          ]),
          const SizedBox(height: 24),

          // Reset Button
          OutlinedButton(
            onPressed: _resetPreferences,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kBlack, width: 2),
              foregroundColor: kBlack,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reset to Defaults',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kBlack, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: kBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildDropdownSetting(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Card(
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kMediumGray.withValues(alpha: 0.2)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: kBlack,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            DropdownButton<String>(
              value: value,
              underline: Container(),
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option, style: const TextStyle(color: kBlack)),
                );
              }).toList(),
              onChanged: onChanged,
              style: const TextStyle(
                color: kBlack,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kMediumGray.withValues(alpha: 0.2)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(
          label,
          style: const TextStyle(
            color: kBlack,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: kBlack,
      ),
    );
  }

  void _resetPreferences() {
    setState(() {
      _selectedCurrency = 'MYR (RM)';
      _defaultStore = 'NSK Grocer';
      _notificationsEnabled = true;
      _priceAlertsEnabled = true;
      _locationServicesEnabled = true;
    });
  }
}


