import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/book_model.dart';
import 'package:social_book_app/services/google_books_service.dart';

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

  final GoogleBooksService _booksService = GoogleBooksService();
  // bool _apiTested = false; // Just had this in there for testing purposes
  // String _apiTestResult = "";

  List<Book> books = [];
  List<Book> filteredBooks = [];

// Test to see if API was connected
  // @override
  // void initState() {
  //   super.initState();
  //   _testApiConnection();
  // }

  // Future<void> _testApiConnection() async {
  //   try {
  //     final books = await _booksService.searchBooks('Harry Potter', maxResults: 3);
  //     setState(() {
  //       _apiTested = true;
  //       _apiTestResult = "API Test: Found ${books.length} books. First book: ${books.isNotEmpty ? books[0].title : 'None'}";
  //       print(_apiTestResult); // Also print to console for debugging
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _apiTested = true;
  //       _apiTestResult = "API Test Failed: $e";
  //       print(_apiTestResult); // Also print to console for debugging
  //     });
  //   }
  // }

  void searchBooks() async {
    String query = searchController.text.toLowerCase();

    setState(() {
      books = [];
    });

    try {
      final results = await _booksService.searchWithFilters(
        query,
        searchTitle: searchByTitle,
        searchAuthor: searchByAuthor,
        searchISBN: searchByISBN,
      );
      setState(() {
        books = results;
      });
    } catch (e) {
      print("Error searching books: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 186, 146, 109), //Colors.grey[200],
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
                itemCount: books.length,
                itemBuilder: (context, index) {
                  var book = books[index];
                  return ListTile(
                    title: Text(book.title),
                    subtitle:
                        Text("Author: ${book.authors} | ISBN: ${book.isbn}"),
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
