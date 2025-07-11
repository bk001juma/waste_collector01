// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  void _loadUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _usernameController.text = doc['username'] ?? '';
        _phoneController.text = doc['phone'] ?? '';
        _addressController.text = doc['address'] ?? '';
      });
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'username': _usernameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Update your personal details',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _updateProfile,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
