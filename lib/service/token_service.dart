// Buat file baru: lib/services/token_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class TokenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _rtdbRef =
      FirebaseDatabase.instance.ref("FCMTokenDevice");
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> getAndSaveToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await saveToken(token);
      }
      return token;
    } catch (e) {
      print('Error getting/saving token: $e');
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      // Save to Realtime Database
      await _rtdbRef.set({"token": token});

      // Save to Firestore with additional metadata
      await _firestore.collection('device_tokens').doc(token).set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'isValid': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'deviceInfo': {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
          'model': Platform.isAndroid ? 'Android Device' : 'iOS Device',
        },
        'appInfo': {
          'version': '1.0.0', // Sesuaikan dengan versi app Anda
          'buildNumber': '1', // Sesuaikan dengan build number app Anda
        }
      }, SetOptions(merge: true));

      print('Token saved successfully: $token');
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  Future<void> invalidateToken(String token) async {
    try {
      await _firestore.collection('device_tokens').doc(token).update({
        'isValid': false,
        'invalidatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error invalidating token: $e');
    }
  }

  Stream<QuerySnapshot> getValidTokensStream() {
    return _firestore
        .collection('device_tokens')
        .where('isValid', isEqualTo: true)
        .snapshots();
  }
}
