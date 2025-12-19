import 'package:flutter/material.dart';
import '../../../backend/services/auth_service.dart';
import 'sign_in_screen.dart';

// Figma Design Colors
const Color kForgotPasswordBlue = Color(0xFF2563EB); // Blue-600
const Color kForgotPasswordBlueDark = Color(0xFF1D4ED8); // Blue-700
const Color kForgotPasswordWhite = Color(0xFFFFFFFF); // White
const Color kTextDark = Color(0xFF1A1A1A); // Gray-900
const Color kTextLight = Color(0xFF808080); // Gray-600
const Color kInputBg = Color(0xFFF9FAFB); // Gray-50
const Color kInputBorder = Color(0xFFE5E7EB); // Gray-200
const Color kSuccessGreen = Color(0xFF10B981); // Green-500
const Color kSuccessGreenBg = Color(0xFFD1FAE5); // Green-100

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitted = false;
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = AuthService();
        await authService.sendPasswordResetEmail(_emailController.text);
        if (mounted) {
          setState(() {
            _isSubmitted = true;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  void _backToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      body: Container(
        // Gradient background: from-blue-50 to-cyan-50
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF), // blue-50
              Color(0xFFECFEFF), // cyan-50
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _headerAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, -20 * (1 - _headerAnimation.value)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
                        child: Column(
                          children: [
                            // Back button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _backToLogin,
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: kTextLight,
                                  size: 20,
                                ),
                                label: const Text(
                                  'Back',
                                  style: TextStyle(
                                    color: kTextLight,
                                    fontSize: 16,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Logo and title
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: kForgotPasswordBlue,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: const Icon(
                                    Icons.shopping_cart,
                                    color: kForgotPasswordWhite,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SmartPrice',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: kTextDark,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    Text(
                                      'Reset your password',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: kTextLight,
                                        fontFamily: 'Roboto',
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
                  );
                },
              ),

              // Form Section
              Expanded(
                child: AnimatedBuilder(
                  animation: _formAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _formAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _formAnimation.value)),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: kForgotPasswordWhite,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: kTextDark,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No worries! Enter your email address and we\'ll send you a link to reset your password.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: kTextLight,
                                      height: 1.5,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Email Field
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Email Address',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: kTextDark,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: const TextStyle(
                                          color: kTextDark,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your email',
                                          hintStyle: const TextStyle(
                                            color: kTextLight,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            color: kTextLight,
                                          ),
                                          filled: true,
                                          fillColor: kInputBg,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: kInputBorder,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: kInputBorder,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: kForgotPasswordBlue,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 20,
                                              ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty ||
                                              !value.contains('@')) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Send Reset Link Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kForgotPasswordBlue,
                                        foregroundColor: kForgotPasswordWhite,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Send Reset Link',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Back to Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: OutlinedButton(
                                      onPressed: _backToLogin,
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: kForgotPasswordWhite,
                                        foregroundColor: kTextDark,
                                        side: const BorderSide(
                                          color: kInputBorder,
                                          width: 2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Back to Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF), // blue-50
              Color(0xFFECFEFF), // cyan-50
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _backToLogin,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: kTextLight,
                          size: 20,
                        ),
                        label: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: kTextLight,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: kForgotPasswordBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: kForgotPasswordWhite,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'SmartPrice',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Success Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: kForgotPasswordWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Success Icon
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: kSuccessGreenBg,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(24),
                          child: const Icon(
                            Icons.check_circle,
                            size: 48,
                            color: kSuccessGreen,
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Check Your Email',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'We\'ve sent a password reset link to\n${_emailController.text}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: kTextLight,
                            height: 1.5,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSubmitted = false;
                            });
                          },
                          child: Text(
                            'Didn\'t receive the email? Check your spam folder or try again',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: kForgotPasswordBlue,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _backToLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kForgotPasswordBlue,
                              foregroundColor: kForgotPasswordWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
