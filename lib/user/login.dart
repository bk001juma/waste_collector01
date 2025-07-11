// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:RecycleHub/admin/admin.dart';
import 'package:RecycleHub/services/authentication.dart';
import 'package:RecycleHub/user/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'package:logging/logging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool _obscurePassword = true;
  bool rememberMe = false;

  final Logger _logger = Logger('LoginScreen');

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      final role = prefs.getString('role');
      final uid = prefs.getString('uid');
      if (role != null && uid != null) {
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminApp(uid: uid)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(uid: uid)),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = await AuthService().signInWithEmail(email, password);

      if (mounted) setState(() => isLoading = false);

      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          final role = userDoc['role'];
          emailController.clear();
          passwordController.clear();

          if (rememberMe) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('role', role);
            await prefs.setString('uid', user.uid);
          }

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminApp(uid: user.uid)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(uid: user.uid)),
            );
          }
        } else {
          await AuthService().signOut();
          throw FirebaseAuthException(
            code: 'user-not-allowed',
            message: 'Email or password is incorrect.',
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = _getErrorMessage(e);
      });
      _logger.warning("FirebaseAuthException caught: ${e.code} - ${e.message}");
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "An unexpected error occurred.";
      });
      _logger.severe("Unexpected error: $e");
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No account found with this email.";
      case 'wrong-password':
        return "Incorrect password or email.";
      case 'too-many-requests':
        return "Too many login attempts. Try again later.";
      case 'network-request-failed':
        return "Network error. Check your internet connection.";
      default:
        return e.message ?? "Login failed. Please try again.";
    }
  }

  Widget _buildTextFormField(
    String hintText,
    IconData icon, {
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return Center(
      child: SizedBox(
        width: 350,
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.green.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(icon),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                    : null,
          ),
          validator: (value) {
            final input = value?.trim() ?? '';
            if (input.isEmpty) {
              return 'Please enter your ${hintText.toLowerCase()}';
            }
            if (hintText.toLowerCase() == "email") {
              bool isEmailValid = RegExp(
                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
                r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
                r"(?:\.[a-zA-Z]{2,})+$",
              ).hasMatch(input);
              if (!isEmailValid) return 'Please enter a valid email address';
            }
            if (hintText.toLowerCase() == "password" && input.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 350,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: const Color.fromARGB(255, 6, 6, 6),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _bottomText(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      },
      child: RichText(
        text: const TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: "Sign up",
              style: TextStyle(
                color: Color.fromARGB(255, 19, 228, 26),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Please login to your account",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      _buildTextFormField(
                        "Email",
                        Icons.email,
                        controller: emailController,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        "Password",
                        Icons.lock,
                        isPassword: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text("Remember Me"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      isLoading
                          ? const CircularProgressIndicator()
                          : _buildGradientButton("LOGIN", _handleLogin),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 24),
                      _bottomText(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
