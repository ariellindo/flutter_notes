import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_notes/entities/entities.dart';

class User extends Equatable {
  final String id;
  final String email;

  const User({
    @required this.id,
    @required this.email,
  });

  @override
  List<Object> get props => [id, email];

  @override
  String toString() {
    return ''' UserEntity {
      id: $id,
      email: $email
    }''';
  }

  UserEntity toEntity() {
    return UserEntity(email: email, id: id);
  }

  factory User.fromEntity(UserEntity entity) {
    return User(email: entity.email, id: entity.id);
  }
}
