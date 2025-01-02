import 'package:flutter/material.dart';
import 'package:vantech/dashboard/dashboard.dart';
import 'package:vantech/dashboard/notification.dart';
import 'package:vantech/page/forgotpass.dart';
import 'package:vantech/page/home_page.dart';
import 'package:vantech/page/signinpage.dart';
import 'package:vantech/page/signuppage.dart';
import 'package:vantech/profil/editpage.dart';
import 'package:vantech/profil/profil.dart';
import 'package:vantech/page/splash_screen.dart';

/// Manages all application routes and navigation logic.
class AppRoutes {
  // Route names (constants for easy reuse)
  static const String splashScreen = '/splash_screen';
  static const String welcomePage = '/welcome_page';
  static const String loginScreen = '/login_screen';
  static const String registerScreen = '/register_screen';
  static const String dashboardScreen = '/dashboard_screen';
  static const String forgetPasswordScreen = '/forget_password_screen';
  static const String profileScreen = '/profile_screen';
  static const String editProfileScreen = '/edit_profile_screen';
  static const String notificationPage = '/notifications';

  /// Map of route names to widget builders.
  static final Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    welcomePage: (context) => const HygieneHeroesHomePage(),
    loginScreen: (context) => const SignInPage(),
    registerScreen: (context) => const SignUpPage(),
    dashboardScreen: (context) => const HomePage(),
    forgetPasswordScreen: (context) => const ForgotPasswordScreen(),
    profileScreen: (context) => const ProfilePage(),
    editProfileScreen: (context) => const EditProfilePage(),
    notificationPage: (context) => const NotificationPage(),
  };

  /// Navigates to the login screen, clearing all previous routes.
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      loginScreen,
      (route) => false,
    );
  }

  /// Navigates to a specified screen with optional arguments.
  static void navigateTo(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Navigates back to the previous screen.
  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Replaces the current screen with a specified screen.
  static void replaceWith(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
}
