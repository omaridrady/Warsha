import 'package:flutter/material.dart';

class PhoneTextField extends StatelessWidget {
  final TextEditingController phoneController;
  PhoneTextField({super.key, required this.phoneController});
  final RegExp phoneReg = RegExp(r'^(07\d{8}|\+962\d{9})$');
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email is required";
        }
        if (!phoneReg.hasMatch(value.trim())) return "Invalid number";

        return null;
      },
      keyboardType: TextInputType.phone,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: "07XXXXXXXX",
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.phone_outlined),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      controller: phoneController,
    );
    ;
  }
}
