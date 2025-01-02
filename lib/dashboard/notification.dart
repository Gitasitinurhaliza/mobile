import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Notifications');
    ref.onValue.listen((DatabaseEvent event) {
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

      setState(() {
        notifications = mappedData;
      });
    });
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
                      time: notification['timestamp'].toString(),
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
