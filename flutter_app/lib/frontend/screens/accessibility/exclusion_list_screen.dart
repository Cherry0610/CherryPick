import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class ExclusionListScreen extends StatefulWidget {
  const ExclusionListScreen({super.key});

  @override
  State<ExclusionListScreen> createState() => _ExclusionListScreenState();
}

class _ExclusionListScreenState extends State<ExclusionListScreen> {
  final List<AppItem> _allApps = [
    AppItem(name: 'Games', icon: Icons.games, package: 'com.games'),
    AppItem(
      name: 'Banking App',
      icon: Icons.account_balance,
      package: 'com.bank',
    ),
    AppItem(name: 'Camera', icon: Icons.camera, package: 'com.camera'),
    AppItem(name: 'Gallery', icon: Icons.photo_library, package: 'com.gallery'),
    AppItem(
      name: 'Video Player',
      icon: Icons.play_circle,
      package: 'com.video',
    ),
  ];

  final Set<String> _excludedApps = {};

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
          'Exclusion List',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: kLightGray,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: kBlack, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select apps where the cursor overlay should be disabled',
                    style: TextStyle(color: kBlack, fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: const Icon(Icons.search, color: kMediumGray),
                filled: true,
                fillColor: kLightGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(color: kBlack),
            ),
          ),

          // App List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allApps.length,
              itemBuilder: (context, index) {
                final app = _allApps[index];
                final isExcluded = _excludedApps.contains(app.package);
                return Card(
                  color: kWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: kLightGray, width: 1),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: SwitchListTile(
                    value: isExcluded,
                    onChanged: (value) {
                      setState(() {
                        if (value) {
                          _excludedApps.add(app.package);
                        } else {
                          _excludedApps.remove(app.package);
                        }
                      });
                    },
                    title: Text(
                      app.name,
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      isExcluded
                          ? 'Cursor disabled in this app'
                          : 'Cursor enabled in this app',
                      style: TextStyle(
                        color: isExcluded ? kMediumGray : kBlack,
                        fontSize: 12,
                      ),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kLightGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(app.icon, color: kBlack, size: 24),
                    ),
                    activeThumbColor: kBlack,
                  ),
                );
              },
            ),
          ),

          // Summary
          if (_excludedApps.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: kLightGray,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: kBlack, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_excludedApps.length} app(s) excluded',
                    style: const TextStyle(
                      color: kBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AppItem {
  final String name;
  final IconData icon;
  final String package;

  AppItem({required this.name, required this.icon, required this.package});
}


