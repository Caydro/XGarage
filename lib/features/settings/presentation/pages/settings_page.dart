import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/glass_container.dart';
import '../../../../core/utils/avatar_url_helper.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../auth/domain/entities/user_entity.dart';
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
  bool _isUploadingAvatar = false;
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

  Future<void> _pickAndUploadAvatar(bool isArabic) async {
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              isArabic ? "تغيير الصورة الشخصية" : "Change Profile Photo",
              style: AppTypography.getHeading3(isArabic: isArabic),
            ),
            const SizedBox(height: 6),
            Text(
              isArabic
                  ? "اختر مصدراً لرفع صورتك الشخصية الجديدة"
                  : "Choose a source to upload your profile photo",
              style: AppTypography.getCaption(isArabic: isArabic),
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.surfaceInput,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.accentRoseSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded,
                    color: AppColors.accentRoseText, size: 20),
              ),
              title: Text(
                isArabic ? "اختيار من المعرض" : "Choose from Gallery",
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.surfaceInput,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.accentRoseSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.accentRoseText, size: 20),
              ),
              title: Text(
                isArabic ? "التقاط بالكاميرا" : "Take Photo with Camera",
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return;

      if (!mounted) return;
      setState(() => _isUploadingAvatar = true);

      await context.read<AuthCubit>().updateAvatar(file.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "تم تحديث الصورة الشخصية بنجاح"
                : "Profile photo updated successfully",
          ),
          backgroundColor: AppColors.statusReady,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "حدث خطأ أثناء رفع الصورة: $e"
                : "Failed to upload photo: $e",
          ),
          backgroundColor: AppColors.statusDanger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _isUploadingAvatar
                                ? null
                                : () => _pickAndUploadAvatar(isArabic),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 66,
                                  height: 66,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceInput,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryCrimson.withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryCrimson.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _isUploadingAvatar
                                      ? const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryCrimson),
                                            ),
                                          ),
                                        )
                                      : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                                          ? Image.network(
                                              resolveAvatarUrl(user.avatarUrl),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Center(
                                                child: Icon(Icons.person_rounded, size: 34, color: AppColors.accentRoseText),
                                              ),
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return const Center(
                                                  child: SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryCrimson),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : const Center(
                                              child: Icon(Icons.person_rounded, size: 34, color: AppColors.accentRoseText),
                                            ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: isArabic ? null : -2,
                                  left: isArabic ? -2 : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryCrimson,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.bgPrimary, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: AppTypography.getHeading3(
                                      isArabic: isArabic),
                                ),
                                Text(
                                  user.phone,
                                  style: AppTypography.getCaption(
                                      isArabic: isArabic),
                                ),
                                if (user.email != null &&
                                    user.email!.isNotEmpty) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    user.email!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
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
                                        : (isArabic
                                            ? "مالك سيارة"
                                            : "Car Owner"),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primaryCrimson,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded,
                                color: AppColors.accentRoseText, size: 26),
                            tooltip: isArabic
                                ? "تعديل البيانات الشخصية"
                                : "Edit Profile",
                            onPressed: () =>
                                _openEditProfileSheet(context, user, isArabic),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: isArabic
                            ? "تعديل بيانات الحساب ورقم الهاتف"
                            : "Edit Profile & Phone Number",
                        icon: Icons.edit_outlined,
                        variant: AppButtonVariant.glass,
                        height: 42,
                        onPressed: () =>
                            _openEditProfileSheet(context, user, isArabic),
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

  void _openEditProfileSheet(
      BuildContext context, UserEntity user, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          _EditProfileBottomSheet(user: user, isArabic: isArabic),
    );
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  final UserEntity user;
  final bool isArabic;

  const _EditProfileBottomSheet({
    required this.user,
    required this.isArabic,
  });

  @override
  State<_EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = widget.isArabic
            ? "يرجى كتابة الاسم بالكامل"
            : "Full name cannot be empty";
      });
      return;
    }

    if (phone.isEmpty) {
      setState(() {
        _errorMessage = widget.isArabic
            ? "يرجى كتابة رقم الهاتف"
            : "Phone number cannot be empty";
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthCubit>().updateProfile(
            name: name,
            phone: phone,
            email: email.isEmpty ? null : email,
            password: password.isEmpty ? null : password,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  widget.isArabic
                      ? "تم تحديث بياناتك بنجاح!"
                      : "Profile updated successfully!",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            backgroundColor: AppColors.statusReady,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white12, width: 1.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Sheet Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_pin_rounded,
                        color: AppColors.accentRoseText, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      isAr
                          ? "تعديل البيانات الشخصية"
                          : "Edit Profile Information",
                      style: AppTypography.getHeading3(isArabic: isAr),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.statusDangerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.statusDanger.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.statusDanger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: AppColors.statusDanger, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Full Name Field
            Text(
              isAr ? "الاسم بالكامل" : "Full Name",
              style: AppTypography.getCaption(isArabic: isAr),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline_rounded,
                    color: AppColors.textMuted),
                hintText: isAr ? "أحمد محمد" : "Ahmed Mohamed",
              ),
            ),
            const SizedBox(height: 14),

            // Phone Number Field
            Text(
              isAr ? "رقم الهاتف (لتسجيل الدخول والتواصل)" : "Phone Number",
              style: AppTypography.getCaption(isArabic: isAr),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_outlined,
                    color: AppColors.textMuted),
                hintText: "01000000001",
              ),
            ),
            const SizedBox(height: 14),

            // Email Address Field
            Text(
              isAr ? "البريد الإلكتروني (اختياري)" : "Email Address (Optional)",
              style: AppTypography.getCaption(isArabic: isAr),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined,
                    color: AppColors.textMuted),
                hintText: "user@example.com",
              ),
            ),
            const SizedBox(height: 14),

            // Password Change Field
            Text(
              isAr
                  ? "تغيير كلمة المرور (اتركها فارغة إن لم ترغب في التغيير)"
                  : "Change Password (Leave blank to keep current)",
              style: AppTypography.getCaption(isArabic: isAr),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                hintText: isAr ? "••••••••" : "••••••••",
              ),
            ),
            const SizedBox(height: 22),

            // Save Changes CTA Button with 3 Jumping Dots
            AppButton(
              text: isAr ? "حفظ التغييرات" : "Save Changes",
              icon: Icons.check_rounded,
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
