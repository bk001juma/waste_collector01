import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequestDetailsPage extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const RequestDetailsPage({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final wasteType = requestData['wasteType'] ?? 'Unknown';
    final pickupDate = (requestData['pickupDate']?.toDate())?.toLocal().toString().split(' ')[0] ?? 'Unknown';
    final pickupTime = requestData['pickupTime'] ?? 'Unknown';
    final status = requestData['status'] ?? 'Unknown';
    final address = requestData['address'] ?? 'Not Provided';
    final instructions = requestData['instructions'] ?? 'No special instructions';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Request Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Waste Type', wasteType),
            _infoRow('Pickup Date', pickupDate),
            _infoRow('Pickup Time', pickupTime),
            _infoRow('Status', status),
            _infoRow('Address', address),
            _infoRow('Instructions', instructions),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16.sp),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
