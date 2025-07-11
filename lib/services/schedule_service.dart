import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class FirebaseWasteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch waste types from Firestore collection 'waste_types'
  Future<List<String>> fetchWasteTypes() async {
    try {
      final snapshot = await _firestore.collection('waste_types').get();
      return snapshot.docs.map((doc) => doc['type'] as String).toList();
    } catch (e) {
      log("Error fetching waste types: $e");
      throw Exception('Failed to fetch waste types');
    }
  }

  /// Submit a new waste pickup schedule to Firestore
  Future<void> submitWasteCollection(
    String wasteDetails, {
    required DateTime pickupDate,
    required String pickupTime,
    required String wasteType,
    required String additionalNotes,
    required double amountOfWaste,
    required String street,
    required String streetNumber,
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("User not authenticated");
    }

    try {
      await _firestore.collection('waste_pickups').add({
        'userId': currentUser.uid,
        'pickupDate': Timestamp.fromDate(pickupDate),
        'pickupTime': pickupTime,
        'wasteType': wasteType,
        'additionalNotes': additionalNotes,
        'amountOfWaste': amountOfWaste,
        'street': street,
        'streetNumber': streetNumber,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      log("Waste collection submitted for user ${currentUser.uid}");
    } catch (e) {
      log("Error submitting waste collection: $e");
      throw Exception("Failed to submit waste collection");
    }
  }

  /// Fetch all scheduled pickups for admin view
  Future<List<Map<String, dynamic>>> fetchAllScheduledPickups() async {
    try {
      final snapshot = await _firestore
          .collection('waste_pickups')
          .orderBy('pickupDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'userId': doc['userId'],
          'wasteType': doc['wasteType'],
          'pickupDate': doc['pickupDate'].toDate(),
          'pickupTime': doc['pickupTime'],
          'amountOfWaste': doc['amountOfWaste'],
          'street': doc['street'],
          'streetNumber': doc['streetNumber'],
        };
      }).toList();
    } catch (e) {
      log('Error fetching all scheduled pickups for admin: $e');
      return [];
    }
  }

 Future<List<Map<String, dynamic>>> fetchWeeklyPickups() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('waste_pickups')
          .where('status', isEqualTo: 'Picked Up')
          .get();

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final counts = <int, int>{};

      for (var i = 0; i < 7; i++) {
        counts[i] = 0;
      }

      for (var doc in snapshot.docs) {
        final pickupTimestamp = doc['pickupDate'];
        if (pickupTimestamp == null) continue;

        final date = (pickupTimestamp as Timestamp).toDate();
        if (date.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
          final weekday = date.weekday - 1; // Monday = 0
          counts[weekday] = (counts[weekday] ?? 0) + 1;
        }
      }

      return counts.entries.map((e) => {
        'day': e.key,
        'count': e.value,
      }).toList();
    } catch (e) {
      print("Error fetching pickups: $e");
      return [];
    }
  }


  /// Cancel (delete) a scheduled waste pickup
  Future<void> cancelWasteCollection(String scheduleId) async {
    try {
      await _firestore.collection('waste_pickups').doc(scheduleId).delete();
      log("Schedule $scheduleId deleted successfully");
    } catch (e) {
      log("Error deleting schedule: $e");
      throw Exception("Failed to delete schedule");
    }
  }

  /// Fetch scheduled waste pickups for the current user
  Future<List<Map<String, dynamic>>> fetchScheduleData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }

    try {
      final querySnapshot = await _firestore
          .collection('waste_pickups')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      log("Error fetching scheduled pickups: $e");
      throw Exception("Failed to fetch schedule data");
    }
  }

  /// Update status of a waste pickup in 'waste_pickups'
  Future<void> updatePickupStatus(String documentId, String newStatus) async {
    try {
      await _firestore.collection('waste_pickups').doc(documentId).update({
        'status': newStatus,
      });
      log("Status updated to $newStatus for $documentId");
    } catch (e) {
      log("Error updating status: $e");
      throw Exception("Failed to update status");
    }
  }

  /// Placeholder for user schedule count for a specific date (future extension)
  Future<int> getUserScheduleCountForDate(DateTime dateTime) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    throw Exception("User not authenticated");
  }

  try {
    // Start of the day
    final startOfDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    // End of the day
    final endOfDay = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('waste_pickups')
        .where('userId', isEqualTo: currentUser.uid)
        .where('pickupDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('pickupDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.length;
  } catch (e) {
    log("Error fetching schedule count: $e");
    return 0; // Return 0 if there's an error
  }
}




}
