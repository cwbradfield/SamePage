import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';
import 'package:social_book_app/pages/friend_profile.dart';
import 'package:social_book_app/pages/friend_request.dart';
import 'package:social_book_app/pages/send_friend_request.dart';

class FriendListScreen extends StatelessWidget {
  FriendListScreen({super.key});
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Remove Friend Function
  Future<void> removeFriend(String friendUid) async {
    var currentUserUid = auth.currentUser!.uid;

    try {
      // Remove friend from current user's friend list
      await firestore.collection('Users').doc(currentUserUid).update({
        'friends': FieldValue.arrayRemove([friendUid])
      });

      // Remove current user from friend's friend list
      await firestore.collection('Users').doc(friendUid).update({
        'friends': FieldValue.arrayRemove([currentUserUid])
      });

      debugPrint("Friend removed successfully!");
    } catch (e) {
      debugPrint("Error removing friend: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().lightBrown,
      appBar: AppBar(
        title: Text(
          "My Friends",
          style: TextStyle(
              color: AppColors().darkBrown,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors().lightBrown,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: AppColors().darkBrown,
                ),
              ),
            ),
            height: 50,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendRequestsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Requests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors().darkBrown,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendFriendRequestScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Add Friends",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors().darkBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: firestore
                  .collection('Users')
                  .doc(auth.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text("No user data found."));
                }

                var userData =
                    snapshot.data?.data() as Map<String, dynamic>? ?? {};
                List<dynamic> friendUids = userData['friends'] ?? [];

                if (friendUids.isEmpty) {
                  return Center(
                      child: Text(
                    "You have no friends yet.",
                    style: TextStyle(color: Colors.black),
                  ));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('Users')
                      .where(FieldPath.documentId, whereIn: friendUids)
                      .snapshots(),
                  builder: (context, friendSnapshot) {
                    if (!friendSnapshot.hasData) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: AppColors().darkBrown,
                      ));
                    }

                    var friends = friendSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        var friendData =
                            friends[index].data() as Map<String, dynamic>;
                        String friendEmail =
                            friendData['email'] ?? "Unknown User";
                        String friendUid = friends[index].id;

                        return ListTile(
                          leading: CircleAvatar(
                              backgroundColor: AppColors().darkBrown,
                              child: Icon(
                                Icons.person,
                                color: AppColors().lightBrown,
                              )),
                          title: Text(
                            friendEmail,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FriendProfileScreen(
                                      friendUid: friendUid)),
                            );
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              removeFriend(friendUid);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Friend removed"),
                                  backgroundColor: AppColors().darkBrown,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
