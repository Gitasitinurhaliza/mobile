import 'package:flutter/material.dart';
import 'package:vantech/page/home_page.dart';
import 'package:vantech/page/signinpage.dart';
import 'package:vantech/page/signuppage.dart';
import 'package:vantech/dasboard%20page/dashboard.dart';
import 'package:vantech/page/forgotpass.dart';
import 'package:vantech/profil/profil.dart';
import 'package:vantech/profil/editpage.dart';
import 'package:vantech/page/splash_screen.dart'; // Import SplashScreen

class AppRoutes {
  static const String splashScreen =
      '/splash_screen'; // Route untuk SplashScreen
  static const String welcomePage = '/welcome_page';
  static const String loginScreen =
      '/login_screen'; // Route untuk halaman login
  static const String registerScreen = '/register_screen';
  static const String dashboardScreen = '/dashboard_screen';
  static const String forgetPasswordScreen = '/forget_password_screen';
  static const String profileScreen = '/profile_screen';
  static const String editProfileScreen = '/edit_profile_screen';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    welcomePage: (context) => const HygieneHeroesHomePage(),
    loginScreen: (context) => const SignInPage(), // Halaman login
    registerScreen: (context) => const SignUpPage(),
    dashboardScreen: (context) => const HomePage(),
    forgetPasswordScreen: (context) => const ForgotPasswordScreen(),
    profileScreen: (context) => const ProfilePage(),
    editProfileScreen: (context) => const EditProfilePage(),
  };

  // Navigasi ke halaman login setelah logout
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      loginScreen,
      (route) => false, // Menghapus semua rute sebelumnya
    );
  }
}
