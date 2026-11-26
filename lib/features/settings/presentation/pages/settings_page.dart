import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/glass_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../locale_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentUrl = AppConfig.baseUrl;
  bool _isTestingPing = false;
  String? _pingResult;
  bool? _pingSuccess;

  Future<void> _testConnection() async {
    setState(() {
      _isTestingPing = true;
      _pingResult = null;
      _pingSuccess = null;
    });

    try {
      final probeDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final res = await probeDio.get(
        '$_currentUrl/auth/login',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );

      if (res.statusCode == 405 || res.statusCode == 200) {
        setState(() {
          _pingSuccess = true;
          _pingResult = 'Connected successfully (Server Alive)';
        });
      } else {
        setState(() {
          _pingSuccess = false;
          _pingResult = 'Server returned HTTP ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _pingSuccess = false;
        _pingResult = 'Cannot reach $_currentUrl. Is Apache/Laragon running?';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isTestingPing = false;
        });
      }
    }
  }

  void _selectUrl(String url) {
    setState(() {
      _currentUrl = url;
      _pingResult = null;
      _pingSuccess = null;
    });
    sl<ApiClient>().updateBaseUrl(url);
    _testConnection();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "الإعدادات والحساب" : "Settings & Profile"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile card
              if (user != null)
                GlassContainer(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: AppColors.accentRoseSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded,
                            size: 30, color: AppColors.accentRoseText),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style:
                                  AppTypography.getHeading3(isArabic: isArabic),
                            ),
                            Text(
                              user.phone,
                              style:
                                  AppTypography.getCaption(isArabic: isArabic),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceInput,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                user.isEmployee
                                    ? (isArabic
                                        ? "فريق عمل الجراج"
                                        : "Valet Staff")
                                    : (isArabic ? "مالك سيارة" : "Car Owner"),
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primaryCrimson,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Language selector
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language_rounded,
                            color: AppColors.accentRoseText),
                        const SizedBox(width: 12),
                        Text(
                          isArabic ? "لغة التطبيق" : "App Language",
                          style: AppTypography.getBodyLarge(isArabic: isArabic),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: isArabic ? 'ar' : 'en',
                      dropdownColor: AppColors.bgElevated,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                            value: 'ar', child: Text('العربية (RTL)')),
                        DropdownMenuItem(
                            value: 'en', child: Text('English (LTR)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          context.read<LocaleCubit>().setLocale(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Backend Info & Server URL Switcher
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic
                              ? "خادم الجراج المتصل"
                              : "Connected Garage Server",
                          style: AppTypography.getCaption(isArabic: isArabic),
                        ),
                        if (_pingSuccess != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _pingSuccess!
                                  ? AppColors.statusReadyBg
                                  : AppColors.statusDangerBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _pingSuccess!
                                      ? Icons.check_circle_rounded
                                      : Icons.error_outline_rounded,
                                  size: 12,
                                  color: _pingSuccess!
                                      ? AppColors.statusReady
                                      : AppColors.statusDanger,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _pingSuccess! ? "Online" : "Offline",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _pingSuccess!
                                        ? AppColors.statusReady
                                        : AppColors.statusDanger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInput,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentUrl,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontFamily: 'monospace'),
                      ),
                    ),
                    if (_pingResult != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _pingResult!,
                        style: TextStyle(
                          fontSize: 11,
                          color: _pingSuccess == true
                              ? AppColors.statusReady
                              : AppColors.statusDanger,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Quick URL Presets
                    Text(
                      isArabic
                          ? "التبديل السريع للخادم:"
                          : "Quick Server Switch:",
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConfig.candidateUrls.map((url) {
                        final isSelected = url == _currentUrl;
                        String label = url;
                        if (url.contains('garage_back')) {
                          label = 'Laragon (Apache)';
                        } else if (url.contains(':8000')) {
                          label = 'Artisan (:8000)';
                        } else if (url.contains('192.168.')) {
                          label = 'Wi-Fi IP';
                        }

                        return ChoiceChip(
                          label:
                              Text(label, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: AppColors.primaryCrimson,
                          backgroundColor: AppColors.surfaceInput,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) => _selectUrl(url),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Test Connection Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _isTestingPing ? null : _testConnection,
                        icon: _isTestingPing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryCrimson),
                              )
                            : const Icon(Icons.network_ping_rounded,
                                size: 16, color: AppColors.accentRoseText),
                        label: Text(
                          isArabic
                              ? "اختبار الاتصال بالخادم"
                              : "Test Connection",
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.accentRoseText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Logout Button
              AppButton(
                text: isArabic ? "تسجيل الخروج" : "Log Out",
                variant: AppButtonVariant.destructive,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await context.read<AuthCubit>().logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 36),

              // Official Brand Logo in Settings Footer
              const Center(
                child: AppLogo.full(
                  height: 90,
                  showGlow: false,
                  showSubtitle: true,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
