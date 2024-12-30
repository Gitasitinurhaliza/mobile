import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vantech/app_routes.dart';
import 'package:vantech/firebase_options.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService()
      .initialize(); // Initialize the notification service
  runApp(const HygieneHeroesApp());
}

class HygieneHeroesApp extends StatelessWidget {
  const HygieneHeroesApp({super.key});

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
