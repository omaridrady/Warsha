import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController emailController;
  EmailTextField({super.key, required this.emailController});
  final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email is required";
        }
        if (!emailRegex.hasMatch(value)) {
          return "Please enter a valid email";
        }
        return null;
      },
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: "name@gmail.com",
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.mail_outline),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      controller: emailController,
    );
  }
}
