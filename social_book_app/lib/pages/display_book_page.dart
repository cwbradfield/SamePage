import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/database/database.dart';
import 'package:social_book_app/models/app_colors.dart';

class DisplayBookPage extends StatefulWidget {
  const DisplayBookPage({required this.title, super.key});
  final String title;

  @override
  State<DisplayBookPage> createState() => _DisplayBookPageState();
}

class _DisplayBookPageState extends State<DisplayBookPage> {
  final reviewController = TextEditingController();

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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().lightBrown,
      appBar: AppBar(
        backgroundColor: AppColors().lightBrown,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Text(
                  widget.title,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  "Book Author",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 550,
                child: StreamBuilder<List<String>>(
                  stream: Database().getAllReviews(widget.title),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
