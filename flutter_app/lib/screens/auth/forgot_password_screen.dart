import 'package:flutter/material.dart';

// Define the black and white theme colors
const Color kPrimaryColor = Color(0xFF1A1A1A); // Black
const Color kBackgroundColor = Color(0xFFFFFFFF); // White
const Color kHintTextColor = Color(0xFF666666); // Dark Gray

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordScreen({super.key});

  // Function to handle the form submission (simulated for now)
  void _submitRequest(BuildContext context) {
    String emailOrId = _emailController.text.trim();
    if (emailOrId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your User ID or Email.')),
      );
      return;
    }

    // --- REAL APPLICATION LOGIC GOES HERE ---
    // 1. Call your API to send the reset link/OTP.
    // 2. Handle the response (success/failure).
    // 3. Navigate to the next screen (OTP Entry or Confirmation).

    // Simulation:
    debugPrint('Sending reset request for: $emailOrId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'If an account exists, a link has been sent to $emailOrId',
        ),
      ),
    );

    // Navigate to the next step, e.g., OTP screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => OtpEntryScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kPrimaryColor),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen (Login)
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // CherryPick Logo/Title
            const Padding(
              padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
              child: Text(
                'CherryPick',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor,
                ),
              ),
            ),

            // Screen Title
            const Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 8.0),

            // Instructions
            const Text(
              'Please enter your User ID or Email to reset your password.',
              style: TextStyle(fontSize: 14, color: kHintTextColor),
            ),
            const SizedBox(height: 40.0),

            // User ID/Email Input Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: kPrimaryColor),
              decoration: InputDecoration(
                labelText: 'User ID / Email',
                labelStyle: const TextStyle(color: kPrimaryColor),
                hintText: 'e.g., yourname@email.com',
                hintStyle: const TextStyle(color: kHintTextColor),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: kHintTextColor),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kHintTextColor, width: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 30.0),

            // Submission Button (Primary CTA)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor, // Black background
                  foregroundColor: kBackgroundColor, // White text
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                onPressed: () => _submitRequest(context),
                child: const Text(
                  'Send Reset Link',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Secondary Action Link
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to login
                },
                child: const Text(
                  'I remember my password (Back to Login)',
                  style: TextStyle(
                    color: kHintTextColor,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
