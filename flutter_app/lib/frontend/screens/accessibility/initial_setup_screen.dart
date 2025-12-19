import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  String _selectedSide = 'right'; // 'left' or 'right'
  double _verticalPosition = 0.5; // 0.0 to 1.0 (top to bottom)

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
          'Configure Trigger Zone',
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

              // Instructions
              const Text(
                'Choose where you want the trigger zone for cursor control:',
                style: TextStyle(
                  color: kBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // Side Selection
              const Text(
                'Side',
                style: TextStyle(
                  color: kBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSideOption('left', 'Left Side')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSideOption('right', 'Right Side')),
                ],
              ),
              const SizedBox(height: 32),

              // Vertical Position
              const Text(
                'Vertical Position',
                style: TextStyle(
                  color: kBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.arrow_upward, color: kBlack),
                  Expanded(
                    child: Slider(
                      value: _verticalPosition,
                      onChanged: (value) {
                        setState(() {
                          _verticalPosition = value;
                        });
                      },
                      activeColor: kBlack,
                      inactiveColor: kMediumGray,
                    ),
                  ),
                  const Icon(Icons.arrow_downward, color: kBlack),
                ],
              ),
              Text(
                _verticalPosition < 0.33
                    ? 'Top Third'
                    : _verticalPosition < 0.67
                    ? 'Middle Third'
                    : 'Bottom Third',
                style: const TextStyle(color: kMediumGray, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Preview
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: kLightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kMediumGray, width: 1),
                  ),
                  child: Stack(
                    children: [
                      // Preview Zone Indicator
                      Positioned(
                        left: _selectedSide == 'left' ? 0 : null,
                        right: _selectedSide == 'right' ? 0 : null,
                        top:
                            MediaQuery.of(context).size.height *
                            0.2 *
                            _verticalPosition,
                        child: Container(
                          width: 60,
                          height: 200,
                          decoration: BoxDecoration(
                            color: kBlack.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kBlack, width: 2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.touch_app,
                              color: kBlack,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      // Instructions overlay
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 120,
                              color: kMediumGray,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Preview: Trigger zone on $_selectedSide side',
                              style: const TextStyle(
                                color: kMediumGray,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Complete Setup Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Save configuration
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/settings',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlack,
                    foregroundColor: kWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Complete Setup',
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

  Widget _buildSideOption(String side, String label) {
    final isSelected = _selectedSide == side;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSide = side;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? kBlack : kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kBlack : kMediumGray,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              side == 'left' ? Icons.arrow_back : Icons.arrow_forward,
              color: isSelected ? kWhite : kBlack,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? kWhite : kBlack,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


