import 'package:RecycleHub/admin/drawer.dart';
import 'package:RecycleHub/admin/pending_pickuopage.dart';
import 'package:RecycleHub/admin/picked_up.dart';
import 'package:RecycleHub/admin/repuest_pickup.dart';
import 'package:RecycleHub/admin/userpage.dart';
import 'package:RecycleHub/admin/weekly_pickup.dart' show WeeklyPickupChartPage;
import 'package:RecycleHub/services/dashboard_services.dart';
import 'package:RecycleHub/services/schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const AdminApp(uid: 'admin'));
}

class AdminApp extends StatelessWidget {
  final String uid;
  const AdminApp({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RecycleHub Admin',
          theme: ThemeData(primarySwatch: Colors.green),
          home: AdminDashboard(uid: uid),
        );
      },
    );
  }
}

class AdminDashboard extends StatefulWidget {
  final String uid;
  const AdminDashboard({super.key, required this.uid});

  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? username;
  final FirebaseWasteService _firebaseWasteService = FirebaseWasteService();

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  // Fetch the username from Firestore
  Future<void> _fetchUsername() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();
      setState(() {
        username = userDoc.data()?['username'] as String?;
      });
    } catch (e) {
      print('Error fetching username: $e');
      setState(() {
        username = 'Unknown'; // Default username if an error occurs
      });
    }
  }

  // Replace this method with the new one
  Future<List<Map<String, dynamic>>> fetchAllScheduledPickups() async {
    return await _firebaseWasteService.fetchAllScheduledPickups();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardService = DashboardService();

    return Scaffold(
      drawer: AdminDrawer(uid: widget.uid),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (username != null)
              Text(
                '👋 Welcome, $username!',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20.h),

            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  children: [
                    _buildStatCard(
                      'Users',
                      dashboardService.getTotalUsers(),
                      AllUsersPage(),
                    ),
                    _buildStatCard(
                      'Total Pickups',
                      dashboardService.getScheduledPickups(),
                      PickupRequestsPage(uid: ''),
                    ),
                    _buildStatCard(
                      'Picked Up',
                      dashboardService.getPickedUpRequests(),
                      const PickedUpRequestsPage(),
                    ),
                    _buildStatCard(
                      'Pending Pickups',
                      dashboardService.getPendingPickupsCount(), 
                      const PendingPickupsPaginatedPage(),
                    ),


                  ],
                );
              },
            ),

            SizedBox(height: 24.h),
              // Bar Chart
              Text(
                '📊 Weekly Pickups',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            

            SizedBox(height: 200.h, child: WeeklyPickupChartPage()), 
          ],
        ),
      ),
    );
  }

  // Stub for _buildStatCard (you probably already have this)
  Widget _buildStatCard(
  String title,
  Future<int> futureValue,
  Widget targetPage,
) {
  return FutureBuilder<int>(
    future: futureValue,
    builder: (context, snapshot) {
      final count = snapshot.data ?? 0;
      return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
         // Refresh the dashboard after returning
          setState(() {});

        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

}

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  const DashboardCard({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }
}


