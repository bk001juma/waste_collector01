
import 'package:RecycleHub/user/login.dart';
import 'package:RecycleHub/user/recycling_center.dart';
import 'package:RecycleHub/user/setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatefulWidget {
  final String uid;

  const SideMenu({super.key, required this.uid});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String username = 'Loading...';
  String email = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? 'No Name';
          email = userDoc['email'] ?? 'No Email';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username),
            accountEmail: Text(email),
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
                  title: "Notification",
                  icon: Icons.notifications,
                  press: () => Navigator.pop(context),
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
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.white,),
              label: const Text('LOGOUT',
              style: TextStyle(color: Colors.white),),
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
              onPressed: () => Navigator.pop(context),
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

                // Clear Firebase auth session
                await FirebaseAuth.instance.signOut();

                // Clear shared preferences (remember me status)
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('isLoggedIn'); // Remove login flag
                await prefs.remove('uid'); // Remove UID if stored

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

class DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback press;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: press,
    );
  }
}
