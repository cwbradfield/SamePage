import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<String>> getFavoriteBooks() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return _firestore.collection('Users').doc(uid).snapshots().map((snapshot) {
      List<dynamic> favoriteBooks = snapshot['favoriteBooks'] ?? [];

      return favoriteBooks.map((favoriteBook) => favoriteBook['title'] as String).toList();
    });
  }

  Stream<List<String>> getFriends() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return _firestore.collection('Users').doc(uid).snapshots().map((snapshot) {
      List<dynamic> friends = snapshot.data()?['friends'] ?? [];

      //return friends.map((friend) => friend as String).toList();
      return friends.cast<String>().toList();
    });
  }

  Stream<List<String>> getAllReviews(String bookTitle) {
    return _firestore.collection('Reviews').where(
      'title',isEqualTo: bookTitle).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['review'] as String).toList();
    });
  }
  
  Stream<List<Map<String, dynamic>>> getUserReviews() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return _firestore.collection('Users').doc(uid).snapshots().map((snapshot) {
      List<dynamic> reviews = snapshot.data()?['Reviews'] ?? [];

      // Convert each item to a map with title and review
    return reviews.map<Map<String, dynamic>>((review) {
      return {
        'title': review['title'] ?? 'Unknown Title',
        'review': review['review'] ?? '',
      };
    }).take(3).toList();
    });
  }
}
