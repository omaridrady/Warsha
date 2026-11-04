import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:warsha/features/Auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          SizedBox(height: 100),
          ListTile(
            title: Text("Sign out"),
            trailing: Icon(Icons.logout),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove("uid");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => AuthBloc(),
                    child: LoginScreen(),
                  ),
                ),
                (rout) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
