import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Total number of users
  Future<int> getTotalUsers() async {
    final users = await _firestore.collection('users').get();
    return users.docs.length;
  }

  /// Total number of scheduled pickups (from 'waste_pickups')
  Future<int> getScheduledPickups() async {
    final pickups = await _firestore.collection('waste_pickups').get();
    return pickups.docs.length;
  }

  /// Number of pickup requests that are marked as 'Picked Up'
  Future<int> getPickedUpRequests() async {
    final snapshot = await _firestore
        .collection('waste_pickups')
        .where('status', isEqualTo: 'Picked Up')
        .get();
    return snapshot.docs.length;
  }

  /// Number of pickup requests that are still 'Pending'
  Future<int> getPendingPickupsCount() async {
    final snapshot = await _firestore
        .collection('waste_pickups')
        .where('status', isEqualTo: 'Pending')
        .get();
    return snapshot.docs.length;
  }

  /// Optional: total messages if you're using messaging feature
  Future<int> getPendingMessages() async {
    final messages = await _firestore.collection('messages').get();
    return messages.docs.length;
  }

  /// Paginated list of 'Pending' pickups
  Future<List<QueryDocumentSnapshot>> fetchPendingPickupsPaginated({
    required int pageSize,
    QueryDocumentSnapshot? startAfterDoc,
  }) async {
    try {
      Query query = _firestore
          .collection('waste_pickups')
          .where('status', isEqualTo: 'Pending')
          .orderBy('pickupDate', descending: true)
          .limit(pageSize);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print("Error fetching paginated pending pickups: $e");
      throw Exception("Failed to fetch paginated pending pickups");
    }
  }
  /// Update pickup status
Future<void> updatePickupStatus(String docId, String newStatus) async {
  try { 
    await _firestore.collection('waste_pickups').doc(docId).update({  
      'status': newStatus,
    });
  } catch (e) {
    print('Error updating status: $e');
    throw Exception("Failed to update status");
  }
}

/// Cancel (delete) a scheduled pickup
Future<void> cancelWasteCollection(String docId) async {
  try {
    await _firestore.collection('waste_pickups').doc(docId).delete();
  } catch (e) {
    print('Error deleting pickup: $e');
    throw Exception("Failed to delete pickup");
  }
}

}
