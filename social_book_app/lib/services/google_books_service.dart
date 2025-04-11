import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:social_book_app/models/book_model.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static String get _apiKey => dotenv.env['GOOGLE_BOOKS_API_KEY'] ?? '';
  
  // Search books by query
  Future<List<Book>> searchBooks(String query, {int maxResults = 10}) async {
    if (query.isEmpty) return [];
    
    // Build URL with search parameters
    String url = '$_baseUrl?q=$query&maxResults=$maxResults';
    if (_apiKey.isNotEmpty) {
      url += '&key=$_apiKey';
    }
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['items'] != null) {
          return List<Book>.from(
            data['items'].map((item) => Book.fromJson(item))
          );
        }
        return [];
      } else {
        print('API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching books: $e');
      return [];
    }
  }
  
  // Specialized search functions
  Future<List<Book>> searchByTitle(String title, {int maxResults = 10}) async {
    return searchBooks('intitle:$title', maxResults: maxResults);
  }
  
  Future<List<Book>> searchByAuthor(String author, {int maxResults = 10}) async {
    return searchBooks('inauthor:$author', maxResults: maxResults);
  }
  
  Future<List<Book>> searchByISBN(String isbn, {int maxResults = 10}) async {
    return searchBooks('isbn:$isbn', maxResults: maxResults);
  }
  
  // Combined search with filters
  Future<List<Book>> searchWithFilters(String query, {
    bool searchTitle = false,
    bool searchAuthor = false,
    bool searchISBN = false,
    int maxResults = 10,
  }) async {
    if (query.isEmpty) return [];
    
    // If no specific filters are selected, search all
    if (!searchTitle && !searchAuthor && !searchISBN) {
      return searchBooks(query, maxResults: maxResults);
    }
    
    // Build query string with filters
    List<String> queryParts = [];
    
    if (searchTitle) queryParts.add('intitle:$query');
    if (searchAuthor) queryParts.add('inauthor:$query');
    if (searchISBN) queryParts.add('isbn:$query');
    
    String combinedQuery = queryParts.join(' OR ');
    return searchBooks(combinedQuery, maxResults: maxResults);
  }
}