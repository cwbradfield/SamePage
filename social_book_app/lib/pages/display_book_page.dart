import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/database/database.dart';
import 'package:social_book_app/models/app_colors.dart';

class DisplayBookPage extends StatefulWidget {
  const DisplayBookPage({
    required this.title,
    required this.author,
    required this.isbn,
    required this.thumbnail,
    required this.description,
    super.key,
  });

  final String title;
  final String author;
  final String isbn;
  final String thumbnail;
  final String description;

  @override
  State<DisplayBookPage> createState() => _DisplayBookPageState();
}

class _DisplayBookPageState extends State<DisplayBookPage> {
  final reviewController = TextEditingController();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      var favoriteBooks = userDoc.data()?['favoriteBooks'] ?? [];
      setState(() {
        isFavorite = favoriteBooks.any((book) => book['title'] == widget.title);
      });
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  Future<void> toggleFavorite() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Map<String, dynamic> bookData = {
        'title': widget.title,
        'author': widget.author,
        'isbn': widget.isbn,
        'thumbnail': widget.thumbnail,
        'description': widget.description,
      };

      if (isFavorite) {
        await firestore.collection('Users').doc(uid).update({
          'favoriteBooks': FieldValue.arrayRemove([bookData])
        });
      } else {
        await firestore.collection('Users').doc(uid).update({
          'favoriteBooks': FieldValue.arrayUnion([bookData])
        });
      }

      setState(() {
        isFavorite = !isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? "Book added to favorites!"
                : "Book removed from favorites.",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          backgroundColor: AppColors().darkBrown,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  void addReview(String reviewText) async {
    try {
      await FirebaseFirestore.instance.collection("Reviews").add({
        'title': widget.title,
        'review': reviewText,
        'user': FirebaseAuth.instance.currentUser!.email
      });

      reviewController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Review added successfully!",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          backgroundColor: AppColors().darkBrown,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().lightBrown,
      appBar: AppBar(
        backgroundColor: AppColors().lightBrown,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black87,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.thumbnail.isNotEmpty)
                Image.network(
                  widget.thumbnail,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.book, size: 200);
                  },
                ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "By ${widget.author}",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    if (widget.description.isNotEmpty) ...[
                      Text(
                        "Description:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reviews",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 550,
                      child: StreamBuilder<List<String>>(
                        stream: Database().getAllReviews(widget.title),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: AppColors().darkBrown,
                            ));
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text("No reviews yet");
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text("Error loading reviews"));
                          }

                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return _buildReviewItem(snapshot.data![index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                child: TextField(
                  controller: reviewController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black87)),
                      fillColor: Colors.grey[200],
                      filled: true,
                      hintText: 'Leave a review',
                      hintStyle: TextStyle(color: Colors.grey[600])),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(Colors.black87)),
                onPressed: () {
                  addReview(reviewController.text);
                },
                child: Text(
                  "Add review",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(String reviewText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.star, color: Colors.amber),
          title: Text(reviewText),
        ),
      ),
    );
  }
}
