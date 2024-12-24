import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vantech/dasboard%20page/informationpage.dart';
import 'package:vantech/dasboard%20page/notification.dart';
import 'package:vantech/profil/profil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _userName = 'User';
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _userName =
              user.displayName ?? 'User'; // Display name from Firebase Auth
        });
      }
      if (user == null) {
        print('No user logged in');
        return;
      }
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        setState(() {
          _userName = snapshot.child('name').value as String? ?? 'User';
        });
      } else {
        print('User profile not found in Realtime Database');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: Column(
        children: [
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
                      // Welcome Row
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end, // Elemen rata kanan
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfilePage()),
                              );
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
                      ),
                      const SizedBox(height: 24),
                      // Waste Capacity Card
                      Container(
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
                              stream: FirebaseDatabase.instance
                                  .ref('UltrasonicData')
                                  .onValue,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                }

                                if (snapshot.hasData &&
                                    snapshot.data!.snapshot.value != null) {
                                  final data = Map<String, dynamic>.from(
                                    (snapshot.data! as DatabaseEvent)
                                        .snapshot
                                        .value as Map<dynamic, dynamic>,
                                  );

                                  // Peta untuk mengganti label sensor
                                  final Map<String, String> sensorLabels = {
                                    'Sensor1': 'Organik',
                                    'Sensor2': 'Anorganik',
                                    'Sensor3': 'Plastik',
                                  };

                                  final summary = [
                                    {
                                      'label':
                                          sensorLabels['Sensor1'] ?? 'Sensor1',
                                      'value':
                                          data['Sensor1']['Percentage'] ?? 0,
                                    },
                                    {
                                      'label':
                                          sensorLabels['Sensor2'] ?? 'Sensor2',
                                      'value':
                                          data['Sensor2']['Percentage'] ?? 0,
                                    },
                                    {
                                      'label':
                                          sensorLabels['Sensor3'] ?? 'Sensor3',
                                      'value':
                                          data['Sensor3']['Percentage'] ?? 0,
                                    },
                                  ];

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: summary.map((row) {
                                      return CircularProgressWithLabel(
                                        label: row['label'].toString(),
                                        percentage: row['value'] as int,
                                        color: const Color(0xFF8B4513),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return const Center(
                                    child: Text(
                                      "No data available",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Interaction Section
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 16),
                          children: [
                            TextSpan(
                              text: 'Interact With Your\n',
                              style: TextStyle(
                                color: Colors.black87,
                              ),
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
                      ),
                      const SizedBox(height: 16),
                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3D3C3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InformationPage(),
                              ),
                            );
                          },
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom Navigation Bar
          Container(
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                        child: const Icon(Icons.home_filled,
                            color: Color(0xFF4A6741), size: 28),
                      ),
                      const SizedBox(height: 4), // Jarak antara ikon dan teks
                      const Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A6741),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationPage(),
                            ),
                          );
                        },
                        child: const Icon(Icons.notifications_outlined,
                            color: Colors.grey, size: 28),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Notification',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                        child: const Icon(Icons.person_outline,
                            color: Colors.grey, size: 28),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
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
