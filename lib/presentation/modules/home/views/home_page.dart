import 'dart:io';

import 'package:bookspark/presentation/modules/home/views/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../app/controllers/bloc/app_bloc.dart';
import '../../clubs/views/club_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    PostFeed(),
    const ClubPage(),
    const ProfilePage(),
  ];

  // Firebase Database and Storage references
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
          title: Text('Error'),
          content: Text('El texto del post no puede estar vacío.'),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

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
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Save the post in Firebase Realtime Database
    _database.reference().child('posts').push().set(post);

    // Clear post variables after submission
    setState(() {
      _postText = '';
      _pickedImage = null;
    });
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
    return Scaffold(
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
      body: _pages[_currentIndex],
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



class PostFeed extends StatefulWidget {
  final DatabaseReference _postsRef = FirebaseDatabase.instance.reference().child('posts');

  @override
  State<PostFeed> createState() => _PostFeedState();
}

class _PostFeedState extends State<PostFeed> {
  Future<void> _refreshPosts() async {
    // Wait for a short duration to simulate the refresh process.
    // You can replace this with the actual data fetching from the database.
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: StreamBuilder<DatabaseEvent>(
        stream: widget._postsRef.orderByChild('timestamp').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> posts = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Widget> postList = [];
            posts.forEach((key, value) {
              postList.add(
                Card(
                  child: ListTile(
                    title: Text(value['text']),
                    subtitle: value['image'] != null ? Image.network(value['image']) : null,
                  ),
                ),
              );
            });

            return ListView(
              children: postList,
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}