import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class VisualSettingsScreen extends StatefulWidget {
  const VisualSettingsScreen({super.key});

  @override
  State<VisualSettingsScreen> createState() => _VisualSettingsScreenState();
}

class _VisualSettingsScreenState extends State<VisualSettingsScreen> {
  double _cursorSize = 20.0;
  Color _cursorColor = kBlack;
  double _touchpadOpacity = 0.3;
  String _touchpadPosition = 'bottom';

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
          'Visual Settings',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Cursor Size
          _buildSection('Cursor Size', [
            Row(
              children: [
                const Icon(Icons.remove, color: kBlack),
                Expanded(
                  child: Slider(
                    value: _cursorSize,
                    min: 10,
                    max: 50,
                    divisions: 40,
                    label: '${_cursorSize.round()}px',
                    onChanged: (value) {
                      setState(() {
                        _cursorSize = value;
                      });
                    },
                    activeColor: kBlack,
                    inactiveColor: kMediumGray,
                  ),
                ),
                const Icon(Icons.add, color: kBlack),
              ],
            ),
            Text(
              '${_cursorSize.round()} pixels',
              style: const TextStyle(color: kMediumGray, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ]),

          // Cursor Color
          _buildSection('Cursor Color', [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildColorOption(kBlack, 'Black'),
                _buildColorOption(kWhite, 'White'),
                _buildColorOption(const Color(0xFF808080), 'Gray'),
                _buildColorOption(const Color(0xFFFF0000), 'Red'),
                _buildColorOption(const Color(0xFF0000FF), 'Blue'),
                _buildColorOption(const Color(0xFF00FF00), 'Green'),
              ],
            ),
          ]),

          // Touchpad Opacity
          _buildSection('Touchpad Opacity', [
            Row(
              children: [
                const Icon(Icons.opacity, color: kBlack),
                Expanded(
                  child: Slider(
                    value: _touchpadOpacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(_touchpadOpacity * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _touchpadOpacity = value;
                      });
                    },
                    activeColor: kBlack,
                    inactiveColor: kMediumGray,
                  ),
                ),
              ],
            ),
            Text(
              '${(_touchpadOpacity * 100).round()}%',
              style: const TextStyle(color: kMediumGray, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ]),

          // Touchpad Position
          _buildSection('Touchpad Position', [
            Row(
              children: [
                Expanded(child: _buildPositionOption('top', 'Top')),
                const SizedBox(width: 12),
                Expanded(child: _buildPositionOption('bottom', 'Bottom')),
                const SizedBox(width: 12),
                Expanded(child: _buildPositionOption('left', 'Left')),
                const SizedBox(width: 12),
                Expanded(child: _buildPositionOption('right', 'Right')),
              ],
            ),
          ]),

          // Preview
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kLightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kMediumGray, width: 1),
            ),
            child: Column(
              children: [
                const Text(
                  'Preview',
                  style: TextStyle(
                    color: kBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kBlack, width: 1),
                  ),
                  child: Stack(
                    children: [
                      // Touchpad preview
                      Positioned(
                        bottom: _touchpadPosition == 'bottom' ? 0 : null,
                        top: _touchpadPosition == 'top' ? 0 : null,
                        left: _touchpadPosition == 'left' ? 0 : null,
                        right: _touchpadPosition == 'right' ? 0 : null,
                        child: Container(
                          width:
                              _touchpadPosition == 'left' ||
                                  _touchpadPosition == 'right'
                              ? 60
                              : double.infinity,
                          height:
                              _touchpadPosition == 'top' ||
                                  _touchpadPosition == 'bottom'
                              ? 60
                              : double.infinity,
                          color: kBlack.withValues(alpha: _touchpadOpacity),
                        ),
                      ),
                      // Cursor preview
                      Center(
                        child: Container(
                          width: _cursorSize,
                          height: _cursorSize,
                          decoration: BoxDecoration(
                            color: _cursorColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _cursorColor == kWhite ? kBlack : kWhite,
                              width: 1,
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
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kLightGray, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, String label) {
    final isSelected = _cursorColor == color;
    return InkWell(
      onTap: () {
        setState(() {
          _cursorColor = color;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? kBlack : kMediumGray,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: kWhite, size: 24)
            : null,
      ),
    );
  }

  Widget _buildPositionOption(String position, String label) {
    final isSelected = _touchpadPosition == position;
    return InkWell(
      onTap: () {
        setState(() {
          _touchpadPosition = position;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kBlack : kWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? kBlack : kMediumGray,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? kWhite : kBlack,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


