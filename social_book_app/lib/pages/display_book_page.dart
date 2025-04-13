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
  bool _isLoading = false;
  Stream<List<Map<String, dynamic>>>? _reviewsStream;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _initializeReviewsStream();
  }

  void _initializeReviewsStream() {
    if (mounted) {
      setState(() {
        _reviewsStream = Database().getBookReviews(widget.title);
      });
    }
  }

  @override
  void didUpdateWidget(DisplayBookPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _initializeReviewsStream();
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
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

  Future<void> _deleteReview(String reviewId) async {
    try {
      await Database().deleteReview(reviewId);
      _initializeReviewsStream();
    } catch (e) {
      debugPrint('Error deleting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error deleting review. Please try again.",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    bool isCurrentUser =
        review['userId'] == FirebaseAuth.instance.currentUser!.uid;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.person, color: AppColors().darkBrown),
          title: Text(
            review['user'] ?? 'Anonymous',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors().darkBrown,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review['review'] ?? ''),
              SizedBox(height: 4),
              Text(
                _formatTimestamp(review['timestamp'] as Timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: isCurrentUser
              ? IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteReview(review['id']),
                )
              : null,
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<bool> _checkForReviews() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Reviews')
          .where('bookTitle', isEqualTo: widget.title)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking for reviews: $e');
      return false;
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
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Image.network(
                    widget.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.book, size: 200);
                    },
                  ),
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
                        color: AppColors().darkBrown,
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
              Divider(color: AppColors().darkBrown),
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
                      child: FutureBuilder<bool>(
                        future: _checkForReviews(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors().darkBrown,
                              ),
                            );
                          }

                          if (!snapshot.hasData || !snapshot.data!) {
                            return Center(
                              child: Text(
                                "No reviews yet",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors().darkBrown,
                                ),
                              ),
                            );
                          }

                          return StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _reviewsStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Error loading reviews",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors().darkBrown,
                                  ),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text(
                                    "No reviews yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return _buildReviewItem(
                                      snapshot.data![index]);
                                },
                              );
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
                      borderSide: BorderSide(color: Colors.black87),
                    ),
                    fillColor: Colors.grey[200],
                    filled: true,
                    hintText: 'Leave a review',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(Colors.black87),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (reviewController.text.trim().isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                            });
                            Database()
                                .addReview(
                                    widget.title, reviewController.text.trim())
                                .then((_) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                  reviewController.clear();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Review added successfully!",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    backgroundColor: AppColors().darkBrown,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }).catchError((error) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Error adding review. Please try again.",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            });
                          }
                        },
                  child: Text(
                    _isLoading ? "Adding review..." : "Add review",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
