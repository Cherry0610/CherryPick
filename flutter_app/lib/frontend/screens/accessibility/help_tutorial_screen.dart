import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class HelpTutorialScreen extends StatefulWidget {
  const HelpTutorialScreen({super.key});

  @override
  State<HelpTutorialScreen> createState() => _HelpTutorialScreenState();
}

class _HelpTutorialScreenState extends State<HelpTutorialScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<TutorialItem> _tutorials = [
    TutorialItem(
      title: 'Getting Started',
      category: 'Basics',
      icon: Icons.play_circle_outline,
      content: 'Learn how to enable and configure the cursor control feature.',
    ),
    TutorialItem(
      title: 'Gesture Controls',
      category: 'Gestures',
      icon: Icons.gesture,
      content:
          'Master all available gestures: tap, double tap, long press, and swipes.',
    ),
    TutorialItem(
      title: 'Customization',
      category: 'Settings',
      icon: Icons.tune,
      content:
          'Customize cursor appearance, sensitivity, and gesture mappings.',
    ),
    TutorialItem(
      title: 'Exclusion List',
      category: 'Settings',
      icon: Icons.block,
      content: 'Configure apps where the cursor should be disabled.',
    ),
    TutorialItem(
      title: 'Troubleshooting',
      category: 'Support',
      icon: Icons.build,
      content: 'Common issues and how to resolve them.',
    ),
    TutorialItem(
      title: 'Advanced Tips',
      category: 'Advanced',
      icon: Icons.lightbulb_outline,
      content: 'Pro tips for power users and advanced customization.',
    ),
  ];

  List<TutorialItem> get _filteredTutorials {
    if (_searchQuery.isEmpty) return _tutorials;
    return _tutorials
        .where(
          (tutorial) =>
              tutorial.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              tutorial.category.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              tutorial.content.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

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
          'Help & Tutorial',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search features and tips...',
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Tutorial List
          Expanded(
            child: _filteredTutorials.isEmpty
                ? const Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(color: kMediumGray, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredTutorials.length,
                    itemBuilder: (context, index) {
                      final tutorial = _filteredTutorials[index];
                      return _buildTutorialCard(tutorial);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard(TutorialItem tutorial) {
    return Card(
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kLightGray, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showTutorialDetail(tutorial);
        },
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
                child: Icon(tutorial.icon, color: kBlack, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kBlack,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tutorial.category,
                            style: const TextStyle(
                              color: kWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tutorial.title,
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tutorial.content,
                      style: const TextStyle(color: kMediumGray, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  void _showTutorialDetail(TutorialItem tutorial) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(tutorial.icon, color: kBlack, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutorial.title,
                            style: const TextStyle(
                              color: kBlack,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tutorial.category,
                            style: const TextStyle(
                              color: kMediumGray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  tutorial.content,
                  style: const TextStyle(
                    color: kBlack,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Detailed instructions and step-by-step guide would go here...',
                  style: TextStyle(
                    color: kMediumGray,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TutorialItem {
  final String title;
  final String category;
  final IconData icon;
  final String content;

  TutorialItem({
    required this.title,
    required this.category,
    required this.icon,
    required this.content,
  });
}


