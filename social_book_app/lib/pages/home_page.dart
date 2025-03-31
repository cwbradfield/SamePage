import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/components/search.dart';
import 'friend_request.dart';
import 'send_friend_request.dart';
import 'friend_list.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 186, 146, 109),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(
              Icons.logout,
              color: Color.fromARGB(255, 66, 37, 10),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Logged in as: ${user.email!}",
                style: TextStyle(fontSize: 22),
              ),
            ),
            // Button to go to Search Screen
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookSearchScreen()),
                  );
                },
                child: Text("Search for Books"),
              ),
            ),
            // Button to go to Friend List Screen
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FriendListScreen()),
                  );
                },
                child: Text("View Friends"),
              ),
            ),
            // Button to go to Friend Requests Screen
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FriendRequestsScreen()),
                  );
                },
                child: Text("View Friend Requests"),
              ),
            ),
            // Button to go to Send Friend Request Screen
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SendFriendRequestScreen()),
                  );
                },
                child: Text("Add Friends"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
