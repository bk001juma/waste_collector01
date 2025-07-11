// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:RecycleHub/services/schedule_service.dart';

class PickedUpRequestsPage extends StatelessWidget {
  const PickedUpRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picked Up Requests'),
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('waste_pickups')
            .where('status', isEqualTo: 'Picked Up')
            .orderBy('pickupDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text('No picked up requests found.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              final requestId = doc.id;
              final wasteType = data['wasteType'] ?? 'Unknown';
              final pickupDate = (data['pickupDate'] as Timestamp?)?.toDate();
              final pickupTime = data['pickupTime'] ?? 'Unknown';
              final street = data['street'] ?? '';
              final streetNumber = data['streetNumber'] ?? '';
              final status = data['status'] ?? 'Picked Up';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.recycling, color: Colors.green),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '$wasteType Pickup',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Pickup Request"),
                                  content: const Text("Are you sure you want to delete this request?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await FirebaseWasteService().cancelWasteCollection(requestId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Request deleted')),
                                  );
                                } catch (_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to delete request')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                          SizedBox(width: 6.w),
                          Text(
                            pickupDate != null
                                ? pickupDate.toLocal().toString().split(' ')[0]
                                : 'N/A',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                          ),
                          SizedBox(width: 16.w),
                          const Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
                          SizedBox(width: 6.w),
                          Text(
                            pickupTime,
                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Location: $street $streetNumber',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Status: $status',
                        style: TextStyle(fontSize: 14.sp, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
