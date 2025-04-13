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

    // Get the highest quality image available
    String imageUrl = '';
    if (volumeInfo['imageLinks'] != null) {
      if (volumeInfo['imageLinks']['medium'] != null) {
        imageUrl = volumeInfo['imageLinks']['medium'];
      } else if (volumeInfo['imageLinks']['large'] != null) {
        imageUrl = volumeInfo['imageLinks']['large'];
      } else if (volumeInfo['imageLinks']['thumbnail'] != null) {
        imageUrl = volumeInfo['imageLinks']['thumbnail'];
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
      thumbnail: imageUrl,
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
