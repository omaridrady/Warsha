import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

clsUser? currentUser;

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[600],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
        child: Column(
          children: [
            currentUser == null
                ? CircularProgressIndicator()
                : Text(
                    "Hi, ${currentUser!.name}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> getCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = await UserService.getUser(prefs.getString("uid")!);
    setState(()  {
      currentUser = user;
    });
  }
}
