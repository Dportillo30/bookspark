import 'package:bookspark/presentation/modules/clubs/services/firebase_club_service.dart';
import 'package:bookspark/presentation/modules/clubs/views/join_club.dart';
import 'package:bookspark/presentation/modules/clubs/views/new_club_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bookspark/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/controllers/bloc/app_bloc.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({ Key? key }) : super(key: key);

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  var _selectedClub; // Variable para almacenar el club seleccionado

  @override
  Widget build(BuildContext context){

    final user = context.select((AppBloc bloc) => bloc.state.user);

  void _updateClubsView() async {
  final user = context.read<AppBloc>().state.user;
  final clubs = await joinedClubs(user.id);
  setState(() {
    _selectedClub = null;
  });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis clubs de lectura'),
        centerTitle: true, // Centra el título en la AppBar
      ),
      body: FutureBuilder(
        future: joinedClubs(user.id),
        builder: ((context,snapshot){
          if (snapshot.hasData) {
            return Center(
              child: Opacity(
                opacity: 0.8, // Opacidad de los elementos de la lista
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context,index){
                    return ListTile(
                      title: Text(snapshot.data![index]['name']),
                      subtitle: Text(snapshot.data![index]['description']), // Añade la descripción como subtitulo
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // Añade padding horizontal
                      onTap: () {
                        setState(() {
                          _selectedClub = snapshot.data![index];
                        });
                        _showClubDetails(context);
                      },
                    );
                  },
                ),
              ),
            );   
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => NewClubPage(updateClubsView: _updateClubsView)),
);
            },
            tooltip: 'Crear Club de lectura',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => JoinClubPage(updateClubsView: _updateClubsView)),
);

            },
            tooltip: 'Unirse a un nuevo club de lectura',
            child: const Icon(Icons.group_add),
          ),
        ],
      ),
    );
  }

  void _showClubDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_selectedClub['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_selectedClub['description']),
              const SizedBox(height: 10),
              Text('Libro actual: ${_selectedClub['currentBook']}'),
              Text('Fecha de reunión: ${_selectedClub['meetingDate']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}