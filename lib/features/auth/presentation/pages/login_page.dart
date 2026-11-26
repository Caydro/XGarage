import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/glass_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../settings/presentation/locale_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo(String login, String password) {
    setState(() {
      _loginController.text = login;
      _passwordController.text = password;
    });
    context.read<AuthCubit>().login(login: login, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Crimson Glow Backdrop
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            height: 380,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.8,
                  colors: [AppColors.primaryGlow, Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is Authenticated) {
                      if (state.user.isEmployee) {
                        context.go('/employee/queue');
                      } else {
                        context.go('/owner/dashboard');
                      }
                    } else if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.statusDanger,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Official Brand Identity
                          const AppLogo.emblem(
                            size: 92,
                            showGlow: true,
                            heroTag: 'app_logo_hero',
                          ),
                          const SizedBox(height: 16),
                          const AppLogo.wordmark(
                            size: 28,
                            showSubtitle: true,
                            isItalic: true,
                          ),
                          const SizedBox(height: 24),

                          // Glass Login Form Card
                          GlassContainer(
                            enableBlur: true,
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? "تسجيل الدخول" : "Sign In",
                                  style: AppTypography.getHeading2(isArabic: isArabic),
                                ),
                                const SizedBox(height: 18),

                                // Phone / Email input
                                TextFormField(
                                  controller: _loginController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: isArabic ? "رقم الهاتف أو البريد" : "Phone or Email",
                                    prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 14),

                                // Password input
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: isArabic ? "كلمة المرور" : "Password",
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 22),

                                // Submit Button
                                AppButton(
                                  text: isArabic ? "دخول إلى الجراج" : "Sign In",
                                  isLoading: isLoading,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthCubit>().login(
                                            login: _loginController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Quick 1-Tap Demo Logins
                          Text(
                            isArabic ? "حسابات تجريبية سريعة للفحص:" : "Quick Demo Accounts:",
                            style: AppTypography.getCaption(isArabic: isArabic),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.primaryCrimson.withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _fillDemo('01011111111', 'password123'),
                                  child: Text(
                                    isArabic ? "مالك سيارة (طارق)" : "Car Owner Demo",
                                    style: const TextStyle(fontSize: 12, color: AppColors.accentRoseText),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.statusReady.withValues(alpha: 0.5)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _fillDemo('01000000001', 'password123'),
                                  child: Text(
                                    isArabic ? "سايس الجراج (أحمد)" : "Valet Staff Demo",
                                    style: const TextStyle(fontSize: 12, color: AppColors.statusReady),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Register Navigation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isArabic ? "ليس لديك حساب؟" : "Don't have an account?",
                                style: AppTypography.getBodyMedium(isArabic: isArabic),
                              ),
                              TextButton(
                                onPressed: () => context.push('/register'),
                                child: Text(
                                  isArabic ? "إنشاء حساب مالك جديد" : "Register Owner",
                                  style: const TextStyle(
                                    color: AppColors.primaryCrimson,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
