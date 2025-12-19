import 'package:flutter/material.dart';
import '../../../backend/services/auth_service.dart';
import '../../config/app_routes.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

// Figma Design Colors
const Color kLoginRed = Color(0xFFD94C4C); // Primary red
const Color kLoginRedDark = Color(0xFFC43C3C); // Darker red for hover
const Color kLoginWhite = Color(0xFFFFFFFF); // White
const Color kTextDark = Color(0xFF1A1A1A); // Gray-900
const Color kTextLight = Color(0xFF808080); // Gray-600
const Color kInputBg = Color(0xFFF9FAFB); // Gray-50
const Color kInputBorder = Color(0xFFE5E7EB); // Gray-200
const Color kForgotPasswordBlue = Color(0xFF2563EB); // Blue-600

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
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
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authService = AuthService();
        // Add timeout to prevent indefinite loading
        await authService
            .signInWithEmailPassword(
              _emailController.text,
              _passwordController.text,
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception(
                  'Login timed out. Please check your internet connection and try again.',
                );
              },
            );

        if (mounted) {
          // Navigate immediately after successful login
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          return;
        }
      } on Exception catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar(
            e.toString().replaceFirst('Exception: ', 'Error: '),
            isError: true,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar(
            'An unexpected error occurred. Please try again.',
            isError: true,
          );
        }
      }
    }
  }

  void _continueAsGuest() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _forgotPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
  }

  void _navigateToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background: from-red-50 to-orange-50
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFEF2F2), // red-50
              Color(0xFFFFF7ED), // orange-50
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
                        child: Row(
                          children: [
                            // App Logo
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: kLoginRed,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _buildAppLogo(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // SmartPrice text
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
                                  'Welcome back!',
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
                      ),
                    ),
                  );
                },
              ),

              // Form Section with rounded top corners
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
                            color: kLoginWhite,
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
                                  // Login Title
                                  const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: kTextDark,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Sign in to continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: kTextLight,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Email Field
                                  _buildEmailField(),
                                  const SizedBox(height: 24),

                                  // Password Field
                                  _buildPasswordField(),
                                  const SizedBox(height: 12),

                                  // Forgot Password Link
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _forgotPassword,
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: kForgotPasswordBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Login Button
                                  _buildLoginButton(),
                                  const SizedBox(height: 16),

                                  // Continue as Guest Button
                                  _buildGuestButton(),
                                  const SizedBox(height: 32),

                                  // Sign Up Link
                                  _buildSignUpLink(),
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
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
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: kTextDark, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: const TextStyle(color: kTextLight),
            prefixIcon: const Icon(Icons.email_outlined, color: kTextLight),
            filled: true,
            fillColor: kInputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kInputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kInputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kLoginRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || !value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextDark,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: kTextDark, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: const TextStyle(color: kTextLight),
            prefixIcon: const Icon(Icons.lock_outline, color: kTextLight),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: kTextLight,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: kInputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kInputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kInputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kLoginRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: kLoginRed,
          foregroundColor: kLoginWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(kLoginWhite),
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
      ),
    );
  }

  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _continueAsGuest,
        style: OutlinedButton.styleFrom(
          backgroundColor: kLoginWhite,
          foregroundColor: kTextDark,
          side: const BorderSide(color: kInputBorder, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continue as Guest',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            color: kTextLight,
            fontFamily: 'Roboto',
          ),
        ),
        GestureDetector(
          onTap: _navigateToSignUp,
          child: const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: kLoginRed,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }

  /// Build app logo with fallback to icon
  Widget _buildAppLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to shopping cart icon if logo not found
        return Container(
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.shopping_cart, color: kLoginWhite, size: 32),
        );
      },
    );
  }
}
