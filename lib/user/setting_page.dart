// ignore_for_file: use_build_context_synchronously

import 'package:RecycleHub/provider/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:RecycleHub/user/edit_profile.dart';
import 'package:RecycleHub/user/login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Account Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.edit,
            title: "Edit Profile",
            subtitle: "Change your personal info",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          const SizedBox(height: 15),
          _buildSettingCard(
            icon: Icons.lock,
            title: "Change Password",
            subtitle: "Update your account password",
            onTap: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(height: 15),
          _buildSettingCard(
            icon: Icons.dark_mode,
            title: "Dark Theme",
            subtitle: "Toggle app theme",
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(); 
              },
            ),
          ),
          const SizedBox(height: 15),
          _buildSettingCard(
            icon: Icons.delete_forever,
            title: "Delete Account",
            subtitle: "Permanently remove your account",
            iconColor: Colors.red,
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = Colors.green,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          // ignore: deprecated_member_use
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: newPassController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter new password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser
                    ?.updatePassword(newPassController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This action cannot be undone. Do you really want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                  await user.delete();
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete account: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
