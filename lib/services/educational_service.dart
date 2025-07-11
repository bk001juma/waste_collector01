import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';

class EducationalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file and returns its download URL.
  Future<String?> uploadFile(File file, String fileName) async {
    try {
      final ref = _storage.ref().child('educational_content/$fileName');

      // Detect MIME type for metadata
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final metadata = SettableMetadata(contentType: mimeType);

      // Upload the file to Firebase Storage
      await ref.putFile(file, metadata);

      // Get the download URL for the uploaded file
      return await ref.getDownloadURL();
    } catch (e) {
      print('File upload error: $e');
      return null;
    }
  }

  /// Adds educational content to Firestore.
  Future<void> addContent({
    required String title,
    required String type,
    required String content,
  }) async {
    // Add the educational content to Firestore
    await _firestore.collection('educational_content').add({
      'title': title.trim(),
      'type': type,
      'content':
          content.trim(), // The content here will be the file URL or text
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates educational content by document ID.
  Future<void> updateContent({
    required String docId,
    required String title,
    required String type,
    required String content,
  }) async {
    try {
      await _firestore.collection('educational_content').doc(docId).update({
        'title': title.trim(),
        'type': type,
        'content': content.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating content: $e');
    }
  }

  /// Deletes educational content by document ID.
  Future<void> deleteContent(String docId) async {
    await _firestore.collection('educational_content').doc(docId).delete();
  }

  /// Gets all educational content as a stream, sorted by created time.
  Stream<QuerySnapshot> getEducationalContent() {
    return _firestore
        .collection('educational_content')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
