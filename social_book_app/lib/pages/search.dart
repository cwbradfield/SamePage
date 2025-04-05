import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookSearchScreen extends StatefulWidget {
  BookSearchScreen({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  BookSearchScreenState createState() => BookSearchScreenState();
}

class BookSearchScreenState extends State<BookSearchScreen> {
  TextEditingController searchController = TextEditingController();
  bool searchByTitle = false;
  bool searchByAuthor = false;
  bool searchByISBN = false;

  List<Map<String, String>> filteredBooks = [];

  void searchBooks() async {
  String query = searchController.text.toLowerCase();

  Query firestoreQuery = FirebaseFirestore.instance.collection('Books');

  if (query.isEmpty) {
    setState(() => filteredBooks = []);
    return;
  }

  if (searchByTitle) {
    firestoreQuery = firestoreQuery
        .where('title', isGreaterThanOrEqualTo: query);
        //.where('title', isLessThanOrEqualTo: '$query\uf8ff');
  } else if (searchByAuthor) {
    firestoreQuery = firestoreQuery
        .where('author', isGreaterThanOrEqualTo: query);
        //.where('author', isLessThanOrEqualTo: '$query\uf8ff');
  } else if (searchByISBN) {
    firestoreQuery = firestoreQuery
        .where('isbn', isGreaterThanOrEqualTo: query);
        //.where('isbn', isLessThanOrEqualTo: '$query\uf8ff');
  }

  final snapshot = await firestoreQuery.get();

  setState(() {
    filteredBooks = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "title": (data['title'] ?? '').toString(),
        "author": (data['author'] ?? '').toString(),
        "isbn": (data['isbn'] ?? '').toString(),
      };
    }).toList();
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
            onPressed: BookSearchScreen().signUserOut,
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
                labelText: "Search Books",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchBooks,
                ),
              ),
              onChanged: (value) => searchBooks(),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Title"),
                    value: searchByTitle,
                    onChanged: (value) {
                      setState(() => searchByTitle = value!);
                      searchBooks();
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Author"),
                    value: searchByAuthor,
                    onChanged: (value) {
                      setState(() => searchByAuthor = value!);
                      searchBooks();
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("ISBN"),
                    value: searchByISBN,
                    onChanged: (value) {
                      setState(() => searchByISBN = value!);
                      searchBooks();
                    },
                  ),
                ),
              ],
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
