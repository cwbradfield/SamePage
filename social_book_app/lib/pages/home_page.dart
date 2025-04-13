import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';
import 'package:social_book_app/pages/display_book_page.dart';
import 'package:social_book_app/pages/friend_list.dart';
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
                  Icon(Icons.person, size: 50, color: AppColors().darkBrown),
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
                        "📖 Avid Reader | Book Lover",
                        style: TextStyle(
                            fontSize: 16, color: AppColors().darkBrown),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                                builder: (context) => FriendListScreen()));
                      },
                      child: Text("Friends",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors().darkBrown)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FriendRequestsScreen()));
                      },
                      child: Text("Requests",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors().darkBrown)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SendFriendRequestScreen()));
                      },
                      child: Text("Add Friends",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors().darkBrown)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
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
              height: 180,
              child: StreamBuilder<List<Map<String, dynamic>>>(
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

                  List<Map<String, dynamic>> books = snapshot.data ?? [];

                  if (books.isEmpty) {
                    return Center(
                      child: Text(
                        "No favorite books yet",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors().darkBrown,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      var book = books[index];
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
                  );
                },
              ),
            ),

            SizedBox(
              height: 30,
            ),

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
                    iconColor: AppColors().lightBrown,
                    backgroundColor: Colors.black87,
                    foregroundColor: AppColors().lightBrown,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Favorite Book Card Widget
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
              SizedBox(
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
              SizedBox(
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
}
