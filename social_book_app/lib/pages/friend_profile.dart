import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';
import 'package:social_book_app/pages/display_book_page.dart';

class FriendProfileScreen extends StatelessWidget {
  final String friendUid;

  const FriendProfileScreen({super.key, required this.friendUid});

  Widget _buildFavoriteBookCard(String title, String thumbnail) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 120,
          height: 180,
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 80,
                child: thumbnail.isNotEmpty
                    ? Image.network(
                        thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.book,
                              size: 40, color: Colors.brown);
                        },
                      )
                    : Icon(Icons.book, size: 40, color: Colors.brown),
              ),
              SizedBox(height: 8),
              Container(
                height: 40,
                child: Text(
                  title.isNotEmpty ? title : "No title",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            return Text("$email's Profile");
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
          List<dynamic> favoriteBooks = friendData['favoriteBooks'] ?? [];

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

                // Favorite Books Section
                Text(
                  "📚 Favorite Books",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                if (favoriteBooks.isEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "No favorite books yet.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: favoriteBooks.length,
                      itemBuilder: (context, index) {
                        var book = favoriteBooks[index] as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisplayBookPage(
                                  title: book['title'] ?? '',
                                  author: book['author'] ?? '',
                                  isbn: book['isbn'] ?? '',
                                  thumbnail: book['thumbnail'] ?? '',
                                  description: book['description'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: _buildFavoriteBookCard(
                            book['title'] ?? '',
                            book['thumbnail'] ?? '',
                          ),
                        );
                      },
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
