import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collector/user/display_schedule.dart';
import 'package:collector/user/menu.dart';
import 'package:collector/user/schedule.dart';
import 'package:collector/user/tips.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

final Logger _logger = Logger('HomePage');

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({super.key, required this.uid});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String> _username;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _username = _fetchUsername();
  }

  Future<String> _fetchUsername() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();
      if (userDoc.exists) {
        return userDoc.data()?['username'] ?? 'Guest';
      }
    } catch (e) {
      _logger.severe('Error fetching username: $e');
    }
    return 'Guest';
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _username,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingScaffold();
        }

        if (snapshot.hasError) {
          _logger.severe('Error fetching username: ${snapshot.error}');
          return _errorScaffold();
        }

        final username = snapshot.data ?? 'Guest';

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'RecycleHub',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: const Color.fromARGB(255, 14, 73, 17),
            elevation: 0,
          ),
          drawer: const SideMenu(),
          body: _buildPageContent(username),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Schedules',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.recycling),
                label: 'Tips',
              ),
            ],
            currentIndex: _currentIndex,
            selectedItemColor: Colors.green,
            onTap: _onTabTapped,
          ),
        );
      },
    );
  }

  Widget _buildPageContent(String username) {
    switch (_currentIndex) {
      case 0:
        return _homeContent(username);
      case 1:
        return DisplaySchedulePage(uid: widget.uid);
      case 2:
        return RecyclingTips();
      default:
        return _homeContent(username);
    }
  }

  Widget _homeContent(String username) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $username!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let\'s make Tanzania cleaner and greener!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: QuickActionCard(
                  icon: Icons.schedule,
                  label: 'Schedule Pickup',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const SchedulePickup(
                              scheduleId: '',
                              initialWasteType: null,
                              initialPickupLocation: null,
                              initialWasteDetails: null,
                              initialPickupDate: null,
                              initialPickupTime: null,
                              initialAmountOfWaste: null,
                              initialAdditionalNotes: null,
                            ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuickActionCard(
                  icon: Icons.recycling,
                  label: 'Recycling Tips',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecyclingTips()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Today\'s Recycling Tip',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const RecyclingTipCard(
            tip:
                'Did you know? Recycling one aluminum can saves enough energy to run a TV for 3 hours!',
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const ActivityCard(
            activity:
                'Your pickup for plastic waste is scheduled for tomorrow at 10 AM.',
          ),
        ],
      ),
    );
  }

  Widget _loadingScaffold() => Scaffold(
    appBar: AppBar(
      title: Text('RecycleHub', style: TextStyle(color: Colors.white)),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Color.fromARGB(255, 14, 73, 17),
    ),
    body: Center(child: CircularProgressIndicator()),
  );

  Widget _errorScaffold() => Scaffold(
    appBar: AppBar(
      title: Text('RecycleHub', style: TextStyle(color: Colors.white)),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Color.fromARGB(255, 14, 73, 17),
    ),
    body: Center(child: Text('Error fetching username')),
  );
}

// ----- Reusable Widgets -----
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecyclingTipCard extends StatelessWidget {
  final String tip;

  const RecyclingTipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, size: 30, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(child: Text(tip, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.notifications, size: 30, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(activity, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
