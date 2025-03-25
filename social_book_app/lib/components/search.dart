import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: BookSearchScreen(),
  ));
}

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  BookSearchScreenState createState() => BookSearchScreenState();
}

class BookSearchScreenState extends State<BookSearchScreen> {
  TextEditingController searchController = TextEditingController();
  bool searchByTitle = false;
  bool searchByAuthor = false;
  bool searchByISBN = false;

  List<Map<String, String>> books = [ // connect to firebase instead
    {"title": "The Hobbit", "author": "J.R.R. Tolkien", "isbn": "9780345339683"},
    {"title": "1984", "author": "George Orwell", "isbn": "9780451524935"},
    {"title": "Dune", "author": "Frank Herbert", "isbn": "9780441013593"},
  ];

  List<Map<String, String>> filteredBooks = [];

  void searchBooks() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredBooks = books.where((book) {
        if (!searchByTitle && !searchByAuthor && !searchByISBN) {
          // If no filters selected, search all fields
          return book.values.any((value) => value.toLowerCase().contains(query));
        }
        // Apply selected filters
        return (searchByTitle && book["title"]!.toLowerCase().contains(query)) ||
               (searchByAuthor && book["author"]!.toLowerCase().contains(query)) ||
               (searchByISBN && book["isbn"]!.toLowerCase().contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Search")),
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
