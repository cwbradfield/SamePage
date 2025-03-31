import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendProfileScreen extends StatelessWidget {
  final String friendEmail;

  const FriendProfileScreen({super.key, required this.friendEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Friend's Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Users').doc(friendEmail).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var friendData = snapshot.data!.data() as Map<String, dynamic>;
          String username = friendData['email'] ?? "Unknown User";
          List<dynamic> reviews = friendData['reviews'] ?? [];
          List<dynamic> recommendations = friendData['recommendations'] ?? [];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Email: $friendEmail", style: TextStyle(fontSize: 16, color: Colors.grey)),
                Divider(),

                // Reviews Section
                Text("📖 Book Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                reviews.isEmpty
                    ? Text("No reviews yet.")
                    : Column(
                        children: reviews.map((review) {
                          return Card(
                            child: ListTile(
                              title: Text(review['title']),
                              subtitle: Text(review['review']),
                              trailing: Text("⭐ ${review['rating']}"),
                            ),
                          );
                        }).toList(),
                      ),
                Divider(),

                // Recommendations Section
                Text("📚 Book Recommendations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                recommendations.isEmpty
                    ? Text("No recommendations yet.")
                    : Column(
                        children: recommendations.map((book) {
                          return ListTile(
                            leading: Icon(Icons.book),
                            title: Text(book),
                          );
                        }).toList(),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
