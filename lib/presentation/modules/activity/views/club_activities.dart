import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ClubActivities extends StatefulWidget {
  final String clubId;
  
   const ClubActivities({Key? key, required this.clubId}) : super(key: key);

  @override
  State<ClubActivities> createState() => _ClubActivitiesState();
}

class _ClubActivitiesState extends State<ClubActivities> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .where('clubId', isEqualTo: widget.clubId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al obtener las actividades'));
        }

        final activities = snapshot.data?.docs ?? [];

        return Scaffold(
          body: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activityData = activities[index].data() as Map<String, dynamic>?; // Convert to the nullable map// Use the null-aware operator

              if (activityData == null) {
                return SizedBox.shrink(); // Handle null activityData if needed
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(activityData['name']),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: _getActivityTypeChip(activityData),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(_getActivityDateAndOwner(activityData)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Implement the logic for creating a new activity
              _createNewActivity(context, widget.clubId);
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }


Widget _getActivityTypeChip(Map<String, dynamic>? activityData) {
  if (activityData == null) {
    return Chip(label: Text('Datos de actividad nulos'));
  }

  String type = activityData['type'] ?? 'Tipo no disponible';

  // Define the color and label for the chip based on the activity type.
  Color chipColor = type == 'quiz' ? Colors.green : Colors.red;
  String chipLabel = type == 'quiz' ? 'Quiz' : 'Progreso';

  return Chip(label: Text(chipLabel), backgroundColor: chipColor);
}

String _getActivityDateAndOwner(Map<String, dynamic>? activityData) {
  if (activityData == null) {
    return 'Datos de actividad nulos';
  }

  String createdAt = activityData['createdAt'] ?? 'Fecha no disponible';
  String ownerName = activityData['ownerName'] ?? 'Propietario no disponible';

  return 'Creado el: $createdAt | Creado por: $ownerName';
}



void _createNewActivity(BuildContext context, String clubId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String activityName = ''; // Activity name entered by the user
      String activityType = 'quiz'; // Default activity type, you can change this as needed

      return AlertDialog(
        title: const Text('Crear nueva actividad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Titulo'),
              onChanged: (value) {
                activityName = value;
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: activityType,
              onChanged: (newValue) {
                activityType = newValue ?? 'quiz';
              },
              items: const [
                DropdownMenuItem(
                  value: 'quiz',
                  child: Text('Quiz'),
                ),
                DropdownMenuItem(
                  value: 'progress',
                  child: Text('Progreso'),
                ),
              ],
              decoration: const InputDecoration(labelText: 'Tipo dde actividad'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate activityName and perform data saving to Firebase Firestore here
              if (activityName.trim().isEmpty) {
                // Show an error message if the activity name is empty
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Ingresa el nombre de una actividad'),
                ));
              } else {

                 // Get the currently logged-in user
          final user = FirebaseAuth.instance.currentUser;
          String ownerId = user?.uid ?? 'Unknown User';

          // Get the ownerName from the 'users' collection
          DocumentSnapshot userSnapshot =
              await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
          String ownerName = userSnapshot.exists ? userSnapshot['displayName'] : 'Unknown User';




                // Save the activity details to Firestore
                String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
                await FirebaseFirestore.instance.collection('activities').add({
                  'clubId': clubId,
                  'name': activityName,
                  'type': activityType,
                  'createdAt': formattedDate,
                  'ownerName': ownerName,
                  // Add other activity details as neededr
                });

                Navigator.pop(context); // Close the dialog after saving
              }
            },
            child: Text('Crear'),
          ),
        ],
      );
    },
  );
}

}
