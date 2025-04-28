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
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
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
            return Center(
                child: CircularProgressIndicator(
              color: AppColors().darkBrown,
            ));
          }

          var friendData = snapshot.data!.data() as Map<String, dynamic>;
          String email = friendData['email'] ?? "Unknown User";
          List<dynamic> favoriteBooks = friendData['favoriteBooks'] ?? [];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: AppColors().darkBrown,
                      size: 48,
                    ),
                    SizedBox(width: 8),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),

                // Favorite Books Section
                Text(
                  "📚 Favorite Books",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors().darkBrown,
                  ),
                ),
                SizedBox(height: 10),
                if (favoriteBooks.isEmpty)
                  Column(
                    children: [
                      SizedBox(height: 30),
                      Center(
                        child: Text(
                          "No favorite books yet",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
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
                    color: AppColors().darkBrown,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 300, // Fixed height for the reviews section
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Reviews')
                        .where('userId', isEqualTo: friendUid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: AppColors().darkBrown,
                        ));
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error loading reviews",
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No reviews yet.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }

                      var reviews = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var review = reviews[index];
                          String bookTitle =
                              review['bookTitle'] ?? 'Unknown Book';
                          String reviewText = review['review'] ?? '';

                          // Limit review text to 100 characters
                          String previewText = reviewText.length > 100
                              ? reviewText.substring(0, 100) + '...'
                              : reviewText;

                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookTitle,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors().darkBrown,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    previewText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
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
        },
      ),
    );
  }
}
