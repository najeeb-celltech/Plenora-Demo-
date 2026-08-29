import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_input_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../home/screens/home_screen.dart';
import 'signup_screen.dart';

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

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(milliseconds: 1000), () async {
        await AuthService.setLoggedIn(true);
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      });
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.06, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          var fadeAnimation =
              Tween<double>(begin: 0.0, end: 1.0).animate(animation);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 14 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Title & Subtitle (Centered, Refined Typography)
                              Text(
                                "Welcome Back",
                                style: AppTypography.headlineLarge.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  "Log in to manage your bookings and experience top home services.",
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontSize: 14.5,
                                    height: 1.45,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Email Field
                              CustomInputField(
                                label: "Email",
                                hintText: "Enter your email address",
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Please enter your email";
                                  }
                                  final emailRegex = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return "Please enter a valid email";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Password Field
                              CustomInputField(
                                label: "Password",
                                hintText: "Enter your password",
                                controller: _passwordController,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleLogin(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              // Forgot Password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Password reset link sent to your email."),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Forgot Password?",
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Primary Login Button
                              SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  text: "Login",
                                  onPressed: _handleLogin,
                                  isLoading: _isLoading,
                                  height: 54,
                                  borderRadius: 30,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Clean Account Switch Link
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _navigateToSignUp,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Text(
                                        "Sign up",
                                        style: AppTypography.titleSmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
