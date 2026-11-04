import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTapChange;
  final bool isClient;
  CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTapChange,
    required this.isClient,
  });

  @override
  Widget build(BuildContext context) {
    final List<_NavItem> items = [
      _NavItem(icon: Icons.home, label: "Home"),
      _NavItem(
        icon: Icons.confirmation_num,
        label: isClient ? "Tickets" : "Jobs",
      ),
      _NavItem(icon: Icons.person_rounded, label: "Profile"),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 0,left: 10,right: 10,bottom: 20),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),

          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final _NavItem item = items[index];
              final bool isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => onTapChange(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? Color(0xFF0056C6) : Colors.grey,
                    ),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? Color(0xFF0056C6) : Colors.grey,
                      ),
                    ),
                    // AnimatedContainer(
                    //   duration: const Duration(milliseconds: 200),
                    //   height: 4,
                    //   decoration: const BoxDecoration(
                    //     color: Color(0xFF0056C6),
                    //     shape: BoxShape.circle,
                    //   ),
                    // ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
