// ignore_for_file: use_build_context_synchronously

import 'package:collector/services/schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchedulePickup extends StatefulWidget {
  const SchedulePickup({
    super.key,
    required String scheduleId,
    required initialWasteType,
    required initialPickupLocation,
    required initialWasteDetails,
    required initialPickupDate,
    required initialPickupTime,
    required initialAmountOfWaste,
    required initialAdditionalNotes,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SchedulePickupState createState() => _SchedulePickupState();
}

class _SchedulePickupState extends State<SchedulePickup> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedWasteType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _locationController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _scheduleData;

  final List<String> _wasteTypes = [
    'Plastic',
    'Paper',
    'Metal',
    'Glass',
    'Organic',
    'E-Waste',
  ];

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
        return [];
      }

      final snapshot =
          await FirebaseFirestore.instance
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
      return [];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null && picked != _selectedTime) {
      if (picked.hour < now.hour ||
          (picked.hour == now.hour && picked.minute < now.minute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a future time')),
        );
      } else {
        setState(() {
          _selectedTime = picked;
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        FirebaseWasteService firebaseWasteService = FirebaseWasteService();
        await firebaseWasteService.submitWasteCollection(
          "Waste collection request", // or any additional details if needed
          pickupDate: _selectedDate!,
          wasteType: _selectedWasteType!,
          pickupTime: _selectedTime!.format(context),
          additionalNotes: _notesController.text,
          amountOfWaste: double.parse(_amountController.text),
          pickupLocation: _locationController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pickup scheduled successfully!')),
        );

        _formKey.currentState!.reset();
        setState(() {
          _selectedWasteType = null;
          _selectedDate = null;
          _selectedTime = null;
          _locationController.clear();
          _amountController.clear();
          _notesController.clear();
        });
        // ignore: duplicate_ignore
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Pickup'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedWasteType,
                decoration: const InputDecoration(
                  labelText: 'Select Waste Type',
                  border: OutlineInputBorder(),
                ),
                items:
                    _wasteTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWasteType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a waste type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Pickup Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Pickup Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null
                            ? 'Select Time'
                            : _selectedTime!.format(context),
                      ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Pickup Location',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount of Waste (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount of waste';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Schedule Pickup',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _scheduleData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching schedule data'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No scheduled waste collections.'),
                    );
                  } else {
                    List<Map<String, dynamic>> schedule = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: schedule.length,
                      itemBuilder: (context, index) {
                        final item = schedule[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(item['wasteType']),
                            subtitle: Text(item['pickupLocation']),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
