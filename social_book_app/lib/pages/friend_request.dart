import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  FriendRequestsScreenState createState() => FriendRequestsScreenState();
}

class FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Accept Friend Request
  Future<void> acceptRequest(String requestId, String fromUser) async {
    try {
      // Update request status to "accepted"
      await firestore.collection('friend_requests').doc(requestId).update({
        'status': 'accepted',
      });

      // Add both users to each other's friend lists using UIDs
      await firestore.collection('Users').doc(user.uid).update({
        'friends': FieldValue.arrayUnion([fromUser]),
      });
      await firestore.collection('Users').doc(fromUser).update({
        'friends': FieldValue.arrayUnion([user.uid]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors().darkBrown,
          content: Text(
            'Friend request accepted!',
            style: TextStyle(color: AppColors().lightBrown, fontSize: 24),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error accepting request: $e');
    }
  }

  // Reject Friend Request
  Future<void> rejectRequest(String requestId) async {
    try {
      // Remove request from Firestore
      await firestore.collection('friend_requests').doc(requestId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors().darkBrown,
          content: Text(
            'Friend request rejected.',
            style: TextStyle(color: AppColors().lightBrown, fontSize: 24),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error rejecting request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().lightBrown,
      appBar: AppBar(
        title: Text("Friend Requests"),
        backgroundColor: AppColors().lightBrown,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('friend_requests')
            .where('toUser', isEqualTo: user.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppColors().darkBrown));
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

              return StreamBuilder<DocumentSnapshot>(
                stream: firestore.collection('Users').doc(fromUser).snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text("Loading..."),
                    );
                  }

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  String fromUserEmail = userData['email'] ?? "Unknown User";

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors().darkBrown,
                        child:
                            Icon(Icons.person, color: AppColors().lightBrown),
                      ),
                      title: Text(fromUserEmail),
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
          );
        },
      ),
    );
  }
}
