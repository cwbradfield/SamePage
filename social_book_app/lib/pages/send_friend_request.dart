import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';

class SendFriendRequestScreen extends StatefulWidget {
  const SendFriendRequestScreen({super.key});

  @override
  SendFriendRequestScreenState createState() => SendFriendRequestScreenState();
}

class SendFriendRequestScreenState extends State<SendFriendRequestScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String searchQuery = "";

  // Send friend request
  Future<void> sendFriendRequest(String recipientUid) async {
    try {
      var currentUser = auth.currentUser!;
      var existingRequest = await firestore
          .collection('friend_requests')
          .where('fromUser', isEqualTo: currentUser.uid)
          .where('toUser', isEqualTo: recipientUid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Friend request already sent!",
                  style:
                      TextStyle(color: AppColors().lightBrown, fontSize: 24))),
        );
        return;
      }

      await firestore.collection('friend_requests').add({
        'fromUser': currentUser.uid,
        'toUser': recipientUid,
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          "Friend request sent!",
          style: TextStyle(color: AppColors().lightBrown, fontSize: 24),
        )),
      );
    } catch (e) {
      debugPrint('Error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().lightBrown,
      appBar: AppBar(
        title: Text("Send Friend Request"),
        backgroundColor: AppColors().lightBrown,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search by email",
                labelStyle: TextStyle(color: AppColors().darkBrown),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors().darkBrown),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors().darkBrown),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors().darkBrown),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: AppColors().darkBrown),
                  onPressed: () {
                    setState(() {
                      searchQuery = _searchController.text.trim();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchQuery.isEmpty
                  ? null
                  : firestore
                      .collection('Users')
                      .where('email', isGreaterThanOrEqualTo: searchQuery)
                      .where('email', isLessThan: '${searchQuery}z')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: Text("Search for a user to send a request."));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs.where(
                  (doc) => doc.id != auth.currentUser!.uid,
                );

                if (users.isEmpty) {
                  return Center(child: Text("No users found."));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users.elementAt(index);
                    String email = user['email'];
                    String uid = user.id;

                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text(email),
                      trailing: ElevatedButton(
                        onPressed: () => sendFriendRequest(uid),
                        child: Text("Add Friend"),
                      ),
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
