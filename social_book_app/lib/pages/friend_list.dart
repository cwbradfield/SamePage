import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendListScreen extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Friends")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('Users').doc(auth.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
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
                  // Navigate to friend's profile (to be implemented)
                },
              );
            },
          );
        },
      ),
    );
  }
}
