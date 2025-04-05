import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';
import 'package:social_book_app/pages/add_favorite_book_page.dart';
import 'package:social_book_app/pages/display_book_page.dart';
import 'package:social_book_app/pages/friend_request.dart';
import 'package:social_book_app/pages/search.dart';
import 'package:social_book_app/database/database.dart';
import 'package:social_book_app/pages/send_friend_request.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().lightBrown,
      appBar: AppBar(
        backgroundColor: AppColors().lightBrown,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(
              Icons.logout,
              color: AppColors().darkBrown,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // CircleAvatar(
                  //   radius: 40,
                  //   backgroundImage: NetworkImage(
                  //       "https://via.placeholder.com/150"), // Placeholder profile pic
                  // ),
                  Icon(Icons.person),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email!,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "📖 Avid Reader | Book Lover", // should add DB field for profile text/byline
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Favorite Books Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "📚 Favorite Books",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 120,
              child: StreamBuilder<List<String>>(
                stream: Database().getFavoriteBooks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: AppColors().darkBrown,
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading books"));
                  }

                  List<String> bookTitles = snapshot.data ?? [];

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookTitles.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DisplayBookPage(
                                        title: bookTitles[index])));
                          },
                          child: _buildFavoriteBookCard(bookTitles[index]));
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black87)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddFavoriteBookPage()));
                  },
                  child: Text(
                    "Add a favorite book",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            // Recent Reviews Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "📝 Recent Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Database().getUserReviews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: AppColors().darkBrown,
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading reviews"));
                  }

                  final reviews = snapshot.data!;

                  return ListView(
                    children: reviews.map((entry) {
                      return _buildReviewItem(entry['title'], entry['review']);
                    }).toList(),
                  );
                },
              ),
            ),
            // _buildReviewItem("The Hobbit", "Loved the adventure! 🌟🌟🌟🌟🌟"),
            // _buildReviewItem("Dune", "A masterpiece of sci-fi. 🌟🌟🌟🌟"),

            // Book Search
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookSearchScreen()),
                    );
                  },
                  icon: Icon(Icons.search),
                  label: Text("Search for Books"),
                  style: ElevatedButton.styleFrom(
                    iconColor: AppColors().darkBrown,
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            // Friends List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "👥 Friends",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: StreamBuilder<List<String>>(
                stream: Database().getFriends(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: AppColors().darkBrown,
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading friends"));
                  }

                  List<String> friends = snapshot.data ?? [];

                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      return _buildFriendItem(friends[index]);
                    },
                  );
                },
              ),
            ),

            // View Friends  --no longer needed if above friends list works
            // Padding(
            //   padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       style: ButtonStyle(
            //           backgroundColor: WidgetStatePropertyAll(Colors.black87)),
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => FriendListScreen()),
            //         );
            //       },
            //       child: Text("View Friends",
            //           style: TextStyle(color: Colors.white)),
            //     ),
            //   ),
            // ),

            // Friend Requests
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black87)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FriendRequestsScreen()),
                    );
                  },
                  child: Text(
                    "View Friend Requests",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            // Add Friends
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black87)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SendFriendRequestScreen()),
                    );
                  },
                  child: Text("Add Friends",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Favorite Book Card Widget
  Widget _buildFavoriteBookCard(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, size: 40, color: Colors.brown),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // Review Item Widget
  Widget _buildReviewItem(String bookTitle, String reviewText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.star, color: Colors.amber),
          title: Text(bookTitle, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(reviewText),
        ),
      ),
    );
  }

  // Friend Item Widget
  Widget _buildFriendItem(String email) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          // leading: CircleAvatar(
          //   backgroundImage: NetworkImage("https://via.placeholder.com/100"),
          // ),

          leading: Icon(Icons.person),
          title: Text(email, style: TextStyle(fontWeight: FontWeight.bold)),
          
          // trailing: IconButton(  --could potentially be used in send_friend_request to add friend
          //   icon: Icon(Icons.person_add, color: Colors.blue),
          //   onPressed: () {
          //     Navigator.push(context,MaterialPageRoute(
          //       builder: (context) => FriendRequestsScreen()));
          //   },
          // ),
        ),
      ),
    );
  }
}
