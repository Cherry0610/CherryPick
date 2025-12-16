import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class GestureCustomizationScreen extends StatefulWidget {
  const GestureCustomizationScreen({super.key});

  @override
  State<GestureCustomizationScreen> createState() =>
      _GestureCustomizationScreenState();
}

class _GestureCustomizationScreenState
    extends State<GestureCustomizationScreen> {
  final Map<String, String> _gestureMappings = {
    'Tap': 'Click',
    'Double Tap': 'Home',
    'Long Press': 'Back',
    'Swipe Up': 'Recent Apps',
    'Swipe Down': 'Notifications',
    'Swipe Left': 'Previous App',
    'Swipe Right': 'Next App',
  };

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
          'Gesture Customization',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Map gestures to cursor actions. Tap any gesture to change its action.',
              style: TextStyle(color: kMediumGray, fontSize: 15, height: 1.5),
            ),
          ),
          ..._gestureMappings.entries.map(
            (entry) => _buildGestureCard(
              gesture: entry.key,
              action: entry.value,
              onTap: () => _showActionPicker(entry.key),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureCard({
    required String gesture,
    required String action,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kLightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getGestureIcon(gesture), color: kBlack, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gesture,
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action,
                      style: const TextStyle(color: kMediumGray, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kMediumGray),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGestureIcon(String gesture) {
    switch (gesture) {
      case 'Tap':
        return Icons.touch_app;
      case 'Double Tap':
        return Icons.touch_app;
      case 'Long Press':
        return Icons.touch_app;
      case 'Swipe Up':
        return Icons.arrow_upward;
      case 'Swipe Down':
        return Icons.arrow_downward;
      case 'Swipe Left':
        return Icons.arrow_back;
      case 'Swipe Right':
        return Icons.arrow_forward;
      default:
        return Icons.gesture;
    }
  }

  void _showActionPicker(String gesture) {
    final actions = [
      'Click',
      'Double Click',
      'Right Click',
      'Home',
      'Back',
      'Recent Apps',
      'Notifications',
      'Previous App',
      'Next App',
      'None',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Action for $gesture',
              style: const TextStyle(
                color: kBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...actions.map(
              (action) => ListTile(
                title: Text(action, style: const TextStyle(color: kBlack)),
                onTap: () {
                  setState(() {
                    _gestureMappings[gesture] = action;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
