import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService(
          {required FlutterLocalNotificationsPlugin localNotifications,
          required FirebaseMessaging firebaseMessaging}) =>
      _instance;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _notificationStreamController =
      StreamController<NotificationData>.broadcast();

  Stream<NotificationData> get notificationStream =>
      _notificationStreamController.stream;
  bool _isInitialized = false;

  NotificationService._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize(
      {required void Function(String? payload) onTapNotification}) async {
    if (_isInitialized) return;

    try {
      await _setupNotifications();
      _isInitialized = true;
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
      rethrow;
    }
  }

  Future<void> _setupNotifications() async {
    await _requestPermissions();
    await _initializeLocalNotifications();
    await _createNotificationChannel();
    await _setupFirebaseMessaging();
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('User granted permission: ${settings.authorizationStatus}');

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    } catch (e) {
      print('Error requesting permissions: $e');
      rethrow;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification response received: ${response.payload}');
        _handleNotificationResponse(response);
      },
    );
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupFirebaseMessaging() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Token refresh handling
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      // Here you could send the new token to your server
    });

    // Handle initial message for terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });

    // Handle background/terminated state messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleForegroundNotification(String title, String body) {
    final notification = NotificationData(
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    _notificationStreamController.add(notification);
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background/terminated message: ${message.messageId}');

    await showNotification(
      title: message.notification?.title ?? 'Background Notification',
      body: message.notification?.body ?? '',
      notificationId: DateTime.now().millisecond,
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    int? notificationId,
    required Map<String, String> payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final id = notificationId ?? DateTime.now().millisecond;

    try {
      final androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        enableVibration: true,
        enableLights: true,
        playSound: true,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.alarm,
        styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: true,
          contentTitle: title,
          htmlFormatContentTitle: true,
        ),
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: 'default',
      );

      _notificationStreamController.add(
        NotificationData(
          title: title,
          body: body,
          timestamp: DateTime.now(),
        ),
      );

      print('Notification shown successfully: $title');
    } catch (e) {
      print('Error showing notification: $e');
      rethrow;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    print('Handling foreground message: ${message.messageId}');

    await showNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
      notificationId: DateTime.now().millisecond,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    print('Handling notification response: ${response.payload}');

    final notification = NotificationData(
      title: 'Notification Tapped',
      body: response.payload ?? '',
      timestamp: DateTime.now(),
    );

    _notificationStreamController.add(notification);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling background message: ${message.messageId}');

    final notificationService = NotificationService();
    await notificationService.showNotification(
      title: message.notification?.title ?? 'Background Notification',
      body: message.notification?.body ?? '',
      notificationId: DateTime.now().millisecond,
    );
  }

  void dispose() {
    _notificationStreamController.close();
    _isInitialized = false;
    print('NotificationService disposed');
  }
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}

class NotificationData {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationData({
    required this.title,
    required this.body,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'NotificationData{title: $title, body: $body, timestamp: $timestamp}';
  }
}
