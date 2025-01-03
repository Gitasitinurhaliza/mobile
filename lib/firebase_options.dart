// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Configuration for Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCc1nfbpZsN0WSVhA8h_1S4hYMQHl5I2Pw',
    appId: '1:87580194329:web:522019d58d296f1c71dc88',
    messagingSenderId: '87580194329',
    projectId: 'vangtech2024',
    authDomain: 'vangtech2024.firebaseapp.com',
    databaseURL:
        'https://vangtech2024-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'vangtech2024.firebasestorage.app',
    measurementId: 'G-KW511CYENH',
  );

  // Configuration for Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMvlrNvTO9lQold2--bpbCbPHICQrkrYM',
    appId: '1:87580194329:android:cc345288af2a79e771dc88',
    messagingSenderId: '87580194329',
    projectId: 'vangtech2024',
    databaseURL:
        'https://vangtech2024-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'vangtech2024.firebasestorage.app',
  );

  // Configuration for iOS (optional, if needed)
  static const FirebaseOptions iOS = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_IOS_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    databaseURL: 'YOUR_DATABASE_URL',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
