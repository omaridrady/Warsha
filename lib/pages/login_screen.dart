import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warsha/modules/clsUser.dart';
import 'package:warsha/pages/forget_password.dart';
import 'package:warsha/pages/home_page.dart';
import 'package:warsha/pages/navigation_bar.dart';
import 'package:warsha/pages/client_register_screen.dart';
import 'package:warsha/pages/new_user_type_screen.dart';
import 'package:warsha/pages/todo_Screen.dart';
import 'package:warsha/services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Create a GlobalKey to identify the Form
  final _formKey = GlobalKey<FormState>();

  // 2. Regex Patterns
  // Simple Email Regex
  final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isClient = true;
  // Loading state
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login with proper error handling
  Future<void> _handleLogin() async {
    // 4. Trigger validation
    if (!_formKey.currentState!.validate()) {
      return; // Form validation failed
    }

    // Don't allow multiple login attempts
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Sign in with Firebase
      final userData = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user exists and email is verified
      if (userData.user != null) {
        if (userData.user!.emailVerified) {
          // Save user ID to SharedPreferences
          final SharedPreferences prefs =
          await SharedPreferences.getInstance();
          prefs.clear();
          await prefs.setString("uid", userData.user!.uid);

          // Navigate to home page
          if (mounted) {
            clsUser? user = await UserService.getUser(userData.user!.uid);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PagesNavigator(user: user),
              ),
            );
          }
        } else {
          // Email not verified
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please verify your email first"),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errorsr
      String errorMessage = "An error occurred";

      if (e.code == 'user-not-found') {
        errorMessage = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many login attempts. Please try again later";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "Network error. Please check your internet connection";
      } else {
        errorMessage = e.message ?? "Login failed";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred: $e"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Logo or Title
                    Text(
                      "Warsha",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        } else if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        // Remove strict password validation - let Firebase handle it
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Forget Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgetPassword(),
                            ),
                          );
                        },
                        child: Text("Forgot Password?"),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewUserTypeScreen(),
                              ),
                            );
                          },
                          child: Text("Create one now"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}