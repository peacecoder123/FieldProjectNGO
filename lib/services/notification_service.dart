import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler for FCM.
/// Must be outside any class to be accessible while app is in background/terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, 
  // such as Firestore, make sure you call `Firebase.initializeApp()` here.
  debugPrint('Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Notification channel for Android (Heads-up notifications)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Request Permissions (iOS/Android 13+/Web)
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Setup Background Handler (Skipped on Web as it uses the Service Worker directly)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }

      // 3. Setup Local Notifications (foreground support)
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        // Web local notifications are handled differently
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      if (!kIsWeb) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      // 4. Configure Listeners
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

      _initialized = true;
      debugPrint('PushNotificationService initialized.');
    } catch (e) {
      debugPrint('Warning: PushNotificationService failed to initialize: $e');
      // We don't rethrow here so the app can still boot and seed data
    }
  }

  /// Returns the current device token for FCM.
  Future<String?> getFcmToken() async {
    try {
      debugPrint('FCM: Requesting token from Firebase...');
      final token = await _fcm.getToken();
      if (token == null) {
        debugPrint('FCM: Token is NULL. This usually means the browser blocked the request or the service worker isn\'t ready.');
      } else {
        debugPrint('FCM: Token successfully retrieved: ${token.substring(0, 10)}...');
      }
      return token;
    } catch (e) {
      debugPrint('FCM Error during getToken(): $e');
      return null;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android.smallIcon,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Triggers a local notification immediately.
  /// Used for workflow event feedback (simulating push notifications).
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id: title.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('Notification clicked (App opened from background): ${message.data}');
    // TODO: Add navigation logic here based on message.data
  }
}
