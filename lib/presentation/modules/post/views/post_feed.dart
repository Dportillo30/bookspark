import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/controllers/bloc/app_bloc.dart';

class PostFeed extends StatefulWidget {
  @override
  State<PostFeed> createState() => _PostFeedState();
}

class _PostFeedState extends State<PostFeed> {
  // Reference to the Firestore collection
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsRef = FirebaseFirestore.instance.collection('posts');

  // Añade un mapa para realizar un seguimiento de los likes del usuario
  Map<String, bool> _userLikes = {};

  Future<void> _refreshPosts() async {
    // Wait for a short duration to simulate the refresh process.
    // You can replace this with the actual data fetching from the database.
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: StreamBuilder<QuerySnapshot>(
        stream: _postsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                var data = posts[index].data() as Map<String, dynamic>;
                final postId = posts[index].id;

                // Verifica si el usuario actual dio like a este post
                final userLiked = _userLikes[postId] ?? (data['likes']?.contains('userId') ?? false);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['text'],
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        if (data['image'] != null)
                          Image.network(
                            data['image'],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            // Icono de like con acción de toggle
                            IconButton(
                              icon: Icon(
                                userLiked ? Icons.favorite : Icons.favorite_border,
                                color: userLiked ? Colors.red : Colors.black,
                              ),
                              onPressed: () {
                                // Cambia el estado del like
                                setState(() {
                                  if (userLiked) {
                                    // Si ya le dio like, quita el like
                                    _firestore
                                        .collection('posts')
                                        .doc(postId)
                                        .update({'likes': FieldValue.arrayRemove([user.id])});
                                    _userLikes[postId] = false;
                                  } else {
                                    // Si no le dio like, agrega el like
                                    _firestore
                                        .collection('posts')
                                        .doc(postId)
                                        .update({'likes': FieldValue.arrayUnion([user.id])});
                                    _userLikes[postId] = true;
                                  }
                                });
                              },
                            ),
                            // Muestra la cantidad de likes
                            Text(
                              data['likes']?.length.toString() ?? '0',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
