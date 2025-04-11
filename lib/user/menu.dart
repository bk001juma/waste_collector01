import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Section
          const UserAccountsDrawerHeader(
            accountName: Text('RecycleHub'),
            accountEmail: Text('recyclehub@tz.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage(""),
            ),
            decoration: BoxDecoration(
              color: Colors.green, // Theme color for sustainability
            ),
          ),
          // List of menu options
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerListTile(
                  title: "Notifications",
                  icon: Icons.notifications,
                  press: () {
                    // Navigate to Notifications Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                DrawerListTile(
                  title: "Schedules",
                  icon: Icons.schedule,
                  press: () {
                    // Navigate to Schedule Pickup Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                DrawerListTile(
                  title: "Recycling Tips",
                  icon: Icons.recycling,
                  press: () {
                    // Navigate to Recycling Tips Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                DrawerListTile(
                  title: "Recycling Centers",
                  icon: Icons.map,
                  press: () {
                    // Navigate to Recycling Centers Map
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                DrawerListTile(
                  title: "Leaderboard",
                  icon: Icons.leaderboard,
                  press: () {
                    // Navigate to Leaderboard Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                DrawerListTile(
                  title: "Settings",
                  icon: Icons.settings,
                  press: () {
                    // Navigate to Settings Screen
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                DrawerListTile(
                  title: "Language",
                  icon: Icons.language,
                  press: () {
                    // Navigate to Language Settings
                    Navigator.pop(context); // Close the drawer
                  },
                ),
              ],
            ),
          ),
          // Footer Section (Logout)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogoutBottomSheet(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Theme color for sustainability
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

  // Function to show logout confirmation bottom sheet
  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to log out?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login', // Replace with your actual route name
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Yes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('No'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom widget for drawer list items
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
      leading: Icon(
        icon,
        color: Colors.green,
      ), // Theme color for sustainability
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: press,
    );
  }
}
