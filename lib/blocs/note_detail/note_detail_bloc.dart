import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:flutter_notes/blocs/blocs.dart';
import 'package:flutter_notes/models/models.dart';
import 'package:flutter_notes/repositories/repositories.dart';

part 'note_detail_event.dart';
part 'note_detail_state.dart';

class NoteDetailsBloc extends Bloc<NoteDetailEvent, NoteDetailState> {
  final AuthBloc _authBloc;
  final NoteRepository _noteRepository;

  NoteDetailsBloc({AuthBloc authBloc, NoteRepository noteRepository})
      : _authBloc = authBloc,
        _noteRepository = noteRepository,
        super(NoteDetailState.empty());

  @override
  Stream<NoteDetailState> mapEventToState(NoteDetailEvent event) async* {
    if (event is NoteLoaded) {
      yield* _mapNoteLoadedToState(event);
    } else if (event is NoteContentUpdated) {
      yield* _mapNoteContentUpdatedToState(event);
    } else if (event is NoteColorUpdated) {
      yield* _mapNoteColorUpdatedToState(event);
    } else if (event is NoteAdded) {
      yield* _mapNoteAddedToState();
    } else if (event is NoteSaved) {
      yield* _mapNoteSavedToState();
    } else if (event is NoteDeleted) {
      yield* _mapNoteDeletedToState();
    }
  }

  String _getCurrentUserId() {
    AuthState authState = _authBloc.state;
    String currentUserId;

    if (authState is Anonymous) {
      currentUserId = authState.user.id;
    } else if (authState is Authenticated) {
      currentUserId = authState.user.id;
    }

    return currentUserId;
  }

  Stream<NoteDetailState> _mapNoteLoadedToState(NoteLoaded event) async* {
    yield state.update(note: event.note);
  }

  Stream<NoteDetailState> _mapNoteContentUpdatedToState(
      NoteContentUpdated event) async* {
    if (state.note == null) {
      final String currentUserId = _getCurrentUserId();
      final Note note = Note(
        color: HexColor('#E74C3C'),
        content: event.content,
        userId: currentUserId,
        timestamp: DateTime.now(),
      );
      yield state.update(note: note);
    } else {
      yield state.update(
        note: state.note.copy(
          content: event.content,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Stream<NoteDetailState> _mapNoteColorUpdatedToState(
      NoteColorUpdated event) async* {
    if (state.note == null) {
      final String currentUserId = _getCurrentUserId();
      final Note note = Note(
        color: event.color,
        content: '',
        userId: currentUserId,
        timestamp: DateTime.now(),
      );
      yield state.update(note: note);
    } else {
      yield state.update(
        note: state.note.copy(
          color: event.color,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Stream<NoteDetailState> _mapNoteAddedToState() async* {
    yield NoteDetailState.submitting(note: state.note);
    try {
      await _noteRepository.addNote(note: state.note);
      yield NoteDetailState.success(note: state.note);
    } catch (_) {
      yield NoteDetailState.failure(
        note: state.note,
        errorMessage: 'New note could not be added',
      );
      yield state.update(
        isSubmitting: false,
        isSuccess: false,
        isFailure: false,
        errorMessage: '',
      );
    }
  }

  Stream<NoteDetailState> _mapNoteSavedToState() async* {
    yield NoteDetailState.submitting(note: state.note);
    try {
      await _noteRepository.updateNote(note: state.note);
    } catch (_) {
      yield NoteDetailState.failure(
        note: state.note,
        errorMessage: 'Note could not be saved',
      );
      yield state.update(
        isSubmitting: false,
        isSuccess: false,
        isFailure: false,
        errorMessage: '',
      );
    }
  }

  Stream<NoteDetailState> _mapNoteDeletedToState() async* {
    yield NoteDetailState.submitting(note: state.note);
    try {
      await _noteRepository.deleteNote(note: state.note);
      yield NoteDetailState.success(note: state.note);
    } catch (_) {
      yield NoteDetailState.failure(
        note: state.note,
        errorMessage: 'Note could not be deleted',
      );
      yield state.update(
        isSubmitting: false,
        isSuccess: false,
        isFailure: false,
        errorMessage: '',
      );
    }
  }
}
