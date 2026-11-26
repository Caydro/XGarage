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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _makeController = TextEditingController(text: 'Audi');
  final _modelController = TextEditingController(text: 'A6');
  final _plateLettersController = TextEditingController(text: 'ق هـ و');
  final _plateNumbersController = TextEditingController(text: '٤٣٢١');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _plateLettersController.dispose();
    _plateNumbersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo.emblem(size: 28, showGlow: false),
            const SizedBox(width: 10),
            Text(isArabic ? "تسجيل مالك جديد" : "Register Car Owner"),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                context.go('/owner/dashboard');
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "بيانات المالك" : "Owner Details",
                            style: AppTypography.getHeading3(isArabic: isArabic),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: isArabic ? "الاسم بالكامل" : "Full Name",
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: isArabic ? "رقم الهاتف (مثل 01012345678)" : "Phone Number",
                            ),
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: isArabic ? "كلمة المرور" : "Password",
                            ),
                            validator: (v) => v == null || v.length < 6 ? "Minimum 6 chars" : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    GlassContainer(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "بيانات سيارتك الأولى (اختياري الآن)" : "First Vehicle Details",
                            style: AppTypography.getHeading3(isArabic: isArabic),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _makeController,
                                  decoration: InputDecoration(
                                    labelText: isArabic ? "الماركة" : "Make",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _modelController,
                                  decoration: InputDecoration(
                                    labelText: isArabic ? "الموديل" : "Model",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _plateLettersController,
                                  decoration: InputDecoration(
                                    labelText: isArabic ? "حروف اللوحة" : "Plate Letters",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _plateNumbersController,
                                  decoration: InputDecoration(
                                    labelText: isArabic ? "أرقام اللوحة" : "Plate Numbers",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: isArabic ? "إنشاء الحساب ودخول الجراج" : "Create Account & Enter",
                      isLoading: isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthCubit>().register(
                                name: _nameController.text.trim(),
                                phone: _phoneController.text.trim(),
                                password: _passwordController.text.trim(),
                                make: _makeController.text.trim().isEmpty ? null : _makeController.text.trim(),
                                model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
                                plateLetters: _plateLettersController.text.trim().isEmpty
                                    ? null
                                    : _plateLettersController.text.trim(),
                                plateNumbers: _plateNumbersController.text.trim().isEmpty
                                    ? null
                                    : _plateNumbersController.text.trim(),
                              );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
