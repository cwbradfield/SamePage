import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getFavoriteBooks() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return _firestore.collection('Users').doc(uid).snapshots().map((snapshot) {
      List<dynamic> favoriteBooks = snapshot['favoriteBooks'] ?? [];
      return favoriteBooks.map((book) => book as Map<String, dynamic>).toList();
    });
  }

  //
  //
  // REVIEW FUNCTIONS
  //
  //

  Stream<List<Map<String, dynamic>>> getBookReviews(String bookTitle) {
    return _firestore
        .collection('Reviews')
        .where('bookTitle', isEqualTo: bookTitle)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map<List<Map<String, dynamic>>>((snapshot) {
      if (snapshot.docs.isEmpty) {
        return <Map<String, dynamic>>[];
      }
      return snapshot.docs.map<Map<String, dynamic>>((doc) {
        var data = doc.data();
        return {
          'id': doc.id,
          'review': data['review'] ?? '',
          'user': data['user'] ?? 'Anonymous',
          'userId': data['userId'] ?? '',
          'timestamp': data['timestamp'] ?? Timestamp.now(),
        };
      }).toList();
    }).handleError((error) {
      debugPrint('Error getting reviews: $error');
      return <Map<String, dynamic>>[];
    });
  }

  Future<void> addReview(String bookTitle, String reviewText) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String userEmail =
          FirebaseAuth.instance.currentUser!.email ?? 'Anonymous';

      // Add the review
      await _firestore.collection('Reviews').add({
        'bookTitle': bookTitle,
        'review': reviewText,
        'user': userEmail,
        'userId': uid,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('Reviews').doc(reviewId).delete();
    } catch (e) {
      debugPrint('Error deleting review: $e');
      rethrow;
    }
  }
}
