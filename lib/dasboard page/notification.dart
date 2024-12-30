import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vantech/dasboard%20page/dashboard.dart';
import 'dart:io';
import 'package:vantech/profil/profil.dart';

// Background message handler must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");

  // Show notification when the app is in the background
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("UltrasonicData");
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Map<String, DateTime> _lastNotificationTime = {};
  static const Duration notificationInterval = Duration(minutes: 5);

  List<Map<String, String>> notifications = [];
  int _currentIndex = 1;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _initializeApp() async {
    await _initializeNotifications();
    await requestNotificationPermissions();
    _monitorFirebase();
  }

  Future<void> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestPermission();
    }
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
      provisional: false,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification tapped: ${response.payload}");
        _handleNotificationTap(response.payload);
      },
    );

    // Request notification permission
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    DatabaseReference ref = FirebaseDatabase.instance.ref("FCMTokenDevice");

    await ref.set({
      "token": token,
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      if (message.notification != null) {
        _showNotification(
          message.notification!.title!,
          message.notification!.body!,
          notificationId: message.hashCode,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened: ${message.notification?.title}');
      // Handle the notification tap
      _handleNotificationTap(message.data['payload']);
    });
  }

  Future<bool> _shouldShowNotification(String sensorLabel) async {
    final now = DateTime.now();
    final lastTime = _lastNotificationTime[sensorLabel];

    if (lastTime == null || now.difference(lastTime) >= notificationInterval) {
      _lastNotificationTime[sensorLabel] = now;
      return true;
    }
    return false;
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      print("Handling notification tap with payload: $payload");
    }
  }

  void _monitorFirebase() {
    print("Starting Firebase monitoring...");
    _databaseRef.onValue.listen((event) async {
      try {
        print("Received Firebase data update");
        final data = event.snapshot.value;
        print("Raw data: $data");

        if (data == null) {
          print("No data received");
          return;
        }

        Map<dynamic, dynamic> sensorData;
        if (data is Map) {
          sensorData = data;
        } else {
          print("Invalid data format");
          return;
        }

        print("Processing sensor data: $sensorData");

        sensorData.forEach((sensor, value) async {
          try {
            if (value is! Map) {
              print("Invalid sensor data format for $sensor");
              return;
            }

            final percentage = value['Percentage'];
            if (percentage == null) {
              print("No percentage value for $sensor");
              return;
            }

            String sensorLabel;
            String emoji;
            switch (sensor.toString().toLowerCase()) {
              case 'sensor1':
                sensorLabel = 'Organik';
                emoji = '🥬';
                break;
              case 'sensor2':
                sensorLabel = 'Anorganik';
                emoji = '📦';
                break;
              case 'sensor3':
                sensorLabel = 'Plastik';
                emoji = '🥤';
                break;
              default:
                print("Unknown sensor: $sensor");
                return;
            }

            print("Sensor: $sensorLabel, Percentage: $percentage");

            if (percentage >= 70 && percentage <= 100) {
              if (await _shouldShowNotification(sensorLabel)) {
                await _handleHighCapacity(
                    sensorLabel, percentage, emoji, sensor);
              }
            } else if (percentage >= 0 && percentage <= 10) {
              if (await _shouldShowNotification(sensorLabel)) {
                await _handleLowCapacity(
                    sensorLabel, percentage, emoji, sensor);
              }
            }
          } catch (e) {
            print("Error processing sensor $sensor: $e");
          }
        });
      } catch (e, stackTrace) {
        print("Error in _monitorFirebase: $e");
        print("Stack trace: $stackTrace");
      }
    }, onError: (error) {
      print("Firebase listener error: $error");
    });
  }

  Future<void> _handleHighCapacity(
      String sensorLabel, num percentage, String emoji, dynamic sensor) async {
    print("Creating full capacity notification for $sensorLabel");
    final notification = {
      'title': 'Peringatan! Kapasitas Maksimal',
      'body':
          '$emoji Tempat Sampah $sensorLabel Penuh ($percentage%)! Harap Segera Dikosongkan!',
      'time': TimeOfDay.now().format(context),
    };

    if (mounted) {
      setState(() {
        notifications.insert(0, notification);
        _listKey.currentState
            ?.insertItem(0, duration: const Duration(milliseconds: 500));
      });
    }

    await _showNotification(
      notification['title']!,
      notification['body']!,
      notificationId: sensor.hashCode,
    );
  }

  Future<void> _handleLowCapacity(
      String sensorLabel, num percentage, String emoji, dynamic sensor) async {
    print("Creating low capacity notification for $sensorLabel");
    final notification = {
      'title': 'Informasi Kapasitas Kosong',
      'body':
          '$emoji Tempat Sampah $sensorLabel Tersedia ($percentage%) - Silakan Gunakan!',
      'time': TimeOfDay.now().format(context),
    };

    if (mounted) {
      setState(() {
        notifications.insert(0, notification);
        _listKey.currentState
            ?.insertItem(0, duration: const Duration(milliseconds: 500));
      });
    }

    await _showNotification(
      notification['title']!,
      notification['body']!,
      notificationId: sensor.hashCode,
    );
  }

  Future<void> _showNotification(String title, String body,
      {required int notificationId}) async {
    print("Showing notification - Title: $title, Body: $body");

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
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
      styleInformation: const BigTextStyleInformation(''),
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      channelShowBadge: true,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: 'notification_payload',
      );
      print("Notification shown successfully");
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                "Notifikasi akan muncul ketika sensor mendeteksi perubahan kapasitas.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : AnimatedList(
              key: _listKey,
              padding: const EdgeInsets.all(16),
              initialItemCount: notifications.length,
              itemBuilder: (context, index, animation) {
                final notification = notifications[index];
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuad,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: NotificationCard(
                      icon: Icons.notifications,
                      iconColor: notification['title']!.contains('Kosong')
                          ? Colors.green
                          : Colors.red,
                      iconBackground: notification['title']!.contains('Kosong')
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      title: notification['title']!,
                      subtitle: notification['body']!,
                      time: notification['time']!,
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.notifications_outlined, 'Notification', 1),
              _buildNavItem(Icons.person_outline, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _onTabTapped(index),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF4A6741) : Colors.grey,
            size: 28,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? const Color(0xFF4A6741) : Colors.grey,
          ),
        ),
      ],
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String time;

  const NotificationCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
