import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class SensitivitySettingsScreen extends StatefulWidget {
  const SensitivitySettingsScreen({super.key});

  @override
  State<SensitivitySettingsScreen> createState() =>
      _SensitivitySettingsScreenState();
}

class _SensitivitySettingsScreenState extends State<SensitivitySettingsScreen> {
  double _movementSpeed = 0.5;
  double _acceleration = 0.5;
  double _deadZone = 0.1;

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
          'Sensitivity Settings',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Fine-tune the responsiveness of the cursor tracker pad.',
              style: TextStyle(color: kMediumGray, fontSize: 15, height: 1.5),
            ),
          ),

          // Movement Speed
          _buildSliderCard(
            title: 'Movement Speed',
            value: _movementSpeed,
            min: 0.1,
            max: 1.0,
            icon: Icons.speed,
            description: 'How fast the cursor moves',
            onChanged: (value) {
              setState(() {
                _movementSpeed = value;
              });
            },
          ),

          // Acceleration
          _buildSliderCard(
            title: 'Acceleration',
            value: _acceleration,
            min: 0.0,
            max: 1.0,
            icon: Icons.trending_up,
            description: 'Cursor acceleration on quick movements',
            onChanged: (value) {
              setState(() {
                _acceleration = value;
              });
            },
          ),

          // Dead Zone
          _buildSliderCard(
            title: 'Dead Zone',
            value: _deadZone,
            min: 0.0,
            max: 0.5,
            icon: Icons.center_focus_strong,
            description: 'Area where small movements are ignored',
            onChanged: (value) {
              setState(() {
                _deadZone = value;
              });
            },
          ),

          // Reset Button
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _movementSpeed = 0.5;
                _acceleration = 0.5;
                _deadZone = 0.1;
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kBlack, width: 2),
              foregroundColor: kBlack,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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

  Widget _buildSliderCard({
    required String title,
    required double value,
    required double min,
    required double max,
    required IconData icon,
    required String description,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kLightGray, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kBlack, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: kBlack,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: kMediumGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kLightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      color: kBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: 100,
              onChanged: onChanged,
              activeColor: kBlack,
              inactiveColor: kMediumGray,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low', style: TextStyle(color: kMediumGray, fontSize: 12)),
                Text(
                  'High',
                  style: TextStyle(color: kMediumGray, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


