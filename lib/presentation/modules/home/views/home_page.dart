import 'dart:io';

import 'package:bookspark/presentation/modules/home/views/profile_info_page.dart';
import 'package:bookspark/presentation/modules/home/views/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../../app/controllers/bloc/app_bloc.dart';
import '../../clubs/views/club_page.dart';
import '../../post/views/post_feed.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isNewUser = false;
  int _currentIndex = 0;
  final List<Widget> _pages = [
    PostFeed(),
    const ClubPage(),
    const ProfilePage(),
  ];

  // Firebase Database and Storage references

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
     final user = FirebaseAuth.instance.currentUser;
    // Obtener el UID del usuario logueado (reemplaza 'tu_id_de_usuario' por la forma en que obtienes el UID)
    final userId = user?.uid ;

    // Consultar la colección 'users' y obtener el valor de 'isNew' para el usuario actual
    FirebaseFirestore.instance.collection('users').doc(userId).get().then((doc) {
      if (doc.exists) {
        setState(() {
          isNewUser = doc.get('isNewUser') ?? false; // Si no se encuentra 'isNew', se establece en falso
        });
      }
    }).catchError((error) {
      print('Error al obtener el valor de isNew: $error');
    });
  }
  


  // Text and image variables for post
  String _postText = '';
  XFile? _pickedImage;

  // Function to handle post submission
void _submitPost() async {
  if (_postText.isEmpty) {
    // Show an error dialog if post text is empty
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('El texto del post no puede estar vacío.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    return;
  }

  // Replace 'userId' con el ID del usuario actual
  final userId = 'tu_id_de_usuario';

  // Upload image to Firebase Storage if an image is selected
  String? imageUrl;
  if (_pickedImage != null) {
    final ref = _storage.ref().child('post_images').child(DateTime.now().toString());
    final uploadTask = ref.putFile(File(_pickedImage!.path));
    final snapshot = await uploadTask.whenComplete(() {});
    imageUrl = await snapshot.ref.getDownloadURL();
  }

  // Create the post object
  final post = {
    'text': _postText,
    'image': imageUrl,
    'timestamp': DateTime.now(),
    'userId': userId, // Agrega la información del usuario
    'likeCount': 0, // Inicializa el conteo de likes en 0
    'comments': [], // Inicializa la lista de comentarios como vacía
  };

  try {
    // Save the post in Firebase Firestore
    await _firestore.collection('posts').add(post);

    // Clear post variables after submission
    setState(() {
      _postText = '';
      _pickedImage = null;
    });
  } catch (e) {
    // Handle any errors that occur during Firestore write
    print('Error saving post: $e');
  }
}

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    if(isNewUser ){
      print('isNewUser:');
      print(isNewUser);
      return ProfileInfoPage() ;
    }

    return  Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            key: const Key('homePage_logout_iconButton'),
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AppBloc>().add(const AppLogoutRequested());
            },
          )
        ],
      ),
      body:  _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Show a dialog to input post text and pick image
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Nuevo Post'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        maxLength: 150,
                        onChanged: (text) => setState(() => _postText = text),
                        decoration: InputDecoration(
                          hintText: 'Escribe tu post (máximo 150 caracteres)',
                        ),
                      ),
                      SizedBox(height: 8),
                      _pickedImage != null
                          ? Image.file(File(_pickedImage!.path), height: 100)
                          : Container(),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Seleccionar imagen'),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancelar'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Publicar'),
                      onPressed: () {
                        _submitPost();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
            child: Icon(Icons.add),
            tooltip: 'Crear nuevo post',
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            onPressed: () {
              //TODO SITEMA DE MENSAJERIA
            },
            child: Icon(Icons.message),
          ),
        ],
      ): null,
    );
  }
}


