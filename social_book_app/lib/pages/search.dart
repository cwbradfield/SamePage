import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/database/database.dart';

class BookSearchScreen extends StatefulWidget {
  BookSearchScreen({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  BookSearchScreenState createState() => BookSearchScreenState();
}

class BookSearchScreenState extends State<BookSearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredBooks = [];

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void searchBooks() async {
    String query = searchController.text.toLowerCase();
    final books = await Database().fetchBooksOnce();

    setState(() {
      filteredBooks = books.where((book) {
        return book['title'].toLowerCase().contains(query) ||
               book['author'].toLowerCase().contains(query) ||
               book['isbn'].contains(query);}).toList();
  
    // StreamBuilder<List<Map<String, dynamic>>>(
    // stream: Database().getBooks(),
    // builder: (context, snapshot) {
    //   if (!snapshot.hasData) {
    //     return CircularProgressIndicator();
    //   }

    //   final books = snapshot.data!;
    //   filteredBooks = books.where((book) {
    //     final queryLower = query.toLowerCase();
    //     return book['title'].toLowerCase().contains(queryLower) ||
    //            book['author'].toLowerCase().contains(queryLower) ||
    //            book['isbn'].contains(query);
    //   }).toList();

    //   return SizedBox.shrink(); // Return an empty widget as a placeholder
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 186, 146, 109),//Colors.grey[200],
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
      //appBar: AppBar(title: Text("Book Search")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Books by Title, Author, or ISBN",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchBooks,
                ),
              ),
              onChanged: (value) => searchBooks(),
            ),
            
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  var book = filteredBooks[index];
                  return ListTile(
                    title: Text(book["title"]!),
                    subtitle: Text("Author: ${book["author"]} | ISBN: ${book["isbn"]}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
