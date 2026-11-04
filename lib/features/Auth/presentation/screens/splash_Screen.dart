import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_bloc.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_event.dart';
import 'package:warsha/features/Ticket/Presentation/bloc/ticket_bloc.dart';
import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_bloc.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/features/Auth/presentation/screens/login_screen.dart';
import 'package:warsha/features/Ticket_List/presentation/screens/navigation_bar.dart';
import 'package:warsha/services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    // Kick off initialization immediately at startup
    _initializeAppLifecycle();
  }

  Future<void> _initializeAppLifecycle() async {
    // 💡 Record the timestamp when the splash screen loaded
    final startTime = DateTime.now();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("uid");

      if (uid != null) {
        context.read<SettingsBloc>().add(GetUserData(userId: uid));

        // 💡 Calculate how much time is left for our minimum 3-second visual requirement
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        final remainingTime = 3000 - elapsed;
        if (remainingTime > 0) {
          await Future.delayed(Duration(milliseconds: remainingTime));
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => TicketListBloc(),
              child: PagesNavigator(),
            ),
          ),
        );
        return;
      }
    } catch (e) {
      print("Error loading initial user session: $e");
    }

    // 💡 If anything fails or there's no cached session, ensure we meet the 3s rule before login
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 3000 && mounted) {
      await Future.delayed(Duration(milliseconds: 3000 - elapsed));
    }
    _goToLogin();
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BlocProvider(create: (context) => AuthBloc(), child: LoginScreen()),
      ),
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
          Center(child: Image.asset("assets/warshaLogo.png")),
        ],
      ),
    );
  }
}
