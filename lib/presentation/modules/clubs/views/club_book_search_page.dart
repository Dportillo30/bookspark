import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BookSearchPageState createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  void _onSearchSubmitted(String value) {
    _searchBooks(); // Iniciamos la búsqueda cuando el usuario presiona "Enter"
  }
  List<Book> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchBooks() async {
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    const apiKey = 'AIzaSyAeyq7fOh6FVW2vwEX82mkTGVmnA5HKQrY';
    final url =
        'https://www.googleapis.com/books/v1/volumes?q=$searchQuery&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchResults = (data['items'] as List)
            .map((item) => Book.fromJson(item))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar libro'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar libro',
                suffixIcon: IconButton(
                  onPressed: _searchBooks,
                  icon: const Icon(Icons.search),
                ),
              ),
              onFieldSubmitted: _onSearchSubmitted,
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final book = _searchResults[index];
                  return ListTile(
                    leading: book.thumbnailUrl != null
                        ? Image.network(book.thumbnailUrl!)
                        : const Icon(Icons.book),
                    title: Text(book.title),
                    onTap: () {
                      Navigator.pop(context, book);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class Book {
  final String id;
  final String title;
  final String? thumbnailUrl;

  Book({required this.id, required this.title, this.thumbnailUrl});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['volumeInfo']['title'] as String,
      thumbnailUrl: json['volumeInfo']['imageLinks'] != null
          ? json['volumeInfo']['imageLinks']['thumbnail'] as String
          : null,
    );
  }
}