import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/pages/home_page.dart';
import 'package:warsha/pages/profile_Screen.dart';
import 'package:warsha/pages/tech_profile_screen.dart';
import 'package:warsha/pages/technician_home_page.dart';
import 'package:warsha/pages/warshati_screen.dart';

class PagesNavigator extends StatefulWidget {
  final clsUser? user;
  PagesNavigator({super.key, this.user});

  @override
  State<PagesNavigator> createState() => _PagesNavigatorState();
}
class _PagesNavigatorState extends State<PagesNavigator> {
  int _selectedIndex = 0;

  // 1. Declare the lists without initializing them here
  late List<Widget> clientPages;
  late List<Widget> technicianPages;

  @override
  void initState() {
    super.initState();

    // 2. Initialize them here where 'widget.user' is accessible
    clientPages = [
      const HomePage(),
      Warshati(user: widget.user,),
      const ProfileScreen()
    ];

    technicianPages = [
      const TechnicianHomePage(),
      Warshati(user: widget.user), // No error now!
      TechProfileScreen(user: widget.user!)
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // 3. Use a local variable to decide which list to use for cleaner code
      body: widget.user!.role == "Client"
          ? clientPages[_selectedIndex]
          : technicianPages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          child: GNav(
            selectedIndex: _selectedIndex, // Good practice to keep this synced
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            color: Colors.black,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.orange.shade600,
            tabs: const [
              GButton(icon: Icons.home, gap: 10, text: "Home", padding: EdgeInsets.all(16)),
              GButton(icon: Icons.table_restaurant_outlined, gap: 10, text: "Warshati"),
              GButton(icon: Icons.person, gap: 10, text: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}
