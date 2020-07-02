import 'package:flutter_notes/models/models.dart';
import 'package:flutter_notes/repositories/base_repository.dart';

abstract class BaseNotesRepository extends BaseRepository {
  Future<Note> addNote({Note note});
  Future<Note> updateNote({Note note});
  Future<Note> deleteNote({Note note});
  Stream<List<Note>> streamNotes({String userId});
}
