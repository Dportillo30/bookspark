import 'package:bookspark/presentation/modules/home/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({Key? key}) : super(key: key);

 static Page<void> page() => const MaterialPage<void>(child: ProfileInfoPage());

  @override
  
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _bookCountController = TextEditingController();
  final _bioController = TextEditingController();
  final _usernameController = TextEditingController();
  final _imagePicker = ImagePicker();
  late String _imageUrl; // Almacenar la URL de la imagen de perfil

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _bookCountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '¿Cuántos libros has leído?'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese el número de libros leídos.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 120,
                decoration: InputDecoration(
                  labelText: '¿Qué puedes decir sobre ti? (máximo 120 caracteres)',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese una descripción.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nombre de usuario'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingrese un nombre de usuario.';
                  }
                  return null;
                },
              ),
              ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      // Guardar la información en Firestore
      final user = FirebaseAuth.instance.currentUser;
      final userData = {
        'bookCount': int.parse(_bookCountController.text),
        'bio': _bioController.text,
        'displayname': _usernameController.text,
        'isNewUser':false,
      };

      // Obtener el documento existente del usuario
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid as String);
      
      // Actualizar solo los campos especificados en userData
      await userDoc.update(userData);

      // Navegar de regreso
      // ignore: use_build_context_synchronously
      Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const HomePage()));
    }
  },
  child: Text('Completar'),
),
            ],
          ),
        ),
      ),
    );
  }
}
