import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class PermissionCheckScreen extends StatefulWidget {
  const PermissionCheckScreen({super.key});

  @override
  State<PermissionCheckScreen> createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {
  bool _accessibilityGranted = false;
  bool _drawOverGranted = false;

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
          'Permissions Required',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 16),

              // Critical Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kLightGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBlack, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: kBlack,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Why We Need These Permissions',
                          style: TextStyle(
                            color: kBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Accessibility Service: Allows the app to detect gestures and control the cursor on your screen.',
                      style: TextStyle(
                        color: kBlack,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Draw Over Other Apps: Enables the cursor overlay to appear on top of other applications.',
                      style: TextStyle(
                        color: kBlack,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Accessibility Permission
              _buildPermissionCard(
                title: 'Accessibility Service',
                description:
                    'Required for gesture detection and cursor control',
                granted: _accessibilityGranted,
                onTap: () async {
                  // TODO: Request accessibility permission
                  setState(() {
                    _accessibilityGranted = true;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Draw Over Permission
              _buildPermissionCard(
                title: 'Draw Over Other Apps',
                description: 'Required for cursor overlay display',
                granted: _drawOverGranted,
                onTap: () async {
                  // TODO: Request draw over permission
                  setState(() {
                    _drawOverGranted = true;
                  });
                },
              ),
              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_accessibilityGranted && _drawOverGranted)
                      ? () {
                          Navigator.pushNamed(context, '/accessibility-guide');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlack,
                    foregroundColor: kWhite,
                    disabledBackgroundColor: kMediumGray,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: granted ? kLightGray : kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: granted ? kBlack : kMediumGray, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              granted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: granted ? kBlack : kMediumGray,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: granted ? kBlack : kMediumGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: kMediumGray, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: granted ? kBlack : kMediumGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
