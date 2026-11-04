import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:warsha/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:warsha/features/Auth/presentation/bloc/auth_state.dart';
import 'package:warsha/features/Auth/presentation/widget/email_text_field.dart';
import 'package:warsha/features/Auth/presentation/widget/login_button.dart';
import 'package:warsha/features/Auth/presentation/widget/password_text_field.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_bloc.dart';
import 'package:warsha/features/Settings/Presentation/BloC/settings_event.dart';
import 'package:warsha/features/Ticket_List/presentation/bloc/ticket_list_bloc.dart';

import 'package:warsha/features/Auth/presentation/screens/forget_password.dart';

import 'package:warsha/features/Ticket_List/presentation/screens/navigation_bar.dart';

import 'package:warsha/features/Auth/presentation/screens/new_user_type_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Create a GlobalKey to identify the Form
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, current) =>
            prev.errorMessage != current.errorMessage ||
            current.isSuccess == true,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }

          if (state.isSuccess) {
            context.read<SettingsBloc>().add(
              GetUserData(userId: state.userId!),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => TicketListBloc(),
                  child: PagesNavigator(),
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.black,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Icon(Icons.handyman, color: Colors.white, size: 30),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "WARSHA",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 35),
                ),
                SizedBox(height: 30),
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
                              "Log-In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                              ),
                            ),
                            SizedBox(height: 20),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "PASSWORD",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider(
                                          create: (context) => AuthBloc(),
                                          child: ForgetPassword(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),

                            //password field
                            PasswordTextField(
                              passwordController: _passwordController,
                            ),
                            SizedBox(height: 20),
                            LoginButton(
                              formKey: _formKey,
                              emailController: _emailController,
                              passwordController: _passwordController,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewUserTypeScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign up for free",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
