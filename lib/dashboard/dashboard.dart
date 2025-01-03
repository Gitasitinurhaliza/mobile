import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vantech/dashboard/informationpage.dart';
import 'package:vantech/dashboard/notification.dart';
import 'package:vantech/profil/customprofile.dart';
import 'package:vantech/profil/profil.dart';
// import 'package:vantech/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // final NotificationService _notificationService = NotificationService();
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("UltrasonicData");
  final Map<String, DateTime> _lastNotificationTime = {};

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late StreamSubscription fireauth;
  String _userName = 'User';
  int _currentIndex = 0;

  final widgets = [];

  @override
  void initState() {
    super.initState();
    _initializeController();

    fireauth = FirebaseAuth.instance.userChanges().listen((User? user) {
      print('update');
      _fetchUserProfile();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeServices();
      _lastNotificationTime.clear(); // Reset notification timers
    });
  }

  void _initializeController() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  Future<void> _initializeServices() async {
    try {
      print('Initializing services...');
      // await _notificationService.initialize();
      await _fetchUserProfile();
      print('Services initialized successfully');
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  Map<String, String>? _getSensorInfo(String sensor) {
    switch (sensor.toLowerCase()) {
      case 'sensor1':
        return {'label': 'Organik', 'emoji': '🥬'};
      case 'sensor2':
        return {'label': 'Anorganik', 'emoji': '📦'};
      case 'sensor3':
        return {'label': 'Plastik', 'emoji': '🥤'};
      default:
        return null;
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _userName = user.displayName ?? 'User';
        });

        final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
        final snapshot = await userRef.get();

        if (snapshot.exists && mounted) {
          setState(() {
            _userName = snapshot.child('name').value as String? ?? 'User';
          });
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    fireauth.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        setState(() {
          _currentIndex = 0;
        });
      },
      child: Scaffold(
        appBar: _currentIndex == 1
            ? AppBar(
                automaticallyImplyLeading: false,
                title: _currentIndex == 1
                    ? const Text('Notifikasi')
                    : const Text('Profile'))
            : null,
        backgroundColor: const Color(0xFFE5E5E5),
        body: Column(
          children: [
            if (_currentIndex == 0)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          _buildProfileHeader(),
                          const SizedBox(height: 24),
                          _buildCapacityCard(),
                          const SizedBox(height: 24),
                          _buildInteractionSection(),
                          const SizedBox(height: 16),
                          _buildInfoCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentIndex == 1) const NotificationPage(),
            if (_currentIndex == 2) const ProfilePage(),
            _buildBottomNavigationBar((index) {
              setState(() {
                _currentIndex = index;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _currentIndex = 2;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD3D3C3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  'Hi, $_userName!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.person, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A6741),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Waste Capacity Mastery',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder(
            stream: _databaseRef.onValue,
            builder: _buildCapacityContent,
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityContent(
      BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
      return const Center(
        child: Text(
          "No data available",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final data = Map<String, dynamic>.from(
      snapshot.data!.snapshot.value as Map<dynamic, dynamic>,
    );

    final Map<String, String> sensorLabels = {
      'Sensor1': 'Organik',
      'Sensor2': 'Anorganik',
      'Sensor3': 'Botol Plastik',
    };

    final summary = sensorLabels.entries
        .map((entry) => {
              'label': entry.value,
              'value': data[entry.key]?['Percentage'] ?? 0,
            })
        .toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: summary
          .map((row) => CircularProgressWithLabel(
                label: row['label'].toString(),
                percentage: row['value'] as int,
                color: const Color(0xFF8B4513),
              ))
          .toList(),
    );
  }

  Widget _buildInteractionSection() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 16),
        children: [
          TextSpan(
            text: 'Interact With Your\n',
            style: TextStyle(color: Colors.black87),
          ),
          TextSpan(
            text: 'Cleaning Mastery!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD3D3C3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InformationPage()),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/png/reading.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mengelola Sampah di Kampus:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Strategi Efektif untuk Lingkungan Bersih dan Sehat',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Yuk Simak',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(Function(int) onTap) {
    return Container(
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
            _buildNavItem(
                Icons.home_filled, 'Home', const HomePage(), 0, onTap),
            _buildNavItem(Icons.notifications_outlined, 'Notification',
                const NotificationPage(), 1, onTap),
            _buildNavItem(
                Icons.person_outline, 'Profile', const ProfilePage(), 2, onTap),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Widget page, int index,
      Function(int) onTap) {
    final isSelected = _currentIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => onTap(index),
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
}

class CircularProgressWithLabel extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;

  const CircularProgressWithLabel({
    super.key,
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 10,
                ),
              ),
              Center(
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
