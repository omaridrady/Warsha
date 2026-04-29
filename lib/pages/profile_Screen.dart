import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/pages/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SizedBox(height: 100,),
        ListTile(
          title: Text("Sign out"),
          trailing: Icon(Icons.logout),
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.remove("uid");
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          },
        )
      ],),
    );
  }
}
