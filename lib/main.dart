import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // Import firebase_options.dart
import 'package:vantech/app_routes.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inisialisasi Firebase saat aplikasi berjalan di background atau terminated
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling a background message: ${message.messageId}");
  // Logika untuk notifikasi atau pembaruan UI jika diperlukan
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup background message handler untuk Firebase
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Mendapatkan permission untuk notifikasi (terutama di iOS)
  await FirebaseMessaging.instance.requestPermission();

  // Mendapatkan token untuk perangkat
  String? token = await FirebaseMessaging.instance.getToken();
  print("Firebase Messaging Token: $token");

  // Menangani pesan notifikasi di foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a foreground message: ${message.messageId}');
    // Anda bisa menambahkan logika untuk menampilkan notifikasi lokal
  });

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
