import 'package:collector/services/authentication.dart';
import 'package:collector/user/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Input validation
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Please fill in both fields.";
      });
      return;
    }

    bool isEmailValid = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    ).hasMatch(email);
    if (!isEmailValid) {
      setState(() {
        errorMessage = "Please enter a valid email address.";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorMessage = "Password must be at least 6 characters long.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = await AuthService().signInWithEmail(email, password);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if (user != null) {
        emailController.clear();
        passwordController.clear();

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => HomePage(uid: user.uid)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          switch (e.code) {
            case 'user-not-found':
              errorMessage = "No account found with this email.";
              break;
            case 'wrong-password':
              errorMessage = "Incorrect password.";
              break;
            case 'too-many-requests':
              errorMessage = "Too many login attempts. Try again later.";
              break;
            case 'network-request-failed':
              errorMessage = "Network error. Check your internet connection.";
              break;
            default:
              errorMessage = e.message ?? "Login failed. Please try again.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "An unexpected error occurred.";
        });
      }
    }
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Login", style: _titleStyle()),
                    SizedBox(height: 8),
                    Text("Please sign in to continue."),
                    SizedBox(height: 32),
                    _buildTextField(
                      "Email",
                      Icons.email,
                      controller: emailController,
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
                        : _buildButton("LOGIN", _handleLogin),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
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
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
                : null,
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
            MaterialPageRoute(builder: (context) => SignupScreen()),
          );
        },
        child: Text(
          "Don't have an account? Sign up",
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
