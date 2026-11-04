import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:warsha/features/Auth/presentation/widget/create_account_button.dart';
import 'package:warsha/features/Auth/presentation/widget/date_drop_list.dart';
import 'package:warsha/features/Auth/presentation/widget/email_text_field.dart';
import 'package:warsha/features/Auth/presentation/widget/name_text_field.dart';
import 'package:warsha/features/Auth/presentation/widget/password_text_field.dart';
import 'package:warsha/features/Auth/presentation/widget/phone_text_field.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/services/user_service.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime _date = DateTime.now();

  final ImagePicker picker = ImagePicker();

  XFile? pickedImage;
  String imgLink = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "WARSHA",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  // width: 300,
                  // height: 380,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create Account",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),

                          SizedBox(height: 20),
                          Text(
                            "FULL NAME",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 10),
                          NameTextField(nameController: _nameController),
                          SizedBox(height: 10),
                          Text(
                            "EMAIL ADDRESS",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 10),

                          //email field
                          EmailTextField(emailController: _emailController),
                          SizedBox(height: 10),
                          Text(
                            "PASSWORD",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 10),

                          //password field
                          PasswordTextField(
                            passwordController: _passwordController,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "PHONE",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 10),
                          PhoneTextField(phoneController: _phoneController),
                          SizedBox(height: 20),
                          Text(
                            "BIRTHDATE",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 10),
                          DateDropList(
                            onChange: (val) {
                              _date = val;
                            },
                          ),
                          SizedBox(height: 20),
                          CreateAccountButton(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            phoneController: _phoneController,
                            nameController: _nameController,
                            date: _date,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MAIN REGISTRATION HANDLER
  // Future<void> _handleRegister() async {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }
  //
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     // 1. CREATE FIREBASE AUTH USER
  //     UserCredential userData = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text,
  //     );
  //
  //     // 2. UPLOAD IMAGE IF PROVIDED
  //     if (pickedImage != null) {
  //       try {
  //         imgLink = await uplouadToCloudinary(pickedImage);
  //       } catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Image upload failed: $e'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //         // Continue without image
  //       }
  //     }
  //
  //     // 3. CREATE USER OBJECT
  //     clsUser newUser = clsUser(
  //       id: userData.user!.uid,
  //       name: _nameController.text.trim(),
  //
  //       phone: _phoneController.text.trim(),
  //       role: "Client",
  //       profileImage: imgLink.isNotEmpty ? imgLink : null,
  //
  //       createdAt: DateTime.now(),
  //       birthdate: DateTime.parse(_dateController.text),
  //
  //     );
  //
  //     // 4. SAVE TO FIRESTORE
  //     bool success = await UserService.addUser(newUser);
  //
  //     if (!success) {
  //       throw Exception('Failed to save user to database');
  //     }
  //
  //     // 5. SEND EMAIL VERIFICATION
  //     if (userData.user != null) {
  //       await userData.user!.sendEmailVerification();
  //     }
  //
  //     // 6. SHOW SUCCESS MESSAGE
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Account created! Check email to verify.'),
  //         backgroundColor: Colors.green,
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //
  //     // 7. NAVIGATE TO LOGIN
  //     Future.delayed(Duration(seconds: 1), () {
  //       Navigator.of(context).pushReplacementNamed('/login');
  //     });
  //
  //   } on FirebaseAuthException catch (e) {
  //     String errorMessage = 'Registration failed';
  //
  //     if (e.code == 'weak-password') {
  //       errorMessage = 'Password is too weak';
  //     } else if (e.code == 'email-already-in-use') {
  //       errorMessage = 'Email already registered';
  //     } else if (e.code == 'invalid-email') {
  //       errorMessage = 'Invalid email format';
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(errorMessage),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     print('Registration error: $e');
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // CLOUDINARY UPLOAD
  Future<String> uplouadToCloudinary(XFile? pickedImage) async {
    if (pickedImage == null) return "";

    File myImage = File(pickedImage.path);
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
      return decoded['secure_url'];
    } else {
      throw Exception(decoded['error']['message']);
    }
  }
}
