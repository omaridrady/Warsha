import 'package:flutter/material.dart';
import 'package:warsha/features/Auth/presentation/screens/client_register_screen.dart';
import 'package:warsha/features/Auth/presentation/screens/technician_register_screen.dart';
import 'package:warsha/features/Auth/presentation/widget/new_user_type_button.dart';

class NewUserTypeScreen extends StatelessWidget {
  const NewUserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      // Use extendBodyBehindAppBar if you have an app bar and want the image under it
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NewUserTypeButton(isClient: true),
                  Divider(),
                  NewUserTypeButton(isClient: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
