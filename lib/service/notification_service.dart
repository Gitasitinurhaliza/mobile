import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late NotificationDetails platformChannelSpecifics;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, macOS: null);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationResponse,
    );

    platformChannelSpecifics = const NotificationDetails(
        android: AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Notifikasi Penting',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      enableLights: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      channelShowBadge: true,
    ));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(message.notification?.title ?? 'No Title',
            message.notification?.body ?? 'No Body');
      }
    });
  }

  Future showNotification(String title, String body) async {
    await flutterLocalNotificationsPlugin.show(
      12345,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future onNotificationResponse(
      NotificationResponse notificationResponse) async {
    // Handle notification tapped logic here
    String? payload = notificationResponse.payload;
    if (payload != null) {
      // Handle the payload as needed
    }
  }
}
