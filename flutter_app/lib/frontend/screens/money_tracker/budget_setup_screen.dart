import 'package:flutter/material.dart';

// --- Reusing AuthColors for Consistency ---
// NOTE: Ideally, move this to a central file (e.g., constants/colors.dart)
class AppColors {
  static const Color background = Colors.black;
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.white70;
  static const Color inputFill = Colors.white;
  static Color inputHint = Colors.grey.shade600;
  static const Color accentColor = Color(0xFF6DE4E0); // Teal accent from your home screen
}

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _incomeController = TextEditingController();
  final Map<String, TextEditingController> _categoryControllers = {
    'Rent/Mortgage': TextEditingController(),
    'Groceries': TextEditingController(),
    'Transportation': TextEditingController(),
    'Savings': TextEditingController(),
  };

  bool _isLoading = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _categoryControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Helper function for consistent field styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String hintText = '0.00',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.black), // Black text on white input
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primaryText),
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.inputHint, fontSize: 16),
          filled: true,
          fillColor: AppColors.inputFill,
          prefixText: 'RM ', // Malaysian Ringgit prefix
          prefixStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Slightly rounded corners
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        ),
        validator: (value) {
          if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
            return 'Please enter a valid amount.';
          }
          return null;
        },
      ),
    );
  }

  // Handles form submission (saving the budget)
  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // 1. Calculate Total Budgeted Amount
      double totalBudgeted = _categoryControllers.values
          .map((c) => double.tryParse(c.text) ?? 0.0)
          .fold(0.0, (sum, amount) => sum + amount);

      double totalIncome = double.tryParse(_incomeController.text) ?? 0.0;

      // 2. Display Result/Warning
      if (totalBudgeted > totalIncome) {
        // Warning: Budget exceeds income
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Warning: Your total budgeted amount (RM ${totalBudgeted.toStringAsFixed(2)}) exceeds your income.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // 3. Prepare Data Structure (for API call)
      final Map<String, dynamic> budgetData = {
        'totalIncome': totalIncome,
        'categories': _categoryControllers.map((key, controller) => MapEntry(
            key.toLowerCase().replaceAll('/', '_'),
            double.tryParse(controller.text) ?? 0.0
        )),
      };

      debugPrint('Budget Data to Save: $budgetData');

      // 4. API Call Placeholder (replace with actual service call)
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget setup saved successfully!'),
            backgroundColor: AppColors.accentColor,
            duration: Duration(seconds: 3),
          ),
        );
        // Navigate to the main app area (e.g., HomeScreen or Budget Dashboard)
        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BudgetDashboard()));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Budget Setup',
          style: TextStyle(color: AppColors.primaryText),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Monthly Income',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set your total monthly income to begin tracking.',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // --- Total Income Input ---
                _buildTextField(controller: _incomeController, label: 'Total Monthly Income'),

                const SizedBox(height: 30),

                // --- Budget Categories Title ---
                const Text(
                  'Allocate Budget Categories',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Category Inputs ---
                ..._categoryControllers.keys.map((category) {
                  return _buildTextField(
                    controller: _categoryControllers[category]!,
                    label: category,
                  );
                }),

                const SizedBox(height: 40),

                // --- Save Button (Primary CTA) ---
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryText))
                      : ElevatedButton(
                    onPressed: _saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor, // Teal background
                      foregroundColor: Colors.black, // Black text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Save Budget',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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