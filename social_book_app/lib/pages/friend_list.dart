import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';
import 'friend_profile.dart';

class FriendListScreen extends StatelessWidget {
  FriendListScreen({super.key});
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Remove Friend Function
  Future<void> removeFriend(String friendEmail) async {
    var currentUserEmail = auth.currentUser!.email!;

    try {
      // Remove friend from current user's friend list
      await firestore.collection('Users').doc(currentUserEmail).update({
        'friends': FieldValue.arrayRemove([friendEmail])
      });

      // Remove current user from friend's friend list
      await firestore.collection('Users').doc(friendEmail).update({
        'friends': FieldValue.arrayRemove([currentUserEmail])
      });

      print("Friend removed successfully!");
    } catch (e) {
      print("Error removing friend: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().lightBrown,
      appBar: AppBar(
        title: Text("My Friends"),
        backgroundColor: AppColors().lightBrown,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore
            .collection('Users')
            .doc(auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          print("Snapshot: ${snapshot}");
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No user data found."));
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          List<dynamic> friends = userData['friends'] ?? [];

          if (friends.isEmpty) {
            return Center(child: Text("You have no friends yet."));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              String friendEmail = friends[index];

              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(friendEmail),
                onTap: () {
                  print("THIS IS FRIENDS EMAIL: $friendEmail");
                  // Navigate to Friend Profile Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FriendProfileScreen(friendEmail: friendEmail)),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    removeFriend(friendEmail);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Friend removed")),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
