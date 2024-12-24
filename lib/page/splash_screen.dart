import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vantech/dasboard%20page/dashboard.dart'; // Path ke halaman Dashboard
import 'package:vantech/page/home_page.dart'; // Path ke HygieneHeroesHomePage

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Animasi scale untuk logo
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Navigasi ke halaman berikutnya setelah animasi selesai
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // Tunda selama durasi animasi
    await Future.delayed(const Duration(seconds: 3));

    // Periksa apakah pengguna sudah login
    if (FirebaseAuth.instance.currentUser != null) {
      // Jika pengguna sudah login, arahkan ke Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Jika pengguna belum login, arahkan ke halaman HygieneHeroesHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HygieneHeroesHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF557354), // Warna hijau sesuai logo
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.8), // Cahaya putih lembut
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Bayangan halus
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/png/logo.png', // Path ke logo aplikasi Anda
                width: 200,
                height: 200,
                fit: BoxFit.cover, // Mengisi area oval
              ),
            ),
          ),
        ),
      ),
    );
  }
}
