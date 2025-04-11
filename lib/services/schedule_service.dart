import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class FirebaseWasteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch waste types from Firestore
  Future<List<String>> fetchWasteTypes() async {
    try {
      final snapshot = await _firestore.collection('waste_types').get();
      return snapshot.docs.map((doc) => doc['type'] as String).toList();
    } catch (e) {
      log("Error fetching waste types: $e");
      throw Exception('Failed to fetch waste types');
    }
  }

  // Submit waste collection request
  Future<void> submitWasteCollection(
    String wasteDetails, {
    required DateTime pickupDate,
    required String wasteType,
    required String pickupTime,
    required String additionalNotes,
    required double amountOfWaste,
    required String pickupLocation,
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Ensure the user is authenticated
    if (currentUser == null) {
      log("User is not authenticated");
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message: 'You must be signed in to submit a waste collection.',
      );
    }

    try {
      // Add waste collection document with the userId set as the current user's UID
      await _firestore.collection('waste_collections').add({
        'userId': currentUser.uid, // Set the userId field
        'wasteDetails': wasteDetails,
        'pickupDate': pickupDate,
        'pickupTime': pickupTime,
        'wasteType': wasteType,
        'pickupLocation': pickupLocation,
        'amountOfWaste': amountOfWaste,
        'additionalNotes': additionalNotes,
        'timestamp': FieldValue.serverTimestamp(),
      });
      log("Waste collection submitted successfully.");
    } catch (e) {
      log("Error submitting waste collection: $e");
      rethrow;
    }
  }
}
