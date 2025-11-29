import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_login_button.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void _validatePasswords() {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;

      if (_passwordController.text.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      }
    });
  }

  void _handleCreateAccount() async {
    _validatePasswords();

    if (_passwordError != null || _confirmPasswordError != null) {
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez entrer une adresse email');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès!')),
        );
        // Retourner à l'écran de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleSocialSignUp(String provider) async {
    if (provider == 'Google') {
      await _handleGoogleSignUp();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up avec $provider (Non implémenté)')),
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signUpWithGoogle();

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription Google réussie!')),
        );
        // Navigation vers l'écran principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Google Sign-In n\'est pas configuré')) {
          errorMessage =
              'Google Sign-In n\'est pas encore configuré.\n\nPour l\'activer :\n1. Obtenez un Client ID Google\n2. Remplacez YOUR_GOOGLE_CLIENT_ID dans web/index.html';
        }
        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              // Create account title
              const Text(
                'CREATE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'AN ACCOUNT',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // First Name field
              CustomTextField(
                hintText: 'First Name',
                prefixIcon: Icons.person_outline,
                controller: _firstNameController,
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 16),

              // Last Name field
              CustomTextField(
                hintText: 'Last Name',
                prefixIcon: Icons.person_outline,
                controller: _lastNameController,
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 16),

              // Date of birth label
              const Text(
                'Date of birth',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              // Date of birth fields (MM/DD/YYYY)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      hintText: 'MM',
                      prefixIcon: Icons.calendar_today,
                      controller: _monthController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      hintText: 'DD',
                      prefixIcon: Icons.calendar_today,
                      controller: _dayController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      hintText: 'YYYY',
                      prefixIcon: Icons.calendar_today,
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Password field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    onChanged: (_) => _validatePasswords(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        _passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Confirm Password field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    hintText: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    onChanged: (_) => _validatePasswords(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: _toggleConfirmPasswordVisibility,
                    ),
                  ),
                  if (_confirmPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        _confirmPasswordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Upload Image section
              const Text(
                'Upload image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              // Upload Image button
              InkWell(
                onTap: () {
                  // TODO: Implement image picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upload image functionality')),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Photo',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Privacy notice
              Text(
                'By clicking the Register button, you agree\nto the public offer',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),

              const SizedBox(height: 24),

              // Create Account button
              CustomButton(
                text: 'Create Account',
                onPressed: _handleCreateAccount,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 40),

              // OR divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[700])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '- OR Continue with -',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[700])),
                ],
              ),

              const SizedBox(height: 24),

              // Social login buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialLoginButton(
                    assetPath: 'google',
                    onPressed: () => _handleSocialSignUp('Google'),
                  ),
                  SocialLoginButton(
                    assetPath: 'apple',
                    onPressed: () => _handleSocialSignUp('Apple'),
                  ),
                  SocialLoginButton(
                    assetPath: 'facebook',
                    onPressed: () => _handleSocialSignUp('Facebook'),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'I Already Have an Account ',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  TextButton(
                    onPressed: _handleLogin,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF6B46C1),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
