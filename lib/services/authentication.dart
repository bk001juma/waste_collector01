import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter for Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Sign up a new user with email, password, and profile details.
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String phone,
    required String address,
  }) async {
    try {
      final result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      final user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'phone': phone,
          'address': address,
          'role': 'user', // 🔒 Force regular user role
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on TimeoutException catch (e, stackTrace) {
      log("Signup timeout", error: e, stackTrace: stackTrace);
      throw FirebaseAuthException(
        code: 'timeout',
        message: 'Request timed out. Please try again.',
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      log("Firebase signup error", error: e, stackTrace: stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      log("Unexpected signup error", error: e, stackTrace: stackTrace);
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  /// Sign in an existing user with email and password.
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      final user = result.user;

      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          return user;
        } else {
          await _auth.signOut();
          throw FirebaseAuthException(
            code: 'user-not-allowed',
            message: 'User profile not found.',
          );
        }
      }

      return null;
    } on TimeoutException catch (e, stackTrace) {
      log("Login timeout", error: e, stackTrace: stackTrace);
      throw FirebaseAuthException(
        code: 'timeout',
        message: 'Login timed out. Please try again.',
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      log("Firebase login error", error: e, stackTrace: stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      log("Unexpected login error", error: e, stackTrace: stackTrace);
      throw Exception("An unexpected error occurred during login.");
    }
  }

  /// Sign out the currently logged-in user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get the currently signed-in user, if any.
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
  /// Check how many pickups the user has scheduled for a given date
  Future<int> getUserScheduleCountForDate(DateTime date) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    throw Exception("User not authenticated");
  }

  try {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _firestore
        .collection('waste_pickups')
        .where('userId', isEqualTo: currentUser.uid)
        .where('pickupDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('pickupDate', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return querySnapshot.docs.length;
  } catch (e) {
    log("Error checking schedule count: $e");
    throw Exception("Failed to fetch schedule count");
  }
}

}
