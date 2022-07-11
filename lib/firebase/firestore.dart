import '/widgets/note.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStore {
  static void addNote(Note note) {
    getUserNoteCollection().doc(note.noteID).set(note.toMap);
  }

  static void updateNote(Note note) {
    getUserNoteCollection().doc(note.noteID).update(note.toMap);
  }

  static void updateNoteField(String noteID, Map<String, Object?> noteToMap) {
    getUserNoteCollection().doc(noteID).update(noteToMap);
  }


  static void deleteNote(Note note) {
    getUserNoteCollection().doc(note.noteID).delete();
  }

  static CollectionReference<Map<String, dynamic>> getUserNoteCollection() {
    return FirebaseFirestore.instance
        .collection("user-notes")
        .doc("notes")
        .collection(FirebaseAuth.instance.currentUser!.email.toString());
  }

  static void deleteAllNotes() async {
    final instance = FirebaseFirestore.instance;
    final batch = instance.batch();
    var collection = getUserNoteCollection();
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
