import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';
import 'package:social_book_app/pages/display_book_page.dart';
import 'package:social_book_app/pages/friend_list.dart';
import 'package:social_book_app/pages/search.dart';
import 'package:social_book_app/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

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
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors().darkBrown,
        selectedItemColor: AppColors().lightBrown,
        unselectedItemColor: const Color.fromARGB(255, 241, 213, 200),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return FriendListScreen();
      case 2:
        return BookSearchScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
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
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Favorite Books Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "📚 Favorite Books",
              style: TextStyle(
                  color: AppColors().darkBrown,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
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
                        color: Colors.black,
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

          SizedBox(height: 30),

          // Reviews Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "📖 My Reviews",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors().darkBrown,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 300, // Fixed height for the reviews section
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Reviews')
                  .where('userId', isEqualTo: user.uid)
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
                      "No reviews yet",
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
                    String bookTitle = review['bookTitle'] ?? 'Unknown Book';
                    String reviewText = review['review'] ?? '';

                    // Limit review text to 100 characters
                    String previewText = reviewText.length > 100
                        ? reviewText.substring(0, 100) + '...'
                        : reviewText;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
