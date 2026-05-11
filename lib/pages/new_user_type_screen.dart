import 'package:flutter/material.dart';
import 'package:warsha/pages/client_register_screen.dart';
import 'package:warsha/pages/technician_register_screen.dart';

class NewUserTypeScreen extends StatelessWidget {
  const NewUserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use extendBodyBehindAppBar if you have an app bar and want the image under it
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Background.png"),
            fit: BoxFit.cover,
          ),
        ),
        // 1. Use Center to put the white box in the middle
        child: Center(
          child: Container(
            // 2. Give the white box some horizontal breathing room
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Soft rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            // 3. Use MainAxisSize.min so the Column only takes the height it needs
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text(
                    "Client",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: const Text(
                    "Normal user who wants to post his warsha",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientRegisterScreen(),
                      ),
                    );
                  },
                ),
                const Divider(indent: 20, endIndent: 20), // Nice separator line
                ListTile(
                  leading: const Icon(Icons.build, color: Colors.orange),
                  title: const Text(
                    "Technician",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: const Text(
                    "Person who wants to provide services",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) =>  TechnicianRegisterScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
