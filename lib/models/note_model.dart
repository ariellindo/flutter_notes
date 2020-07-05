import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes/entities/entities.dart';

class Note extends Equatable {
  final String id;
  final String userId;
  final String content;
  final Color color;
  final DateTime timestamp;

  const Note({
    @required this.id,
    @required this.color,
    @required this.content,
    @required this.timestamp,
    @required this.userId,
  });

  @override
  List<Object> get props => [id, userId, color, content, timestamp];

  @override
  String toString() {
    return ''' Note {
      id: $id,
      userId: $userId,
      color: $color,
      content: $content,
      timestamp: $timestamp
    }''';
  }

  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      userId: userId,
      content: content,
      color: '#${color.value.toRadixString(16)}',
      timestamp: Timestamp.fromDate(timestamp),
    );
  }

  factory Note.fromEntity(NoteEntity entity) {
    return Note(
      id: entity.id,
      userId: entity.userId,
      content: entity.content,
      color: HexColor(entity.color),
      timestamp: entity.timestamp.toDate(),
    );
  }

  Note copy({
    String id,
    String userId,
    String content,
    Color color,
    DateTime timestamp,
  }) {
    return Note(
      id: id ?? this.id,
      userId: id ?? this.userId,
      content: content ?? this.content,
      color: color ?? this.color,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }

    return int.parse(hexColor, radix: 16);
  }
}
