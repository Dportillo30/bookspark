import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/firebase_club_service.dart';

class ClubDetailsPage extends StatefulWidget {
  final Map<String, dynamic> club;

  const ClubDetailsPage({Key? key, required this.club}) : super(key: key);

  @override
  _ClubDetailsPageState createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  String? bookCoverUrl;

  @override
  void initState() {
    super.initState();
    // Call the method to fetch book cover when the widget is initialized.
    fetchBookCover();
  }

  Future<void> fetchBookCover() async {
    const String apiKey = 'AIzaSyAeyq7fOh6FVW2vwEX82mkTGVmnA5HKQrY';
    final String bookId = widget.club['bookId'];

    final String apiUrl = 'https://www.googleapis.com/books/v1/volumes/$bookId?key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String coverUrl = responseData['volumeInfo']['imageLinks']['thumbnail'];
      setState(() {
        bookCoverUrl = coverUrl;
      });
    } else {
      // Handle API error here if needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club['name']),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave') {
                _leaveClub();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'leave',
                  child: Text('Abandonar club'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (bookCoverUrl != null)
              InkWell(
                onTap: () => _showImageDialog(context),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(bookCoverUrl!),
                  radius: 100, // Adjust the radius as needed.
                ),
              ),
            if (bookCoverUrl == null)
              const Center(
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Row(
                  children: [
                    Icon(Icons.people, size: 24),
                    SizedBox(width: 8),
                    Text(
                      '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Text(
                    '${widget.club['userId'].length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.calendar_today, size: 24),
                    SizedBox(width: 8),
                    Text(
                      '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Text(
                    widget.club['meetingDate'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            const ListTile(
              leading: Icon(Icons.description),
              title: Text(
                'Descripción:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              widget.club['description'],
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 14.0),
            const ListTile(
              leading: Icon(Icons.book),
              title: Text(
                'Libro actual:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              widget.club['currentBook'],
              style: const TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.network(bookCoverUrl!),
      ),
    );
  }

  void _leaveClub() async {
    final String clubId = widget.club['clubID']; // Assuming 'clubID' is the field name of the club ID in the document
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await leaveClub(clubId, userId);

      // Show a success message or navigate back, etc.
      // ...
    } catch (e) {
      // Handle any errors that occur during the leave process.
      // ...
    }
  }



}
