import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart'; // <-- New: Required import
import '../general/home_screen.dart';
// import 'constants/auth_colors.dart'; // Import if AuthColors is in a separate file

// Replicating AuthColors for a standalone example (best to centralize them)
class AuthColors {
  static const Color background = Colors.black;
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.white70;
  static const Color inputFill = Colors.white;
  static Color inputHint = Colors.grey.shade600;
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    // Simplified Snackbar styling for this example
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Handles the Sign In API call
  Future<void> _signIn() async {
    // Only validate if the user is trying to sign in (not just hitting forgot password)
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = await AuthService().signInWithEmailPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const HomeScreen(),
            ),
          );
          return;
        }
      } on Exception catch (e) {
        if (mounted) {
          _showSnackBar(
            e.toString().replaceFirst('Exception: ', 'Error: '),
            isError: true,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Handles the Forgot Password API call
  void _forgotPassword() {
    // Navigate to the separate screen for a cleaner flow
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));

    // --- ALTERNATIVE: Use the code you provided to send email directly from this screen ---
    /*
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar(
        'Please enter a valid email address in the field above to reset your password.',
        isError: true,
      );
      return;
    }
    // ... proceed with AuthService().sendPasswordResetEmail(email) logic ...
    */
  }

  void _navigateToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
  }

  // Helper widget for consistent styled text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AuthColors.inputHint, fontSize: 16),
        filled: true,
        fillColor: AuthColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0), // Consistent 40.0 radius
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 24.0,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.08,
              vertical: 48.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 1. Logo and App Name
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_basket,
                        color: AuthColors.primaryText,
                        size: 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Smart Price',
                        style: TextStyle(
                          color: AuthColors.primaryText,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // 2. Large Login Title
                  Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AuthColors.primaryText,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 3. Email Field
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email.'; // FIX: Validator returns error message if invalid
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. Password Field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // 5. Login Button (Styled - OutlinedButton)
                  SizedBox(
                    height: 60,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AuthColors.primaryText,
                            ),
                          )
                        : OutlinedButton(
                            onPressed: _signIn,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AuthColors.background,
                              side: const BorderSide(
                                color: AuthColors.primaryText,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                color: AuthColors.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // 6. Navigation/Footer Text
                  Column(
                    children: [
                      TextButton(
                        onPressed:
                            _forgotPassword, // Navigate to ForgotPasswordScreen
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(color: AuthColors.secondaryText),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AuthColors.secondaryText),
                          ),
                          GestureDetector(
                            onTap: _navigateToSignUp,
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AuthColors.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
