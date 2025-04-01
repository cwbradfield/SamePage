import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<String>> getFavoriteBooks() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return _firestore.collection('Users').doc(uid).snapshots().map((snapshot) {
      List<dynamic> favoriteBooks = snapshot['favoriteBooks'] ?? [];

      return favoriteBooks
          .map((favoriteBook) => favoriteBook['title'] as String)
          .toList();
    });
  }

  Stream<List<String>> getAllReviews(String bookTitle) {
    return _firestore.collection('Reviews').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['review'] as String).toList();
    });
  }
}
