// ignore_for_file: use_build_context_synchronously

import 'package:RecycleHub/services/schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePickupForm extends StatefulWidget {
  const SchedulePickupForm({
    super.key,
    required this.initialAdditionalNotes,
    required this.initialAmountOfWaste,
    required this.initialPickupTime,
    required this.initialPickupDate,
    required this.initialWasteType,
    required this.scheduleId,
    required this.initialStreet,
  });

  final String initialAdditionalNotes;
  final int initialAmountOfWaste;
  final String initialPickupTime;
  final DateTime initialPickupDate;
  final String initialWasteType;
  final String scheduleId;
  final String initialStreet;

  @override
  State<SchedulePickupForm> createState() => _SchedulePickupFormState();
}

class _SchedulePickupFormState extends State<SchedulePickupForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _pickupTimeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();

  String _selectedWasteType = '';
  String _selectedStreet = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final List<String> _wasteTypes = ['Plastic', 'Paper', 'Glass', 'Metal'];

  final Map<String, String> _streetPickupDays = {
    'Sangasanga': 'Monday',
    'J4': 'Tuesday',
    'Mahakamani': 'Wednesday',
    'Osterbay': 'Thursday',
    'Mkubege': 'Friday',
    'Paradise': 'Saturday',
    'Changarawe': 'Sunday',
  };

  // Allowed time range
  final TimeOfDay _minTime = const TimeOfDay(hour: 7, minute: 30);
  final TimeOfDay _maxTime = const TimeOfDay(hour: 16, minute: 0);

  @override
  void initState() {
    super.initState();

    _pickupTimeController.text = widget.initialPickupTime;
    _amountController.text = widget.initialAmountOfWaste.toString();
    _additionalNotesController.text = widget.initialAdditionalNotes;

    _selectedWasteType = widget.initialWasteType;
    _selectedStreet = widget.initialStreet;
    _selectedDate = widget.initialPickupDate;
    _pickupDateController.text = DateFormat('yyyy-MM-dd').format(widget.initialPickupDate);

    final parsedTime = _parseTime(widget.initialPickupTime);
    if (parsedTime != null) {
      _selectedTime = parsedTime;
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final format = DateFormat.jm(); // e.g., 5:08 PM
      final dateTime = format.parse(timeStr);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (_) {
      return null;
    }
  }

  InputDecoration _inputDecoration(String label, Icon icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  DateTime _getNextPickupDate(String weekday) {
    final today = DateTime.now();
    int targetWeekday = _weekdayToInt(weekday);
    int daysToAdd = (targetWeekday - today.weekday + 7) % 7;
    daysToAdd = daysToAdd == 0 ? 7 : daysToAdd; // Always next
    return today.add(Duration(days: daysToAdd));
  }

  int _weekdayToInt(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        return 1;
    }
  }

  bool _isTimeInRange(TimeOfDay time) {
    final afterMin = time.hour > _minTime.hour || (time.hour == _minTime.hour && time.minute >= _minTime.minute);
    final beforeMax = time.hour < _maxTime.hour || (time.hour == _maxTime.hour && time.minute <= _maxTime.minute);
    return afterMin && beforeMax;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTime == null || !_isTimeInRange(_selectedTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pickup time must be between 7:30 AM and 4:00 PM.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final firebaseService = FirebaseWasteService();
      final userScheduleCount = await firebaseService.getUserScheduleCountForDate(_selectedDate!);

      if (userScheduleCount >= 3) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You have already scheduled 3 pickups for this date.',
            ),
          ),
        );
        return;
      }

      try {
        await firebaseService.submitWasteCollection(
          'Waste scheduled for $_selectedStreet on ${DateFormat('yyyy-MM-dd').format(_selectedDate!)} at ${_pickupTimeController.text}',
          pickupDate: _selectedDate!,
          pickupTime: _pickupTimeController.text,
          wasteType: _selectedWasteType,
          amountOfWaste: double.parse(_amountController.text),
          additionalNotes: _additionalNotesController.text,
          street: _selectedStreet,
          streetNumber: _streetNumberController.text,
        );

        setState(() => _isLoading = false);

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Form submitted successfully!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close form
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
      }
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay(hour: 7, minute: 30),
      builder: (context, child) {
        // Enforce light mode for time picker for consistency (optional)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!_isTimeInRange(picked)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time between 7:30 AM and 4:00 PM.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() {
        _selectedTime = picked;
        _pickupTimeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Waste Pickup'),
        backgroundColor: Colors.green.shade700,
        elevation: 2,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Text(
                    'Schedule your waste pickup',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration(
                      "Waste Type",
                      const Icon(Icons.category),
                    ),
                    value: _selectedWasteType.isNotEmpty ? _selectedWasteType : null,
                    items: _wasteTypes
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedWasteType = value!),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please select a waste type' : null,
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration(
                      "Street",
                      const Icon(Icons.location_city),
                    ),
                    value: _selectedStreet.isNotEmpty ? _selectedStreet : null,
                    items: _streetPickupDays.keys
                        .map((street) => DropdownMenuItem(value: street, child: Text(street)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStreet = value!;
                        final pickupDay = _streetPickupDays[_selectedStreet]!;
                        _selectedDate = _getNextPickupDate(pickupDay);
                        _pickupDateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                      });
                    },
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please select a street' : null,
                  ),
                  if (_selectedStreet.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      "Pickup day for this street is every ${_streetPickupDays[_selectedStreet]!}.",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _streetNumberController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      "Street Number",
                      const Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a street number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _pickupDateController,
                    readOnly: true,
                    decoration: _inputDecoration(
                      "Pickup Date",
                      const Icon(Icons.calendar_today),
                    ),
                    validator: (_) => _selectedDate == null ? 'Pickup date required' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _pickupTimeController,
                    readOnly: true,
                    decoration: _inputDecoration(
                      "Pickup Time (7:30 AM - 4:00 PM)",
                      const Icon(Icons.access_time),
                    ),
                    onTap: _pickTime,
                    validator: (_) {
                      if (_selectedTime == null && _pickupTimeController.text.isEmpty) {
                        return 'Please select a time';
                      }
                      if (_selectedTime != null && !_isTimeInRange(_selectedTime!)) {
                        return 'Pickup time must be between 7:30 AM and 4:00 PM';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      "Amount of Waste (kg)",
                      const Icon(Icons.scale),
                    ),
                    validator: (value) {
                      final numValue = double.tryParse(value ?? '');
                      if (numValue == null || numValue <= 0) {
                        return 'Enter amount greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _additionalNotesController,
                    decoration: _inputDecoration(
                      "Additional Notes",
                      const Icon(Icons.note_alt),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
