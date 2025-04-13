import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_book_app/models/app_colors.dart';
import 'package:social_book_app/models/book_model.dart';
import 'package:social_book_app/pages/display_book_page.dart';
import 'package:social_book_app/services/google_books_service.dart';

class BookSearchScreen extends StatefulWidget {
  BookSearchScreen({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  BookSearchScreenState createState() => BookSearchScreenState();
}

class BookSearchScreenState extends State<BookSearchScreen> {
  TextEditingController searchController = TextEditingController();
  bool searchByTitle = false;
  bool searchByAuthor = false;
  bool searchByISBN = false;

  final GoogleBooksService _booksService = GoogleBooksService();

  List<Book> books = [];
  List<Book> filteredBooks = [];

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
      debugPrint("Error searching books: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().lightBrown,
      appBar: AppBar(
        backgroundColor: AppColors().lightBrown,
        title: Text("Search Books"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Books",
                labelStyle: TextStyle(color: AppColors().darkBrown),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  color: AppColors().darkBrown,
                  onPressed: searchBooks,
                ),
              ),
              onChanged: (value) => searchBooks(),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.only(left: 0, right: 40),
                    title: Text(
                      "Title",
                      style: TextStyle(fontSize: 14),
                    ),
                    value: searchByTitle,
                    onChanged: (value) {
                      setState(() => searchByTitle = value!);
                      searchBooks();
                    },
                    checkColor: AppColors().lightBrown,
                    activeColor: AppColors().darkBrown,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.only(left: 10, right: 20),
                    title: Text(
                      "Author",
                      style: TextStyle(fontSize: 14),
                    ),
                    value: searchByAuthor,
                    onChanged: (value) {
                      setState(() => searchByAuthor = value!);
                      searchBooks();
                    },
                    checkColor: AppColors().lightBrown,
                    activeColor: AppColors().darkBrown,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.only(left: 30, right: 0),
                    title: Text(
                      "ISBN",
                      style: TextStyle(fontSize: 14),
                    ),
                    value: searchByISBN,
                    onChanged: (value) {
                      setState(() => searchByISBN = value!);
                      searchBooks();
                    },
                    checkColor: AppColors().lightBrown,
                    activeColor: AppColors().darkBrown,
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
                  return Card(
                    child: ListTile(
                      leading: book.thumbnail.isNotEmpty
                          ? Image.network(
                              book.thumbnail,
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.book, size: 50);
                              },
                            )
                          : Icon(Icons.book, size: 50),
                      title: Text(book.title),
                      subtitle: Text(
                        "Author: ${book.authors.join(', ')}\nISBN: ${book.isbn}",
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DisplayBookPage(
                              title: book.title,
                              author: book.authors.join(', '),
                              isbn: book.isbn,
                              thumbnail: book.thumbnail,
                              description: book.description,
                            ),
                          ),
                        );
                      },
                    ),
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
