import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';

class DisplayBookPage extends StatefulWidget {
  const DisplayBookPage({super.key});

  @override
  State<DisplayBookPage> createState() => _DisplayBookPageState();
}

class _DisplayBookPageState extends State<DisplayBookPage> {
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
                  "Book Clicked On Title",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Center(
                child: Text(
                  "Book Clicked On Author",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Colors.black87)),
                  onPressed: () {
                    // WRITE REVIEW PAGE
                    //
                    //
                    //
                  },
                  child: Text(
                    "Add a review",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
