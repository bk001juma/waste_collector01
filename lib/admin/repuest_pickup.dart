// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:RecycleHub/services/schedule_service.dart';

class PickupRequestsPage extends StatefulWidget {
  final String uid;
  const PickupRequestsPage({super.key, required this.uid});

  @override
  State<PickupRequestsPage> createState() => _PickupRequestsPageState();
}

class _PickupRequestsPageState extends State<PickupRequestsPage> {
  final int _limit = 10;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasNext = false;
  String _selectedStatusFilter = 'All';

  DocumentSnapshot? _lastDoc;
  DocumentSnapshot? _firstDoc;
  List<DocumentSnapshot> _currentDocs = [];

  @override
  void initState() {
    super.initState();
    _fetchPage();
  }

  Future<void> _fetchPage({bool next = true}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('waste_pickups')
        .orderBy('pickupDate', descending: true)
        .limit(_limit);

    if (next && _lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    } else if (!next && _firstDoc != null) {
      query = query.endBeforeDocument(_firstDoc!).limitToLast(_limit);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _currentDocs = snapshot.docs;
        _firstDoc = snapshot.docs.first;
        _lastDoc = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;

        if (next) {
          _currentPage++;
        } else {
          _currentPage = (_currentPage - 1).clamp(1, _currentPage);
        }
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = _selectedStatusFilter == 'All'
        ? _currentDocs
        : _currentDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == _selectedStatusFilter;
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Requests'),
      backgroundColor: Colors.green,),
      body: Column(
        children: [
          /// Status Filter Dropdown
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.green),
                SizedBox(width: 10.w),
                Text('Filter by Status:', style: TextStyle(fontSize: 16.sp)),
                SizedBox(width: 10.w),
                DropdownButton<String>(
                  value: _selectedStatusFilter,
                  items: ['All', 'Pending', 'Picked Up']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatusFilter = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          /// Pickup List
          Expanded(
            child: _isLoading && _currentDocs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredDocs.isEmpty
                    ? const Center(child: Text('No pickup requests found'))
                    : ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final data = filteredDocs[index].data() as Map<String, dynamic>;
                          final requestId = filteredDocs[index].id;
                          final wasteType = data['wasteType'] ?? 'Unknown';
                          final pickupDate = (data['pickupDate'] as Timestamp?)?.toDate();
                          final pickupTime = data['pickupTime'] ?? 'Unknown';
                          final status = data['status'] ?? 'Pending';

                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            elevation: 4,
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
                                          wasteType,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: status,
                                        items: ['Pending', 'Picked Up']
                                            .map((value) => DropdownMenuItem(
                                                  value: value,
                                                  child: Text(value),
                                                ))
                                            .toList(),
                                        onChanged: (newValue) async {
                                          if (newValue != null && newValue != status) {
                                            try {
                                              await FirebaseWasteService()
                                                  .updatePickupStatus(requestId, newValue);
                                              setState(() {
                                                data['status'] = newValue;
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text('Status updated to $newValue')),
                                              );
                                            } catch (_) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Failed to update status')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("Delete Pickup Request"),
                                              content: const Text(
                                                  "Are you sure you want to delete this request?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, false),
                                                  child: const Text("No"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, true),
                                                  child: const Text("Yes"),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await FirebaseWasteService()
                                                  .cancelWasteCollection(requestId);
                                              setState(() {
                                                _currentDocs.removeWhere(
                                                    (doc) => doc.id == requestId);
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Request deleted')),
                                              );
                                            } catch (_) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content:
                                                        Text('Failed to delete request')),
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
                                      const Icon(Icons.calendar_today,
                                          size: 18, color: Colors.blueGrey),
                                      SizedBox(width: 6.w),
                                      Text(
                                        pickupDate != null
                                            ? pickupDate.toLocal().toString().split(' ')[0]
                                            : 'Unknown Date',
                                        style: TextStyle(
                                            fontSize: 14.sp, color: Colors.black87),
                                      ),
                                      SizedBox(width: 16.w),
                                      const Icon(Icons.access_time,
                                          size: 18, color: Colors.blueGrey),
                                      SizedBox(width: 6.w),
                                      Text(
                                        pickupTime,
                                        style: TextStyle(
                                            fontSize: 14.sp, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'Status: $status',
                                    style: TextStyle(
                                        fontSize: 14.sp, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          if (_isLoading && _currentDocs.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          /// Pagination Controls
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 1 ? () => _fetchPage(next: false) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
                child: const Text('Previous'),
              ),
              SizedBox(width: 20.w),
              Text(
                'Page $_currentPage',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 20.w),
              ElevatedButton(
                onPressed: _hasNext ? () => _fetchPage(next: true) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
