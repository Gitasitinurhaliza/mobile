import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vantech/components/notification_card.dart';
import 'package:vantech/dashboard/dashboard.dart';
import 'package:vantech/profil/profil.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var notifications = [];
  int _currentIndex = 1;
  late StreamSubscription<DatabaseEvent> _notificationsSubscription;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String convertToDate(int timestamp) {
    if (timestamp.toString().length == 10) {
      timestamp *= 1000;
    }

    // Konversi ke DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Format tanggal
    String formattedDate =
        DateFormat("d MMMM yyyy - HH:mm", "id_ID").format(dateTime);
    return formattedDate;
  }

  void fetchData() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Notifications');

    _notificationsSubscription =
        ref.orderByChild('timestamp').onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<Object?, Object?>;

      final mappedData = data.entries.map((entry) {
        final value = entry.value as Map<Object?, Object?>;
        return {
          'id': entry.key.toString(),
          'body': value['body'].toString(),
          'title': value['title'].toString(),
          'timestamp': value['timestamp'] as int,
        };
      }).toList();

      mappedData.sort((a, b) => (b['timestamp'] as int)
          .compareTo(a['timestamp'] as int)); // Descending (terbaru ke terlama)

      setState(() {
        notifications = mappedData;
      });
    });
  }

  @override
  void dispose() {
    // Membatalkan subscription ketika widget dihancurkan
    _notificationsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: notifications.isEmpty
          ? const Center(
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
                      iconColor: notification['body'].contains('Gunakan')
                          ? Colors.green
                          : notification['body'].contains('Hampir')
                              ? Colors.orange
                              : Colors.red,
                      iconBackground: notification['body'].contains('Gunakan')
                          ? Colors.green.withOpacity(0.1)
                          : notification['body'].contains('Hampir')
                              ? Colors.orange.withOpacity(.1)
                              : Colors.red.withOpacity(0.1),
                      title: notification['title']!,
                      subtitle: notification['body']!,
                      time: convertToDate(notification['timestamp']),
                    ),
                  ),
                );
              },
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
