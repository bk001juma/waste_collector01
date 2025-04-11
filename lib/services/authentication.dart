import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email, password, username, phone, and address
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
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on TimeoutException catch (e, stackTrace) {
      log("Signup timeout", error: e, stackTrace: stackTrace);
      throw FirebaseAuthException(
        code: 'timeout',
        message: 'Request timed out.',
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      log("Firebase signup error", error: e, stackTrace: stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      log("Signup error", error: e, stackTrace: stackTrace);
      throw Exception("An unexpected error occurred.");
    }
  }

  // Login with email and password
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
            message: 'Email or password is incorrect.',
          );
        }
      }

      return null;
    } on TimeoutException catch (e, stackTrace) {
      log("Login timeout", error: e, stackTrace: stackTrace);
      throw FirebaseAuthException(
        code: 'timeout',
        message: 'Request timed out.',
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      log("Firebase login error", error: e, stackTrace: stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      log("Login error", error: e, stackTrace: stackTrace);
      throw Exception("An unexpected error occurred.");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
