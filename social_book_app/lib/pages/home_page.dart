import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';
import 'package:social_book_app/pages/add_favorite_book_page.dart';
import 'package:social_book_app/pages/display_book_page.dart';
import 'package:social_book_app/pages/search.dart';
import 'package:social_book_app/database/database.dart';

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
                        "📖 Avid Reader | Book Lover",
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
                    return Center(child: CircularProgressIndicator());
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
                                    builder: (context) =>

                                        // DOES NOT WORK
                                        DisplayBookPage()));
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
                    "Add a book",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 100,
            ),

            // Recent Reviews Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "📝 Recent Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildReviewItem("The Hobbit", "Loved the adventure! 🌟🌟🌟🌟🌟"),
            _buildReviewItem("Dune", "A masterpiece of sci-fi. 🌟🌟🌟🌟"),

            // Friends List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "👥 Friends",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFriendItem("Alice Johnson", "alice@example.com"),
            _buildFriendItem("Bob Smith", "bob@example.com"),

            // Book Search
            // Padding(
            //   padding: EdgeInsets.symmetric(vertical: 16),
            //   child: BookSearchScreen(),
            // ),
            // Book Search Button
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
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
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
  Widget _buildFriendItem(String name, String email) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          // leading: CircleAvatar(
          //   backgroundImage: NetworkImage("https://via.placeholder.com/100"),
          // ),

          leading: Icon(Icons.person),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(email),
          trailing: IconButton(
            icon: Icon(Icons.person_add, color: Colors.blue),
            onPressed: () {
              // TODO: Implement add friend functionality
            },
          ),
        ),
      ),
    );
  }
}
