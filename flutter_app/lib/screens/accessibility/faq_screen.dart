import 'package:flutter/material.dart';
import 'accessibility_theme.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<FaqItem> _faqs = [
    FaqItem(
      question: 'Cursor disappears',
      answer:
          'Make sure the Accessibility Service is enabled in Settings. Go to Settings > Accessibility > Installed Services and ensure our app is toggled ON.',
    ),
    FaqItem(
      question: 'Gestures don\'t work',
      answer:
          'Check that both Accessibility and Draw Over Other Apps permissions are granted. You can verify this in the app\'s Permission Check screen.',
    ),
    FaqItem(
      question: 'Cursor is too sensitive',
      answer:
          'Go to Settings > Sensitivity Settings and adjust the Movement Speed and Acceleration sliders to your preference.',
    ),
    FaqItem(
      question: 'How do I disable cursor in specific apps?',
      answer:
          'Navigate to Settings > Exclusion List and toggle ON the apps where you want the cursor disabled.',
    ),
    FaqItem(
      question: 'App crashes on startup',
      answer:
          'Try clearing the app data and cache, then restart. If the issue persists, ensure your device meets the minimum requirements.',
    ),
    FaqItem(
      question: 'Can I change cursor color?',
      answer:
          'Yes! Go to Settings > Visual Settings > Cursor Color and select from available color options.',
    ),
    FaqItem(
      question: 'How do I reset all settings?',
      answer:
          'Currently, you need to reset each setting category individually. We\'re working on adding a global reset option in a future update.',
    ),
    FaqItem(
      question: 'Does this work with all apps?',
      answer:
          'The cursor works with most apps. Some apps (like games or banking apps) may need to be added to the Exclusion List for security reasons.',
    ),
  ];

  int? _expandedIndex;

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
          'Frequently Asked Questions',
          style: TextStyle(color: kBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Find answers to common questions and troubleshooting tips.',
              style: TextStyle(color: kMediumGray, fontSize: 15, height: 1.5),
            ),
          ),
          ...List.generate(
            _faqs.length,
            (index) => _buildFaqCard(_faqs[index], index),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(FaqItem faq, int index) {
    final isExpanded = _expandedIndex == index;
    return Card(
      color: kWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kLightGray, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kLightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.help_outline, color: kBlack, size: 20),
        ),
        title: Text(
          faq.question,
          style: const TextStyle(
            color: kBlack,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: kBlack,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedIndex = expanded ? index : null;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              faq.answer,
              style: const TextStyle(
                color: kMediumGray,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}
