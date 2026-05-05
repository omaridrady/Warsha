import 'package:flutter/material.dart';
import 'package:warsha/pages/home_page.dart';
import 'package:warsha/pages/profile_Screen.dart';

import 'warshati_screen.dart';

class PagesNavigator extends StatefulWidget {
  PagesNavigator({super.key});

  @override
  State<PagesNavigator> createState() => _PagesNavigatorState();
}

class _PagesNavigatorState extends State<PagesNavigator> {
  @override

  int _selectedIndex = 0;
  final List<Widget> pages = [HomePage(), Warshati(), ProfileScreen()];
  final List<IconData> icons = [
    Icons.home,
    Icons.chat,
    
    Icons.person,
  ];
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],



      bottomNavigationBar: Container(
        margin: EdgeInsets.all(16),
    height: 70,
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
    BoxShadow(
    color: Colors.black12,
    blurRadius: 10,
    spreadRadius: 2,
    ),
    ],
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: List.generate(icons.length, (index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
    onTap: () {
    setState(() {
      _selectedIndex = index;
    });
    },
    child: AnimatedContainer(
    duration: Duration(milliseconds: 300),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: Colors.transparent,

    ),
    child: Icon(
    icons[index],
    size: 28,
    color: isSelected ? Colors.deepOrange : Colors.grey,
    ),
    ),
    );
    }),
    ),
    ),
    );
  }
}
