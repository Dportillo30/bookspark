import 'package:bookspark/presentation/modules/activity/views/club_activities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../services/firebase_club_service.dart';

class ClubDetailsPage extends StatefulWidget {
  
  
  final Map<String, dynamic> club;

  const ClubDetailsPage({Key? key, required this.club}) : super(key: key);

  @override
  _ClubDetailsPageState createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> with SingleTickerProviderStateMixin {

  
  String? bookCoverUrl;
  late TabController _tabController;
  int? totalPages;
  
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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

    final int totalPageCount = responseData['volumeInfo']['pageCount'];
      setState(() {
      totalPages = totalPageCount;
    });
    } else {
      //TODO error handle : manejar error por si el libro no tiene portada/ no se encuentra disponible
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserID = FirebaseAuth.instance.currentUser?.uid;
    final String clubOwnerID = widget.club['clubOwner'];
    
    double? progress; // Declarar la variable aquí

    // Calculate progress if totalPages and pageNumber are available
    if (totalPages != null && widget.club['pageNumber'] != null) {
      progress = double.parse(widget.club['pageNumber']!) / totalPages!.toDouble();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club['name']),
actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (currentUserID == clubOwnerID) {
                if (value == 'delete') {
                  _deleteClub();
                }
              } else {
                if (value == 'leave') {
                  _leaveClub();
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                if (currentUserID == clubOwnerID)
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Eliminar club'),
                  )
                else
                  const PopupMenuItem<String>(
                    value: 'leave',
                    child: Text('Abandonar club'),
                  ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bookCoverUrl != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: InkWell(
                  onTap: () => _showImageDialog(context),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(bookCoverUrl!),
                    radius: 35,
                  ),
                ),
              ),
               const SizedBox(width: 16), // Espacio entre la imagen y el botón
                  if (currentUserID == clubOwnerID) // Botón condicional para el clubOwner
                    ElevatedButton(
                      onPressed: () {
                        // Aquí llamamos al método para actualizar el número de páginas
                        _updatePageNumberDialog();
                      },
                      child: Text('Actualizar páginas'),
                    ),
            if (bookCoverUrl == null)
              const Center(
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 10.0),
              if (progress != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 20, // Personaliza la altura de la barra
                      ),
                      const SizedBox(height: 8), // Espacio entre la barra y el porcentaje
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%', // Muestra el porcentaje como números
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
             Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: ElevatedButton(
                onPressed: () => _openSampleBook(),
                child: const Text('Ver muestra del libro'),
              ),
            ),

            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.people, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${widget.club['userId'].length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.club['meetingDate'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            const ListTile(
              leading: Icon(Icons.description),
              title: Text(
                'Descripción:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.club['description'],
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
            const SizedBox(height: 10.0),
            const ListTile(
              leading: Icon(Icons.book),
              title: Text(
                'Libro actual:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.club['currentBook'],
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Comunidad'),
                  Tab(text: 'Actividades'),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.50, // Max 25% height for TabBarView
              child: TabBarView(
                controller: _tabController,
                children:  [
                  Center(
                    child: Text('Comunidad Content'),
                  ),
                  Center(
                    child: ClubActivities(clubId: widget.club['clubID']),
                  ),
                ],
              ),
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

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Has abandonado el club ' + widget.club['name'])),
    );
      // ...
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error al abandonar el club, intentalo de nuevo mas tarde')),
    );
    }
  }


  void _deleteClub() async {
    final clubId = widget.club['clubID'];

    try {
      await deleteClub(clubId);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Has elimnado el club ' + widget.club['name'])),
    );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error al eliminar el club, intentalo de nuevo mas tarde')),
    );
    }
  }

    void _openSampleBook() async {
    final String bookId = widget.club['bookId'];
    final String sampleUrl = 'https://play.google.com/books/reader?id=$bookId';

    if (await canLaunchUrl(Uri.parse(sampleUrl))) {
      await launchUrl(Uri.parse(sampleUrl));
    } else {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error al abrir la muestra')),
    );
    }
  }

void _updatePageNumberDialog() {
  showDialog(
    context: context,
    builder: (context) {
      String newPageNumber = ''; // Variable para almacenar el nuevo número de páginas ingresado

      return AlertDialog(
        title: Text('Actualizar número de páginas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cantidad total de páginas: ${totalPages ?? ''}'),
            SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                newPageNumber = value;
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              
              if (totalPages != null && int.parse(newPageNumber) <= totalPages!) {
                await updatePageNumber(widget.club['clubID'], newPageNumber);

              
                setState(() {});

                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('El número de páginas debe ser menor o igual a la cantidad total del libro')),
                );
              }
            },
            child: Text('Actualizar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
        ],
      );
    },
  );
}


}

