import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/pages/login_screen.dart';
import 'package:warsha/pages/navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'package:warsha/services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Create a GlobalKey to identify the Form
  final _formKey = GlobalKey<FormState>();

  // 2. Regex Patterns
  // Simple Email Regex
  final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  // Password Regex: Min 8 chars, at least 1 letter and 1 number
  final RegExp passRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  XFile? pickedImage;
  String imgLink = "";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: Form(
          key: _formKey, // 3. Assign the key to the Form
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                pickedImage == null
                    ? Container(
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: 150,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.camera_alt),
                                        title: Text("Camera"),
                                        onTap: () async {
                                          pickedImage = await picker.pickImage(
                                            source: ImageSource.camera,
                                          );
                                          setState(() {});
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.photo),
                                        title: Text("Gallery"),
                                        onTap: () async {
                                          pickedImage = await picker.pickImage(
                                            source: ImageSource.gallery,
                                          );
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.photo, size: 50),
                        ),
                      )
                    : Image.file(File(pickedImage!.path)),
                const SizedBox(height: 30),

                _myTextField(_nameController, "Name", Icons.person),

                const SizedBox(height: 20),

                // Email Field
                _myTextField(_emailController, "Email", Icons.mail),
                const SizedBox(height: 20),

                // Password Field
                _myTextField(_passwordController, "Password", Icons.lock),

                const SizedBox(height: 30),
                _myTextField(_phoneController, "Phone", Icons.phone),
                const SizedBox(height: 30),
                TextField(
                  controller: _dateController,
                  readOnly: true, // Prevents keyboard from opening
                  decoration: InputDecoration(
                    labelText: "Birthdate",
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFFF5A00),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFFF5A00),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                ),

                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        UserCredential? userData;
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        try {
                          userData = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                          prefs.setString("uid", userData.user!.uid);
                          if (pickedImage != null) {
                            imgLink = await uplouadToCloudinary(pickedImage);
                          }

                          clsUser newUser = clsUser(
                            id: prefs.getString("uid"),
                            name: _nameController.text,
                            phone: _phoneController.text,
                            role: "Client",
                            birthdate: DateTime.parse(_dateController.text),
                            profileImage: imgLink,
                            createdAt: DateTime.now(),
                          );

                          UserService.addUser(newUser);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "The password provided is too weak.",
                                ),
                              ),
                            );
                          } else if (e.code == 'email-already-in-use') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "The account already exists for that email.",
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          print(e);
                        } finally {
                          _emailController.clear();
                          _passwordController.clear();
                        }

                        if (userData!.user != null) {
                          /// todo: add the user full name to the database later
                          userData.user!.sendEmailVerification();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        }
                      }
                    },
                    child: Text("Create Account"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> uplouadToCloudinary(XFile? pickedImage) async {
    File myImage = File(pickedImage!.path);
    String cloudName = "dkepqbmf9";
    String preset = "uplorder";

    final request = http.MultipartRequest(
      "POST",
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    );

    request.fields["upload_preset"] = preset;
    request.files.add(await http.MultipartFile.fromPath('file', myImage.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final decoded = json.decode(responseBody);
    if (response.statusCode == 200) {
      print('url = ${decoded['secure_url']}');
      return decoded['secure_url'];
    } else {
      throw Exception(decoded['error']['message']);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Earliest year allowed
      lastDate: DateTime(2100), // Latest year allowed
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF5A00), // Using your brand orange
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formats date to: 2026-05-05
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}

Widget _myTextField(
  TextEditingController contorller,
  String label,
  IconData icon,
) {
  return TextFormField(
    controller: contorller,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      prefixIcon: Icon(icon),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Please enter your ${label}";
      }
      return null;
    },
  );
}
