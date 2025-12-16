import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'sign_in_screen.dart'; // Required import

// Replicating AuthColors for a standalone example (best to centralize them)
class AuthColors {
  static const Color background = Colors.black;
  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.white70;
  static const Color inputFill = Colors.white;
  static Color inputHint = Colors.grey.shade600;
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Asynchronous Sign-Up Logic
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await AuthService().signUpWithEmailPassword(
          _emailController.text,
          _passwordController.text,
          _usernameController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully. Please sign in.'),
            duration: Duration(seconds: 4),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );

      } on Exception catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', 'Error: '))
          ),
        );

      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }

  // Helper widget for text field styling consistency
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
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0), // Consistent padding
      ),
      validator: validator,
    );
  }

  // UI Build Method with Form and Validators
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

                  // 2. Large SignUp Title
                  Text(
                    'SignUp',
                    style: TextStyle(
                      color: AuthColors.primaryText,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 3. Username/Name Field
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. Email Field
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 5. Password Field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password (min 6 characters)',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 6. Confirm Password Field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password.';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // 7. Sign Up Button (Styled - OutlinedButton)
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AuthColors.primaryText,))
                        : OutlinedButton( // **CHANGED to OutlinedButton**
                      onPressed: _signUp,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AuthColors.background,
                        side: const BorderSide(color: AuthColors.primaryText, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          color: AuthColors.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // 8. Navigation back to Sign In
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: AuthColors.secondaryText),
                      ),
                      GestureDetector(
                        onTap: _navigateToSignIn,
                        child: const Text(
                          'Sign In',
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
            ),
          ),
        ),
      ),
    );
  }
}