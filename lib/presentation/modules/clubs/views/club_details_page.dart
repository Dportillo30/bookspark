import 'package:flutter/material.dart';

class ClubDetailsPage extends StatelessWidget {
  final Map<String, dynamic> club;

  ClubDetailsPage({required this.club});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(club['name']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.description),
              title: Text(
                'Descripción:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              club['description'],
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            ListTile(
              leading: Icon(Icons.book),
              title: Text(
                'Libro actual:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              club['currentBook'],
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(
                'Fecha de reunión:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              club['meetingDate'],
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            ListTile(
              leading: Icon(Icons.people),
              title: Text(
                'Integrantes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                club['userId'].length,
                (index) => Text(
                  club['userId'][index],
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
