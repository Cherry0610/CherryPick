import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class AccessibilityGuideScreen extends StatefulWidget {
  const AccessibilityGuideScreen({super.key});

  @override
  State<AccessibilityGuideScreen> createState() =>
      _AccessibilityGuideScreenState();
}

class _AccessibilityGuideScreenState extends State<AccessibilityGuideScreen> {
  int _currentStep = 0;

  final List<GuideStep> _steps = [
    GuideStep(
      title: 'Open Settings',
      description: 'Go to your device Settings app',
      icon: Icons.settings,
    ),
    GuideStep(
      title: 'Find Accessibility',
      description: 'Scroll down and tap on "Accessibility"',
      icon: Icons.accessibility_new,
    ),
    GuideStep(
      title: 'Select Installed Services',
      description: 'Tap on "Installed Services" or "Downloaded Apps"',
      icon: Icons.apps,
    ),
    GuideStep(
      title: 'Enable Our App',
      description: 'Find our app and toggle it ON',
      icon: Icons.toggle_on,
    ),
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
          'Enable Accessibility Service',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: PageController(initialPage: _currentStep),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _buildStepPage(_steps[index], index);
                },
              ),
            ),

            // Step Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => _buildDot(index == _currentStep),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
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
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep < _steps.length - 1) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          Navigator.pushNamed(context, '/initial-setup');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlack,
                        foregroundColor: kWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _currentStep < _steps.length - 1 ? 'Next' : 'Continue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildStepPage(GuideStep step, int index) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Step Number
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: kBlack, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: kWhite,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Icon
          Icon(step.icon, size: 120, color: kBlack),
          const SizedBox(height: 32),

          // Title
          Text(
            step.title,
            style: const TextStyle(
              color: kBlack,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            style: const TextStyle(
              color: kMediumGray,
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Placeholder for GIF/Image
          const SizedBox(height: 48),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: kLightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kMediumGray, width: 1),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 60, color: kMediumGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? kBlack : kMediumGray,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class GuideStep {
  final String title;
  final String description;
  final IconData icon;

  GuideStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
