import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../app_init.dart';
import '../screens/notification_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  // await NotificationService.instance.showLocalNotification(message);
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'skinsync_default',
    'SkinSync notifications',
    description: 'SkinSync AI alerts and updates.',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap();
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      log('FCM permission granted');
    } else {
      log('FCM permission denied');
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) async {
      await showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap();
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap();
    }

    _messaging.onTokenRefresh.listen((token) {
      log('FCM token refreshed: $token');
    });
    _isInitialized = true;
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    if (!_isInitialized) {
      await initialize();
    }

    final notification = message.notification;
    log('NOTIFICATION RECEIVED: ${notification?.title}');
    if (notification == null) {
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final title = notification.title ?? 'SkinSync AI';
    final body = notification.body ?? 'You have a new notification';
    final payload = message.data['screen'] is String
        ? message.data['screen'] as String
        : NotificationScreen.routeName;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'SkinSync AI',
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  void _handleNotificationTap() {
    navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
  }
}
