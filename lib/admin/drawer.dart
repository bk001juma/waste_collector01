import 'package:RecycleHub/admin/admin.dart';
import 'package:RecycleHub/admin/educational_content.dart';
import 'package:RecycleHub/admin/repuest_pickup.dart';
import 'package:RecycleHub/user/login.dart';
import 'package:RecycleHub/user/menu.dart';
import 'package:RecycleHub/user/recycling_center.dart';
import 'package:RecycleHub/user/setting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key, required String uid});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  String _username = 'Loading...';
  String _email = 'Loading...';
  String? _uid;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        setState(() {
          _username = doc.data()?['username'] ?? 'No Name';
          _email = doc.data()?['email'] ?? 'No Email';
          _uid = user.uid;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_username),
            accountEmail: Text(_email),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.green,
              ),
            ),
            decoration: const BoxDecoration(color: Colors.green),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerListTile(
                  title: 'Dashboard',
                  icon: Icons.dashboard,
                  press: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminDashboard(uid: _uid ?? ''),
                      ),
                    );
                  },
                ),
                DrawerListTile(
                  title: 'Pickup Requests',
                  icon: Icons.list_alt,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PickupRequestsPage(uid: _uid ?? ''),
                      ),
                    );
                  },
                ),
                DrawerListTile(
                  title: 'Educational Content',
                  icon: Icons.school,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                EducationalContentPage(uid: _uid ?? ''),
                      ),
                    );
                  },
                ),
                DrawerListTile(
                  title: "Recycling Center",
                  icon: Icons.map,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RecyclingCenterPage()),
                    );
                  },
                ),
                
                DrawerListTile(
                  title: "Settings",
                  icon: Icons.settings,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('No', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('isLoggedIn');
                    await prefs.remove('uid');
                    await prefs.remove('role');
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
