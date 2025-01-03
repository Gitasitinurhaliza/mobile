import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late NotificationDetails platformChannelSpecifics;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, macOS: null);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationResponse,
    );

    final String imagePath =
        await loadImageFromAssets('assets/png/logo.png', 'logo.png');

    print(imagePath);

    platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Notifikasi Penting',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'ticker',
      icon: '@mipmap/launcher_icon',
      enableVibration: true,
      enableLights: true,
      playSound: true,
      styleInformation: const BigTextStyleInformation(''),
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      channelShowBadge: true,
      showWhen: true,
      largeIcon: FilePathAndroidBitmap(imagePath),
    ));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(message.notification?.title ?? 'No Title',
            message.notification?.body ?? 'No Body');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String> loadImageFromAssets(String assetPath, String fileName) async {
    // Baca file dari assets
    final ByteData data = await rootBundle.load(assetPath);

    // Dapatkan path direktori lokal
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';

    // Simpan file di direktori lokal
    final File file = File(filePath);
    await file.writeAsBytes(data.buffer.asUint8List());

    return filePath;
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    showNotification(message.notification?.title ?? 'No Title',
        message.notification?.body ?? 'No Body');
  }

  Future showNotification(String title, String body) async {
    await flutterLocalNotificationsPlugin.show(
      0,
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
