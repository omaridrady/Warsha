import 'package:flutter/material.dart';

class NameTextField extends StatelessWidget {
  final TextEditingController nameController;
  const NameTextField({super.key, required this.nameController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email is required";
        }
        return null;
      },
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: "Enter your name",
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.person_outline),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      controller: nameController,
    );
  }
}
