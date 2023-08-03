import 'package:bookspark/presentation/modules/clubs/services/firebase_club_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/controllers/bloc/app_bloc.dart';

class NewClubPage extends StatefulWidget {
  final Function updateClubsView;
  const NewClubPage({Key? key, required this.updateClubsView}) : super(key: key);

  @override
  _NewClubPageState createState() => _NewClubPageState();
}

class _NewClubPageState extends State<NewClubPage> {
  final _formKey = GlobalKey<FormState>();
  final _clubIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currentBookController = TextEditingController();
  final _meetingDateController = TextEditingController();

  @override
  void dispose() {
    _clubIdController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _currentBookController.dispose();
    _meetingDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear nuevo club'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _clubIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del club',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un ID para el club';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del club',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre para el club';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del club',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce una descripción para el club';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _currentBookController,
                decoration: const InputDecoration(
                  labelText: 'Libro actual del club',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el libro actual del club';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _meetingDateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de reunión del club',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce la fecha de reunión del club';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    _createClub(_clubIdController.text.trim(),_currentBookController.text.trim(),_descriptionController.text.trim(),_meetingDateController.text.trim(),_nameController.text.trim(),user.id);
              },
              child: const Text('Crear club'),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

void _createClub( String clubId,String currentBook, String description, String meetingDate, String name , String userId,) async {
   final userUId = userId;

  createClub(clubId,currentBook,description,meetingDate,name,userUId,).then((_) {
    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has creado el club')),
    );
    widget.updateClubsView();
    Navigator.pop(context);
  }).catchError((error) {
    // Show an error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al crear al club')),
    );
  });
}
}