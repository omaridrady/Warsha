import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController passwordController;

  PasswordTextField({super.key, required this.passwordController});

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscure = true;
  final RegExp passRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
  @override
  Widget build(BuildContext context) {


    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password is required";
        }
        if (!passRegex.hasMatch(value)) {
          return "Please enter a valid password";
        }

        return null;
      },
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: "********",
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
          icon: Icon(
            _isObscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      obscureText: _isObscure,
      controller: widget.passwordController,
    );
  }
}
