import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SendFriendRequestScreen extends StatefulWidget {
  const SendFriendRequestScreen({super.key});

  @override
  _SendFriendRequestScreenState createState() => _SendFriendRequestScreenState();
}

class _SendFriendRequestScreenState extends State<SendFriendRequestScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String searchQuery = "";

  // Send friend request
  Future<void> sendFriendRequest(String recipientEmail) async {
    try {
      var currentUser = auth.currentUser!;
      var existingRequest = await firestore
          .collection('friend_requests')
          .where('fromUser', isEqualTo: currentUser.email)
          .where('toUser', isEqualTo: recipientEmail)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Friend request already sent!")),
        );
        return;
      }

      await firestore.collection('friend_requests').add({
        'fromUser': currentUser.email,
        'toUser': recipientEmail,
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Friend request sent!")),
      );
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Send Friend Request")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search by email",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
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
                  return Center(child: Text("Search for a user to send a request."));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs.where(
                  (doc) => doc['email'] != auth.currentUser!.email,
                );

                if (users.isEmpty) {
                  return Center(child: Text("No users found."));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users.elementAt(index);
                    String email = user['email'];

                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text(email),
                      trailing: ElevatedButton(
                        onPressed: () => sendFriendRequest(email),
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
