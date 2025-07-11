import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/dashboard_services.dart';

class PendingPickupsPaginatedPage extends StatefulWidget {
  const PendingPickupsPaginatedPage({super.key});

  @override
  State<PendingPickupsPaginatedPage> createState() => _PendingPickupsPaginatedPageState();
}

class _PendingPickupsPaginatedPageState extends State<PendingPickupsPaginatedPage> {
  final DashboardService dashboardService = DashboardService();
  List<QueryDocumentSnapshot> _pendingPickups = [];
  QueryDocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final newPickups = await dashboardService.fetchPendingPickupsPaginated(pageSize: _pageSize);

    if (!mounted) return;
    setState(() {
      _pendingPickups = newPickups;
      if (newPickups.length < _pageSize) _hasMore = false;
      if (newPickups.isNotEmpty) _lastDocument = newPickups.last;
      _isLoading = false;
    });
  }


  Future<void> _fetchMoreData() async {
    if (_isLoading || !_hasMore || !mounted) return;

    setState(() => _isLoading = true);
    final newPickups = await dashboardService.fetchPendingPickupsPaginated(
      pageSize: _pageSize,
      startAfterDoc: _lastDocument,
    );

    if (!mounted) return;
    setState(() {
      _pendingPickups.addAll(newPickups);
      if (newPickups.length < _pageSize) _hasMore = false;
      if (newPickups.isNotEmpty) _lastDocument = newPickups.last;
      _isLoading = false;
    });
  }


  Future<void> _updateStatus(String requestId, String newStatus) async {
    await dashboardService.updatePickupStatus(requestId, newStatus);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $newStatus')),
    );
    _fetchInitialData();
  }

  Future<void> _cancelPickup(String requestId) async {
    await dashboardService.cancelWasteCollection(requestId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pickup canceled')),
    );
    _fetchInitialData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Pickups'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading && _pendingPickups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _pendingPickups.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _pendingPickups.length) {
                  _fetchMoreData();
                  return const Center(child: CircularProgressIndicator());
                }

                final data = _pendingPickups[index].data() as Map<String, dynamic>;
                final docId = _pendingPickups[index].id;
                final wasteType = data['wasteType'] ?? 'Unknown';
                final street = data['street'] ?? '';
                final date = (data['pickupDate'] as Timestamp).toDate();
                final formattedDate = '${date.year}-${date.month}-${date.day}';

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Waste Type: $wasteType', style: TextStyle(fontSize: 16.sp)),
                        SizedBox(height: 8.h),
                        Text('Street: $street', style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 8.h),
                        Text('Pickup Date: $formattedDate', style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _updateStatus(docId, 'Picked Up'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Mark Picked'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => _cancelPickup(docId),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
