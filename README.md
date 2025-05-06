# SamePage

A Flutter-based social media application for book enthusiasts to share and discover books, connect with other readers, and manage their reading lists.

## Features

- User authentication and profile management
- Book search and discovery using Google Books API
- Social features for connecting with other readers
- Reading list management
- Book recommendations

## Prerequisites

- Flutter SDK (version 3.6.1 or higher)
- Dart SDK
- Firebase account
- Google Books API key

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/cwbradfield/Social-Book-Project-CSC450.git
   cd Social-Book-Project-CSC450
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Set up a Firebase project
   - Add your Firebase configuration files
   - Enable Authentication and Firestore

4. Run the app:
   ```bash
   flutter run
   ```

## Environment Setup

Create a `.env` file in the root directory with the following variables:
```
GOOGLE_BOOKS_API_KEY=your_api_key_here
```

