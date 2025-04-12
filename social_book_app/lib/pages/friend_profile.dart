import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';

class FriendProfileScreen extends StatelessWidget {
  final String friendUid;

  const FriendProfileScreen({super.key, required this.friendUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().lightBrown,
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('Users')
              .doc(friendUid)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Loading...");
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String email = userData['email'] ?? "Unknown User";
            return Text("${email}'s Profile");
          },
        ),
        backgroundColor: AppColors().lightBrown,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('Users').doc(friendUid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var friendData = snapshot.data!.data() as Map<String, dynamic>;
          String email = friendData['email'] ?? "Unknown User";
          List<dynamic> reviews = friendData['reviews'] ?? [];
          List<dynamic> recommendations = friendData['recommendations'] ?? [];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Email: $email",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),

                // Reviews Section
                Text(
                  "📖 Book Reviews",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                reviews.isEmpty
                    ? Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "No reviews yet.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: reviews.map((review) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                review['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(review['review']),
                              trailing: Text(
                                "⭐ ${review['rating']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                SizedBox(height: 20),

                // Recommendations Section
                Text(
                  "📚 Book Recommendations",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                recommendations.isEmpty
                    ? Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "No recommendations yet.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: recommendations.map((book) {
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.book,
                                color: Colors.brown[700],
                              ),
                              title: Text(
                                book,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
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
