import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  // 1. Define the variables the widget will receive
  final TextEditingController controller;
  final String label;
  final IconData icon;

  // 2. Create the Constructor to initialize these variables
  const MyTextfield( {
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // 3. Return the widget normally using 'this.controller', etc.
    return TextFormField(

      controller: controller,
      decoration: InputDecoration(

        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your $label";
        }
        return null;
      },
    );
  }
}