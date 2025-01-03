import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vantech/app_routes.dart';
import 'package:vantech/firebase_options.dart';
import 'package:vantech/service/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting("id_ID", null);
  await FirebaseMessaging.instance.requestPermission(provisional: true);
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  FirebaseMessaging.instance.subscribeToTopic("all_users");

  await NotificationService().init();
  runApp(const HygieneHeroesApp());
}

class HygieneHeroesApp extends StatefulWidget {
  const HygieneHeroesApp({super.key});

  @override
  State<HygieneHeroesApp> createState() => _HygieneHeroesAppState();
}

class _HygieneHeroesAppState extends State<HygieneHeroesApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hygiene Heroes',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashScreen,
      routes: AppRoutes.routes,
    );
  }
}
