import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/glass_container.dart';
import 'app_button.dart';

class NotificationsSheet extends StatefulWidget {
  final bool isArabic;

  const NotificationsSheet({super.key, required this.isArabic});

  static void show(BuildContext context, {required bool isArabic}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsSheet(isArabic: isArabic),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  String? _fcmToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await NotificationService().getFcmToken();
    if (mounted) {
      setState(() {
        _fcmToken = token;
        _isLoading = false;
      });
    }
  }

  void _copyToken() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isArabic ? "تم نسخ كود جهازك (FCM Token)" : "FCM Token copied to clipboard!",
          ),
          backgroundColor: AppColors.statusReady,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.accentRoseSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primaryCrimson,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isAr ? "مركز الإشعارات الحية" : "Live Push Notifications",
                    style: AppTypography.getHeading3(isArabic: isAr),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.statusReadyBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.statusReady.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.statusReady,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'FCM Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusReady,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Informational description
          Text(
            isAr
                ? "تصلك إشعارات فورية عند طلب خروج سيارتك، بدء الغسيل، وتجهيز السيارة أمام بوابة الجراج."
                : "Real-time push alerts arrive when car departures are requested, washing begins, or your vehicle is ready at the gate.",
            style: AppTypography.getCaption(isArabic: isAr),
          ),
          const SizedBox(height: 16),

          // Device FCM Token Card
          GlassContainer(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "معرّف جهازك لـ Firebase (Token):" : "Your Device FCM Token:",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_fcmToken != null)
                      GestureDetector(
                        onTap: _copyToken,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.copy_rounded, size: 14, color: AppColors.accentRoseText),
                            const SizedBox(width: 4),
                            Text(
                              isAr ? "نسخ" : "Copy",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentRoseText,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryCrimson),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInput,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _fcmToken ?? (isAr ? "لم يتم استخراج الكود بعد" : "Token unavailable yet"),
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Close button
          AppButton(
            text: isAr ? "إغلاق" : "Close",
            variant: AppButtonVariant.glass,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
