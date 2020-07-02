import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_notes/config/paths.dart';
import 'package:flutter_notes/entities/entities.dart';
import 'package:flutter_notes/models/models.dart';
import 'package:flutter_notes/repositories/repositories.dart';

class NoteRepository extends BaseNotesRepository {
  final Firestore _firestore;
  final Duration _timeoutDuration = Duration(seconds: 10);

  NoteRepository({Firestore firestore})
      : _firestore = firestore ?? Firestore.instance;

  @override
  void dispose() {}

  /// saves a note to the notes collection in firebase
  /// and returns the note passed
  @override
  Future<Note> addNote({@required Note note}) async {
    await _firestore
        .collection(Paths.notes)
        .add(note.toEntity().toDocument())
        .timeout(_timeoutDuration);

    return note;
  }

  /// updates a note to the notes collection in firebase
  /// and returns the note passed
  @override
  Future<Note> updateNote({@required Note note}) async {
    await _firestore
        .collection(Paths.notes)
        .document(note.id)
        .updateData(note.toEntity().toDocument());

    return note;
  }

  /// delete a note to the notes collection in firebase
  /// and returns the note passed
  @override
  Future<Note> deleteNote({@required Note note}) async {
    await _firestore.collection(Paths.notes).document(note.id).delete();

    return note;
  }

  /// fetch the notes from the notes collection validating the userId
  /// firebse return snapshots of the collection according to the user.
  /// all the snapshots are mapped to get the documents and converting each
  /// document to a note entity.
  /// and then to a sorted list by timestamp
  @override
  Stream<List<Note>> streamNotes({@required String userId}) {
    return _firestore
        .collection(Paths.notes)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.documents
            .map((doc) => Note.fromEntity(NoteEntity.fromSnapShot(doc)))
            .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp)));
  }
}
