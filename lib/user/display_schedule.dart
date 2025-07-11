import 'package:RecycleHub/services/schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure intl is added in pubspec.yaml

class DisplaySchedulePage extends StatefulWidget {
  const DisplaySchedulePage({super.key, required String uid});

  @override
  State<DisplaySchedulePage> createState() => _DisplaySchedulePageState();
}

class _DisplaySchedulePageState extends State<DisplaySchedulePage> {
  late Future<List<Map<String, dynamic>>> _scheduleData;
  final FirebaseWasteService _wasteService = FirebaseWasteService();

  @override
  void initState() {
    super.initState();
    _scheduleData = _wasteService.fetchScheduleData();
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    await _wasteService.cancelWasteCollection(scheduleId);   
    setState(() {
      _scheduleData = _wasteService.fetchScheduleData();
    });
  }

  Future<Map<String, dynamic>?> _fetchFullSchedule(String id) async {
    final allSchedules = await _scheduleData;
    return allSchedules.firstWhere(
      (item) => item['id'] == id,
      orElse: () => {},
    );
  }

  // Color status helper
  Color _getStatusColor(String? status) {
    switch ((status ?? 'Pending').toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Updated to take DateTime? instead of String?
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown date';
    try {
      return DateFormat.yMMMMd().add_jm().format(dateTime.toLocal());
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Waste Collections'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tips.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay with black opacity
          // ignore: deprecated_member_use
          Container(color: Colors.black.withOpacity(0.5)),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _scheduleData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error fetching schedule data',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No scheduled waste collections found.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }

              List<Map<String, dynamic>> schedule = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListView.builder(
                  itemCount: schedule.length,
                  itemBuilder: (context, index) {
                    final item = schedule[index];
                    final status = item['status'] ?? 'Pending';
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        title: Text(
                          item['wasteType'] ?? 'Unknown Waste',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Street: ${item['street'] ?? 'N/A'}"),
                              Text("Street Number: ${item['streetNumber'] ?? 'N/A'}"),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: _getStatusColor(status).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Delete schedule',
                                    onPressed: () => _deleteSchedule(item['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          final fullSchedule = await _fetchFullSchedule(item['id']);
                          if (fullSchedule != null) {
                            _showScheduleDetailsDialog(fullSchedule);
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showScheduleDetailsDialog(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Schedule Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Waste Type:", schedule['wasteType']),
                _detailRow("Street:", schedule['street']),
                _detailRow("Street Number:", schedule['streetNumber']),
                _detailRow(
                  "Pickup Date:",
                  schedule['pickupDate'] != null
                      ? _formatDate((schedule['pickupDate'] as dynamic).toDate())
                      : "Unknown",
                ),
                _detailRow("Pickup Time:", schedule['pickupTime'] ?? "Unknown"),
                _detailRow("Status:", schedule['status'] ?? "Pending"),
                if ((schedule['additionalNotes'] ?? "").toString().isNotEmpty)
                  _detailRow("Notes:", schedule['additionalNotes']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
          children: [
            TextSpan(
              text: value ?? 'N/A',
              style: const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
