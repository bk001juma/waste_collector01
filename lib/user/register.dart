// ignore_for_file: use_build_context_synchronously

import 'package:RecycleHub/services/authentication.dart';
import 'package:RecycleHub/user/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Call AuthService without role
      final user = await AuthService().signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: usernameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
      );

      if (user != null) {
        setState(() => isLoading = false);

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created successfully!")),
        );

        // Navigate to Login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create account. Please try again."),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      // Error handling
      String error = "An error occurred during sign-up. Please try again.";
      if (e is FirebaseAuthException) {
        error = e.message ?? error;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  InputDecoration _inputDecoration(String hintText, Icon icon) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: icon,
      filled: true,
      // ignore: deprecated_member_use
      fillColor: Colors.green.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // Prevent UI push-up
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Create your account",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 32),

                      // All your input fields
                      TextFormField(
                        controller: usernameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          "Username",
                          const Icon(Icons.person),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter a username'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: emailController,
                        decoration: _inputDecoration(
                          "Email",
                          const Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          return emailRegex.hasMatch(value)
                              ? null
                              : 'Please enter a valid email';
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: phoneController,
                        decoration: _inputDecoration(
                          "Phone Number",
                          const Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }

                          final tanzaniaPhoneRegExp = RegExp(
                            r'^(?:\+255|0)(6|7)[0-9]{8}$',
                          );

                          if (!tanzaniaPhoneRegExp.hasMatch(value)) {
                            return 'Enter a valid Tanzanian phone number';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: addressController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          "Address",
                          const Icon(Icons.location_on),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please enter an address'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.key),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          // ignore: deprecated_member_use
                          fillColor: Colors.green.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return value.length < 6
                              ? 'Password should be at least 6 characters'
                              : null;
                        },
                      ),
                      const SizedBox(height: 32),

                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  8,
                                  8,
                                  8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "SIGN UP",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      const TextSpan(
                        text: "Sign in",
                        style: TextStyle(
                          color: Color.fromARGB(255, 19, 228, 26),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
