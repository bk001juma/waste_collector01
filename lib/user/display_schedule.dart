import 'package:collector/user/schedule.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class DisplaySchedulePage extends StatefulWidget {
  const DisplaySchedulePage({super.key, required String uid});

  @override
  // ignore: library_private_types_in_public_api
  _DisplaySchedulePageState createState() => _DisplaySchedulePageState();
}

class _DisplaySchedulePageState extends State<DisplaySchedulePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _scheduleData;
  String? _selectedScheduleId;
  Map<String, dynamic>? _selectedSchedule;

  @override
  void initState() {
    super.initState();
    _scheduleData = _fetchScheduleData();
  }

  // Fetch schedule data for the authenticated user
  Future<List<Map<String, dynamic>>> _fetchScheduleData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        log("User is not authenticated");
        return [];
      }

      final snapshot =
          await _firestore
              .collection('waste_collections')
              .where('userId', isEqualTo: currentUser.uid)
              .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'wasteType': doc['wasteType'],
          'pickupLocation': doc['pickupLocation'],
        };
      }).toList();
    } catch (e) {
      log("Error fetching schedule data: $e");
      return [];
    }
  }

  // Delete a specific schedule
  Future<void> _deleteSchedule(String scheduleId) async {
    try {
      await _firestore.collection('waste_collections').doc(scheduleId).delete();
      log("Schedule deleted successfully");
      setState(() {
        _scheduleData = _fetchScheduleData();
        _selectedSchedule = null;
      });
    } catch (e) {
      log("Error deleting schedule: $e");
    }
  }

  // Update a specific schedule
  Future<void> _updateSchedule(String scheduleId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Schedule"),
          content: Text("Here, you can update the schedule details."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _scheduleData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching schedule data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No scheduled waste collections found.'));
          } else {
            List<Map<String, dynamic>> schedule = snapshot.data!;
            return ListView.builder(
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final item = schedule[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(item['wasteType']),
                    subtitle: Text(item['pickupLocation']),
                    onTap: () async {
                      final fullSchedule = await _fetchFullSchedule(item['id']);
                      setState(() {
                        _selectedScheduleId = item['id'];
                        _selectedSchedule = fullSchedule;
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      bottomSheet:
          _selectedSchedule != null
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waste Type: ${_selectedSchedule!['wasteType']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pickup Location: ${_selectedSchedule!['pickupLocation']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Waste Details: ${_selectedSchedule!['wasteDetails']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pickup Date: ${_selectedSchedule!['pickupDate']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pickup Time: ${_selectedSchedule!['pickupTime']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Amount of Waste: ${_selectedSchedule!['amountOfWaste']} kg',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Additional Notes: ${_selectedSchedule!['additionalNotes']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Update Schedule button's onPressed function
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedSchedule != null) {
                              // Navigate to SchedulePickup page and pass the selected schedule data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SchedulePickup(
                                        scheduleId: _selectedScheduleId!,
                                        initialWasteType:
                                            _selectedSchedule!['wasteType'],
                                        initialPickupLocation:
                                            _selectedSchedule!['pickupLocation'],
                                        initialWasteDetails:
                                            _selectedSchedule!['wasteDetails'],
                                        initialPickupDate:
                                            _selectedSchedule!['pickupDate'],
                                        initialPickupTime:
                                            _selectedSchedule!['pickupTime'],
                                        initialAmountOfWaste:
                                            _selectedSchedule!['amountOfWaste'],
                                        initialAdditionalNotes:
                                            _selectedSchedule!['additionalNotes'],
                                      ),
                                ),
                              );
                            }
                          },
                          child: Text('Update Schedule'),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            _deleteSchedule(_selectedScheduleId!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text('Delete Schedule'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : null,
    );
  }

  // Fetch the full schedule details by its ID
  Future<Map<String, dynamic>> _fetchFullSchedule(String scheduleId) async {
    try {
      final doc =
          await _firestore
              .collection('waste_collections')
              .doc(scheduleId)
              .get();
      return {
        'id': doc.id,
        'wasteDetails': doc['wasteDetails'],
        'pickupDate': (doc['pickupDate'] as Timestamp).toDate(),
        'pickupTime': doc['pickupTime'],
        'amountOfWaste': doc['amountOfWaste'],
        'additionalNotes': doc['additionalNotes'],
        'pickupLocation': doc['pickupLocation'],
        'wasteType': doc['wasteType'],
      };
    } catch (e) {
      log("Error fetching full schedule details: $e");
      return {};
    }
  }
}
