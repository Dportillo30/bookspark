import 'package:bookspark/presentation/modules/clubs/services/firebase_club_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../app/controllers/bloc/app_bloc.dart';
import 'club_book_search_page.dart';


class NewClubPage extends StatefulWidget {
  final Function updateClubsView;
  const NewClubPage({Key? key, required this.updateClubsView}) : super(key: key);

  @override
  _NewClubPageState createState() => _NewClubPageState();
}

class _NewClubPageState extends State<NewClubPage> {
  DateTime? _selectedMeetingDate;
  Book? _selectedBook;
  final _formKey = GlobalKey<FormState>();
  final _clubIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currentBookController = TextEditingController();
  final _meetingDateController = TextEditingController();
  final _currentIdBookController = TextEditingController();



    Future<void> _selectMeetingDate() async {
    final currentDate = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: DateTime(currentDate.year + 1), // Limitamos a un año desde la fecha actual
    );

    if (selectedDate != null && selectedDate != _selectedMeetingDate) {
      setState(() {
        _selectedMeetingDate = selectedDate;
        _meetingDateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  @override
  void dispose() {
    _clubIdController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _currentBookController.dispose();
    _meetingDateController.dispose();
    _clubIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Crear nuevo club'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _clubIdController,
                decoration: const InputDecoration(
                  labelText: 'Codigo del club',
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
    _selectedBook != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Libro seleccionado: ${_selectedBook!.title}'),
              if (_selectedBook!.thumbnailUrl != null)
                Image.network(_selectedBook!.thumbnailUrl!),
              ElevatedButton(
                onPressed: () async {
                  final selectedBook = await Navigator.push<Book?>(
                    context,
                    MaterialPageRoute(builder: (context) => const BookSearchPage()),
                  );
                  setState(() {
                    _selectedBook = selectedBook;
                    if (selectedBook != null) {
                      _currentBookController.text = selectedBook.title;
                      _currentIdBookController.text = selectedBook.id;
                    }
                  });
                },
                child: const Text('Agregar libro'),
              ),
            ],
          )
        : ElevatedButton(
            onPressed: () async {
              final selectedBook = await Navigator.push<Book?>(
                context,
                MaterialPageRoute(builder: (context) => const BookSearchPage()),
              );
              setState(() {
                _selectedBook = selectedBook;
                if (selectedBook != null) {
                  _currentBookController.text = selectedBook.title;
                  _currentIdBookController.text = selectedBook.id;
                }
              });
            },
            child: const Text('Agregar libro'),
          ),
    const SizedBox(height: 16.0),
              TextFormField(
      controller: _meetingDateController,
      decoration: const InputDecoration(
        labelText: 'Fecha de reunión del club',
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: _selectMeetingDate,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecciona la fecha de reunión del club';
        }
        return null;
      },
    ),
              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    _createClub(_clubIdController.text.trim(),_currentBookController.text.trim(),_descriptionController.text.trim(),_meetingDateController.text.trim(),_nameController.text.trim(),user.id,_currentIdBookController.text.trim());
              },
              child: const Text('Crear club'),
            ),
          ),
        ],
      ),
    ),
  ),
      )
);
}

void _createClub( String clubId,String currentBook, String description, String meetingDate, String name , String userId,String bookId) async {
   final userUId = userId;

  createClub(clubId,currentBook,description,meetingDate,name,userUId,bookId).then((_) {
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