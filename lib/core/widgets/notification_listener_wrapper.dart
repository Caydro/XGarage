import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/glass_container.dart';

class NotificationListenerWrapper extends StatefulWidget {
  final Widget child;

  const NotificationListenerWrapper({super.key, required this.child});

  @override
  State<NotificationListenerWrapper> createState() => _NotificationListenerWrapperState();
}

class _NotificationListenerWrapperState extends State<NotificationListenerWrapper> {
  StreamSubscription<RemoteMessage>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = NotificationService().onMessageStream.listen(_handleIncomingMessage);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handleIncomingMessage(RemoteMessage message) {
    if (!mounted) return;

    HapticFeedback.mediumImpact();

    final title = message.notification?.title ?? message.data['title'] ?? 'إشعار جديد';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final screen = message.data['screen'] as String?;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 4),
        content: GlassContainer(
          enableBlur: true,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.accentRoseSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primaryCrimson,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (screen != null && screen.isNotEmpty) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    context.go(screen);
                  },
                  child: const Text(
                    'عرض',
                    style: TextStyle(
                      color: AppColors.accentRoseText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
