part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class Unauthenticated extends AuthState {}

class Anonymous extends AuthState {
  final User user;

  const Anonymous(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() {
    return 'Anonymous { useId: ${user.id} }';
  }
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() {
    return 'Authenticated { useId: ${user.id} }';
  }
}
