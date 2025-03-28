import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/components/search.dart';

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
            // Profile Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                        "https://via.placeholder.com/150"), // Placeholder profile pic
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email!,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFavoriteBookCard("The Hobbit"),
                  _buildFavoriteBookCard("1984"),
                  _buildFavoriteBookCard("Dune"),
                  _buildFavoriteBookCard("Harry Potter"),
                ],
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: BookSearchScreen(),
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
          leading: CircleAvatar(
            backgroundImage: NetworkImage("https://via.placeholder.com/100"),
          ),
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
