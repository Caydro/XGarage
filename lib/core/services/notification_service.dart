import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final _messageStreamController = StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get onMessageStream => _messageStreamController.stream;

  bool _initialized = false;
  String? _cachedToken;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'xgarage_notifications',
    'XGarage Notifications',
    description: 'Urgent valet and car departure status updates',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  Future<void> init() async {
    if (_initialized) return;

    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp();

      // 2. Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Request permissions
      await _requestPermissions();

      // 4. Setup Android Local Notifications Channel for foreground Heads-Up
      if (!kIsWeb && Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);

        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const initSettings = InitializationSettings(android: androidSettings);

        await _localNotifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            // Can handle notification click routing
          },
        );
      }

      // 5. Foreground Message Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _messageStreamController.add(message);

        final notification = message.notification;
        final android = message.notification?.android;

        // Display Heads-Up notification popup when app is open in foreground
        if (notification != null && !kIsWeb && Platform.isAndroid) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.high,
                priority: Priority.high,
                color: const Color(0xFFFF2E55),
              ),
            ),
            payload: message.data['screen'],
          );
        }
      });

      // 6. Background to Foreground Click Listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _messageStreamController.add(message);
      });

      // 7. Cache initial FCM Token
      try {
        _cachedToken = await FirebaseMessaging.instance.getToken();
      } catch (_) {}

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization skipped or failed: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('User granted notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  Future<String?> getFcmToken() async {
    if (_cachedToken != null) return _cachedToken;
    try {
      _cachedToken = await FirebaseMessaging.instance.getToken();
      return _cachedToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Sync device FCM token with Laravel backend to receive push alerts
  Future<void> syncTokenWithBackend(ApiClient apiClient) async {
    try {
      final token = await getFcmToken();
      if (token != null && token.isNotEmpty) {
        await apiClient.post(
          ApiEndpoints.updateFcmToken,
          data: {'fcm_token': token},
        );
        debugPrint('FCM Token synced with XGarage backend successfully: $token');
      }

      // Keep backend synced whenever Google rotates the token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        _cachedToken = newToken;
        try {
          await apiClient.post(
            ApiEndpoints.updateFcmToken,
            data: {'fcm_token': newToken},
          );
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Failed to sync FCM token with backend: $e');
    }
  }

  void dispose() {
    _messageStreamController.close();
  }
}
