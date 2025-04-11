class Book {
  final String id; 
  final String title; 
  final List<String> authors;
  final String publisher;
  final String publishedDate;
  final String description;
  final String thumbnail;
  final String isbn;

  Book({
    required this.id,
    required this.title,
    required this.authors, 
    this.publisher = '',
    this.publishedDate = '',
    this.description = '',
    this.thumbnail = '',
    this.isbn = '',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    var volumeInfo = json['volumeInfo'] ?? {}; 
    var identifiers = volumeInfo['industryIdentifiers'] ?? [];
    String isbn = '';

    for (var identifier in identifiers) {
      if (identifier['type'] == 'ISBN_13') {
        isbn = identifier['identifier'] ?? '';
        break; 
      } else if (identifier['type'] == 'ISBN_10 && isbn.isEmpty') {
        isbn = identifier['identifier'] ?? '';
      }
    }

    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Unknown Title',
      authors: volumeInfo['authors'] != null 
          ? List<String>.from(volumeInfo['authors']) 
          : ['Unknown Author'],
      publisher: volumeInfo['publisher'] ?? '',
      publishedDate: volumeInfo['publishedDate'] ?? '',
      description: volumeInfo['description'] ?? '',
      thumbnail: volumeInfo['imageLinks'] != null 
          ? volumeInfo['imageLinks']['thumbnail'] ?? '' 
          : '',
      isbn: isbn,
    );
  }

  Map<String, String> toMap() {
    return {
      "title": title,
      "author": authors.isNotEmpty ? authors.join(', ') : 'Unknown Author',
      "isbn": isbn,
    };
  }
}