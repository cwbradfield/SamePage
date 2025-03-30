import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Accept Friend Request
  Future<void> acceptRequest(String requestId, String fromUser) async {
    try {
      // Update request status to "accepted"
      await firestore.collection('friend_requests').doc(requestId).update({
        'status': 'accepted',
      });

      // Add both users to each other's friend lists
      await firestore.collection('Users').doc(user.uid).update({
        'friends': FieldValue.arrayUnion([fromUser]),
      });
      await firestore.collection('Users').doc(fromUser).update({
        'friends': FieldValue.arrayUnion([user.email]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request accepted!')),
      );
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  // Reject Friend Request
  Future<void> rejectRequest(String requestId) async {
    try {
      // Remove request from Firestore
      await firestore.collection('friend_requests').doc(requestId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request rejected.')),
      );
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Friend Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('friend_requests')
            .where('toUser', isEqualTo: user.email)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No pending friend requests."));
          }

          var requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              var requestId = request.id;
              var fromUser = request['fromUser'];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text(fromUser),
                  subtitle: Text("Wants to be your friend!"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => acceptRequest(requestId, fromUser),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => rejectRequest(requestId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
