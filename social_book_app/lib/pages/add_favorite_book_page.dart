import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/components/textfield.dart';
import 'package:social_book_app/models/app_colors.dart';

class AddFavoriteBookPage extends StatefulWidget {
  const AddFavoriteBookPage({super.key});

  @override
  State<AddFavoriteBookPage> createState() => _AddFavoriteBookPageState();
}

class _AddFavoriteBookPageState extends State<AddFavoriteBookPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final isbnController = TextEditingController();

  void addFavoriteBook() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Map<String, dynamic> newFavoriteBook = {
      'title': titleController.text,
      'author': authorController.text,
      'isbn': isbnController.text,
    };

    try {
      await firestore.collection("Users").doc(uid).update({
        'favoriteBooks': FieldValue.arrayUnion([newFavoriteBook])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Book added successfully!",
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
              Text(
                "Add a book",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 30,
              ),
              MyTextfield(
                controller: titleController,
                hintText: "Title",
                obscureText: false,
              ),
              SizedBox(
                height: 10,
              ),
              MyTextfield(
                controller: authorController,
                hintText: "Author",
                obscureText: false,
              ),
              SizedBox(
                height: 10,
              ),
              MyTextfield(
                controller: isbnController,
                hintText: "ISBN",
                obscureText: false,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Colors.black87)),
                  onPressed: () {
                    addFavoriteBook();
                  },
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
