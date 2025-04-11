// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:collector/services/authentication.dart';
import 'package:collector/user/login.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 0, right: 0, child: _buildTopDecoration()),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                // Added this to prevent overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Create Account", style: _titleStyle()),
                    SizedBox(height: 32),
                    _buildTextField(
                      "Username",
                      Icons.person,
                      controller: usernameController,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      "Email",
                      Icons.email,
                      controller: emailController,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      "Phone Number",
                      Icons.phone,
                      controller: phoneController,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      "Address",
                      Icons.location_on,
                      controller: addressController,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      "Password",
                      Icons.lock,
                      isPassword: true,
                      controller: passwordController,
                    ),
                    SizedBox(height: 32),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _buildButton("SIGN UP", () async {
                          if (usernameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              phoneController.text.isEmpty ||
                              addressController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please fill in all fields"),
                              ),
                            );
                            return;
                          }

                          // Validate email format
                          if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$",
                          ).hasMatch(emailController.text.trim())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please enter a valid email"),
                              ),
                            );
                            return;
                          }

                          // Validate password length
                          if (passwordController.text.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Password must be at least 6 characters",
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          // Set a timeout of 15 seconds for the signup process
                          try {
                            final user = await Future.any([
                              AuthService().signUpWithEmail(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                username: usernameController.text.trim(),
                                phone: phoneController.text.trim(),
                                address: addressController.text.trim(),
                              ),
                              Future.delayed(
                                Duration(seconds: 15),
                                () => throw "Signup timed out",
                              ),
                            ]);

                            setState(() {
                              isLoading = false;
                            });

                            if (user != null) {
                              Navigator.pushReplacement(
                                // ignore: duplicate_ignore
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            } else {
                              // ignore: duplicate_ignore
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Signup failed")),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });

                            if (e.toString().contains('email-already-in-use')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Email is already in use"),
                                ),
                              );
                            } else if (e == "Signup timed out") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Signup timed out, please try again",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Signup error: $e")),
                              );
                            }
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _bottomText(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Widget _buildTopDecoration() {
    return Container(
      width: 110,
      height: 100,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 19, 228, 26),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
      ),
    );
  }

  Widget _bottomText(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        child: Text(
          "Already have an account? Sign in",
          style: TextStyle(
            color: const Color.fromARGB(255, 19, 228, 26),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  TextStyle _titleStyle() {
    return TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  }
}
