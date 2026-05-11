import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/pages/login_screen.dart';
import 'package:warsha/pages/navigation_bar.dart';
import 'package:warsha/services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  clsUser? user;
  @override
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    // Start the timer and the data fetch
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNext();
    });
  }

  Future<void> _navigateToNext() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("uid");

    if (uid != null) {
      // 1. Await the user data properly
      clsUser? fetchedUser = await UserService.getUser(uid);

      if (fetchedUser != null) {
        // 2. Assign to the class variable and navigate
        if (!mounted) return; // Safety check for async navigation
        Navigator.pushReplacement( // Use pushReplacement so they can't go back to Splash
          context,
          MaterialPageRoute(builder: (context) => PagesNavigator(user: fetchedUser)),
        );
      } else {
        // If UID exists but user not found in DB, go to login
        _goToLogin();
      }
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/Background.png", fit: BoxFit.cover),
          ),
          SizedBox(child: Center(child: Image.asset("assets/warshaLogo.png"))),
        ],
      ),
    );
  }
}
