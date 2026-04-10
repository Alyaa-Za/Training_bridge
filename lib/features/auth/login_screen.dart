import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/auth_card.dart';
import '../../core/widgets/custom_input.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/secure_storage.dart';
import '../../data/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../student/student_home.dart';
import '../institution/institution_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  Future<void> _handleLogin() async {
    // التحقق من صحة البيانات المدخلة
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        'Please fill all fields correctly',
        isError: true,
        icon: Icons.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('═══════════════════════════════════');
      print('🔐 ATTEMPTING LOGIN');
      print('📧 Email: ${_emailController.text.trim()}');
      print('═══════════════════════════════════');

      final response = await ApiService().post(
        ApiConstants.login,
        {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      print('═══════════════════════════════════');
      print('📥 LOGIN RESPONSE');
      print('✅ Success: ${response.success}');
      print('💬 Message: ${response.message}');
      print('📦 Data: ${response.data}');
      print('═══════════════════════════════════');

      if (!mounted) return;

      if (response.success) {
        // استخراج البيانات
        final token = response.data['token'] ?? response.data['access_token'];
        final role = response.data['role'] ?? 'student';

        if (token == null) {
          _showSnackBar(
            'Login failed: No token received from server',
            isError: true,
            icon: Icons.error,
          );
          return;
        }

        // حفظ البيانات
        await SecureStorage().saveToken(token);
        await SecureStorage().saveRole(role);

        print('✅ Token saved: ${token.substring(0, 10)}...');
        print('✅ Role saved: $role');

        // عرض رسالة نجاح
        _showSnackBar(
          'Welcome! Login successful',
          isError: false,
          icon: Icons.check_circle,
        );

        // الانتقال للصفحة المناسبة
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentHome()),
          );
        } else if (role == 'institution') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InstitutionHome()),
          );
        } else {
          _showSnackBar(
            'Unknown user role: $role',
            isError: true,
            icon: Icons.error,
          );
        }
      } else {
        // فشل تسجيل الدخول - رسالة واضحة
        String errorMessage = response.message;

        // تحسين رسائل الخطأ
        if (errorMessage.toLowerCase().contains('credentials') ||
            errorMessage.toLowerCase().contains('invalid') ||
            errorMessage.toLowerCase().contains('unauthorized')) {
          errorMessage = '❌ Invalid email or password\nPlease check your credentials';
        } else if (errorMessage.toLowerCase().contains('network') ||
            errorMessage.toLowerCase().contains('internet')) {
          errorMessage = '🌐 No internet connection\nPlease check your network';
        } else if (errorMessage.isEmpty) {
          errorMessage = '⚠️ Login failed\nPlease try again';
        }

        _showSnackBar(
          errorMessage,
          isError: true,
          icon: Icons.cancel,
          duration: 4,
        );
      }
    } catch (e) {
      print('═══════════════════════════════════');
      print('❌ LOGIN EXCEPTION');
      print('Error: $e');
      print('Type: ${e.runtimeType}');
      print('═══════════════════════════════════');

      if (!mounted) return;

      _showSnackBar(
        '❌ Connection Error\n$e',
        isError: true,
        icon: Icons.error_outline,
        duration: 5,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(
      String message, {
        required bool isError,
        IconData? icon,
        int duration = 3,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? (isError ? Icons.error : Icons.check_circle),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: duration),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.primaryLight.withOpacity(0.6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated bubbles
            ..._buildBubbles(),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: AuthCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.school,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Welcome text
                          const Center(
                            child: Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Center(
                            child: Text(
                              'Login to continue your journey',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Email input
                          CustomInput(
                            label: 'Email',
                            hint: 'Enter your email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),

                          const SizedBox(height: 16),

                          // Password input
                          CustomInput(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _passwordController,
                            isPassword: true,
                            validator: Validators.password,
                            prefixIcon: const Icon(Icons.lock_outlined),
                          ),

                          const SizedBox(height: 24),

                          // Login button
                          PrimaryButton(
                            text: 'Login',
                            onPressed: _handleLogin,
                            isLoading: _isLoading,
                            icon: Icons.login,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBubbles() {
    return List.generate(
      5,
          (index) => Positioned(
        left: (index * 100.0) % MediaQuery.of(context).size.width,
        top: (index * 150.0) % MediaQuery.of(context).size.height,
        child: Container(
          width: 60 + (index * 15.0),
          height: 60 + (index * 15.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}