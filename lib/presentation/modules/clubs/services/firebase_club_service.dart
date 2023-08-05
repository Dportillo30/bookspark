import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> joinedClubs(String userId) async {
  List clubs = [];
  CollectionReference collectionReferenceClubs = db.collection('Club');

  QuerySnapshot queryClub = await collectionReferenceClubs.where('userId', arrayContains: userId).get();

  for (var document in queryClub.docs) {
    clubs.add(document.data());
  }

  return clubs;
}


Future<List> getClubs() async {
  List clubs = [];
  CollectionReference collectionReferenceClubs = db.collection('Club');

  QuerySnapshot queryClub = await collectionReferenceClubs.get();


  for (var documneto in queryClub.docs) {
    clubs.add(documneto.data());
   }

   return clubs;
} 


Future<void> joinClub(String clubId, String userId) async {
  CollectionReference collectionReferenceClubs = db.collection('Club');
  DocumentReference documentReferenceClub = collectionReferenceClubs.doc(clubId);
  
  // Actualiza el campo "userId" del documento en la colección "Club" con el nuevo valor "userId" 
  await documentReferenceClub.update({'userId': FieldValue.arrayUnion([userId])});
}


Future<void> createClub(String clubId, String currentBook, String description, String meetingDate, String name, String userId ,String bookId) async {
CollectionReference collectionReferenceClubs = db.collection('Club');
DocumentReference documentReferenceClub = collectionReferenceClubs.doc(clubId);

// Crea el nuevo documento con los campos especificados
await documentReferenceClub.set({
  'clubID': clubId,
  'currentBook': currentBook,
  'description': description,
  'meetingDate': meetingDate,
  'clubOwner': userId,
  'bookId': bookId,
  'name': name,
  'userId': [userId],
  });
}


Future<void> leaveClub(String clubId, String userId) async {
  CollectionReference collectionReferenceClubs = db.collection('Club');
  DocumentReference documentReferenceClub = collectionReferenceClubs.doc(clubId);

  // Remove the user ID from the 'userId' array in the document
  await documentReferenceClub.update({'userId': FieldValue.arrayRemove([userId])});
}


Future<void> deleteClub(String clubId) async {
  CollectionReference collectionReferenceClubs = db.collection('Club');
  DocumentReference documentReferenceClub = collectionReferenceClubs.doc(clubId);

  await documentReferenceClub.delete();
}


Future<void> updatePageNumber(String clubId, String pageNumber) async {
  CollectionReference collectionReferenceClubs = db.collection('Club');
  DocumentReference documentReferenceClub = collectionReferenceClubs.doc(clubId);

  // Actualiza el campo "pageNumber" del documento en la colección "Club" con el nuevo valor "pageNumber" 
  await documentReferenceClub.update({'pageNumber': pageNumber});
}