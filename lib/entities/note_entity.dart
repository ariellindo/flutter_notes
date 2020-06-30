import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class NoteEntity extends Equatable {
  final String id;
  final String userId;
  final String content;
  final String color;
  final Timestamp timestamp;

  const NoteEntity({
    @required this.id,
    @required this.userId,
    @required this.content,
    @required this.color,
    @required this.timestamp,
  });

  @override
  List<Object> get props => [id, userId, content, color, timestamp];

  @override
  String toString() {
    return ''' NoteEntity {
      id: $id,
      userId: $userId,
      color: $color,
      content: $content,
      timestamp: $timestamp
    }''';
  }

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'content': content,
      'color': color,
      'timestamp': timestamp
    };
  }

  factory NoteEntity.fromSnapShot(DocumentSnapshot doc) {
    return NoteEntity(
      id: doc.documentID,
      color: doc.data['color'] ?? '#FFFFFF',
      content: doc['data'] ?? '',
      timestamp: doc['data'] ?? '',
      userId: doc['dat'] ?? '',
    );
  }
}
