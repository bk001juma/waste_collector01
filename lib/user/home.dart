import 'dart:math' as logger show e;
import 'package:RecycleHub/provider/theme.dart';
import 'package:RecycleHub/services/educational_service.dart';
import 'package:RecycleHub/user/display_schedule.dart';
import 'package:RecycleHub/user/educational_content.dart';
import 'package:RecycleHub/user/menu.dart';
import 'package:RecycleHub/user/schedule.dart';
import 'package:RecycleHub/user/tips.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String?> _usernameFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _usernameFuture = _fetchUsername();
  }

  Future<String?> _fetchUsername() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();
      return userDoc.data()?['username'] as String?;
    } catch (e) {
      logger.e;
      return null;
    }
  }

  void _onTabTapped(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _usernameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScaffold();
        }

        if (snapshot.hasError) {
          return _buildErrorScaffold();
        }

        final username = snapshot.data ?? 'Guest';

        return Scaffold(
          appBar: _buildAppBar(),
          drawer: SideMenu(uid: widget.uid),
          body: _buildCurrentPage(username),
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return AppBar(
    title: const Text('RecycleHub', style: TextStyle(color: Colors.white)),
    centerTitle: true,
    iconTheme: const IconThemeData(color: Colors.white),
    backgroundColor: const Color.fromARGB(255, 14, 73, 17),
    elevation: 0,
    actions: [
      IconButton(
        icon: Icon(
          isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
          color: Colors.white,
        ),
        tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        onPressed: () {
          // Toggle theme using Provider
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          themeProvider.toggleTheme();
        },
      ),
    ],
  );
}


  Widget _buildCurrentPage(String username) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent(username);
      case 1:
        return DisplaySchedulePage(uid: widget.uid);
      case 2:
        return RecyclingTips();
      default:
        return _buildHomeContent(username);
    }
  }

  Widget _buildHomeContent(String username) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(username),
          const SizedBox(height: 20),
          _buildQuickActionsRow(),
          const SizedBox(height: 20),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Recling Tips",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          _buildCarouselSection(),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Recent Pickup Activity",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildRecentActivitySection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(String username) {
    return Column(
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
      ],
    );
  }

  Widget _buildCarouselSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: EducationalService().getEducationalContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('No educational content available.'));
        }

        final contentDocs = snapshot.data!.docs;

        return SizedBox(
          height: 200,
          child: CarouselSlider(
            items:
                contentDocs.map((content) {
                  final contentData = content.data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  EducationalDetailPage(content: contentData),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/r-tip.jpg', // Your asset image path
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(
                                0.4,
                              ), // Dark overlay
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                contentData['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              aspectRatio: 16 / 9,
              initialPage: 0,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: QuickActionCard(
            icon: Icons.schedule,
            label: 'Schedule Pickup',
            onTap: () => _navigateToSchedulePickup(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            icon: Icons.recycling,
            label: 'Recycling Tips',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecyclingTips()),
                ),
          ),
        ),
      ],
    );
  }

  void _navigateToSchedulePickup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SchedulePickupForm(
              scheduleId: '',
              initialWasteType: '',
              initialPickupDate: DateTime.now(),
              initialPickupTime: '',
              initialAmountOfWaste: 0,
              initialAdditionalNotes: '',
              initialStreet: '',
            ),
      ),
    );
  }

 Widget _buildRecentActivitySection() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('waste_pickups')
        .where('userId', isEqualTo: widget.uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const ActivityCard(activity: 'No recent pickups available.');
      }

      final pickupDoc = snapshot.data!.docs.first;
      final pickupData = pickupDoc.data() as Map<String, dynamic>;

      final dynamic rawPickupDate = pickupData['pickupDate'];
      DateTime? pickupDate;

      if (rawPickupDate is Timestamp) {
        pickupDate = rawPickupDate.toDate();
      } else if (rawPickupDate is String) {
        try {
          pickupDate = DateTime.parse(rawPickupDate);
        } catch (e) {
          pickupDate = null;
        }
      }

      final String pickupTime = pickupData['pickupTime'] ?? 'Unknown time';
      final String status = pickupData['status'] ?? 'Scheduled';

      final String location = (pickupData['street'] != null && pickupData['streetNumber'] != null)
          ? '${pickupData['street']} ${pickupData['streetNumber']}'
          : 'Unknown location';

      final String formattedDate = pickupDate != null
          ? '${pickupDate.day}/${pickupDate.month}/${pickupDate.year} at '
              '${pickupDate.hour.toString().padLeft(2, '0')}:${pickupDate.minute.toString().padLeft(2, '0')}'
          : 'Unknown date';

      final String activity =
          'Recent pickup scheduled on $formattedDate at $pickupTime.\n'
          'Status: $status.\n'
          'Pickup Location: $location.';

      return ActivityCard(activity: activity);
    },
  );
}
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
        BottomNavigationBarItem(icon: Icon(Icons.recycling), label: 'Tips'),
      ],
      currentIndex: _currentIndex,
      selectedItemColor: Colors.green,
      onTap: _onTabTapped,
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const Center(child: Text('Error loading user data')),
    );
  }
}

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
