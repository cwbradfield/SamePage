import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/components/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<DocumentSnapshot> userDoc;

  @override
  void initState() {
    super.initState();
    userDoc = FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
  }

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
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("User data not found."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
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
                        backgroundImage: NetworkImage(userData['profilePicUrl'] ?? "https://via.placeholder.com/150"),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['name'] ?? user.email!,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userData['bio'] ?? "📖 Avid Reader | Book Lover",
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
                  child: Text("📚 Favorite Books", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: (userData['favoriteBooks'] as List<dynamic>? ?? [])
                        .map((book) => _buildFavoriteBookCard(book))
                        .toList(),
                  ),
                ),

                // Recent Reviews Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("📝 Recent Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...(userData['recentReviews'] as List<dynamic>? ?? [])
                    .map((review) => _buildReviewItem(review['book'], review['review']))
                    ,

                // Friends List
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("👥 Friends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...(userData['friends'] as List<dynamic>? ?? [])
                    .map((friend) => _buildFriendItem(friend))
                    ,

                // Book Search Button
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookSearchScreen()),
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
          );
        },
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
  Widget _buildFriendItem(String friendEmail) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage("https://via.placeholder.com/100"),
          ),
          title: Text(friendEmail, style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: IconButton(
            icon: Icon(Icons.person_remove, color: Colors.red),
            onPressed: () {
              // TODO: Implement remove friend functionality
            },
          ),
        ),
      ),
    );
  }
}
