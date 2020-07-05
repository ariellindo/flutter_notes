import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import 'package:flutter_notes/config/paths.dart';
import 'package:flutter_notes/entities/entities.dart';
import 'package:flutter_notes/models/models.dart';
import 'package:flutter_notes/repositories/repositories.dart';

class AuthRepository extends BaseAuthRepository {
  final Firestore _fireStore;
  final FirebaseAuth _firebaseAuth;

  // pass the firestore or firebase auth if not create the instance
  AuthRepository({Firestore firestore, FirebaseAuth firebaseAuth})
      : _fireStore = firestore ?? Firestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  void dispose() {}

  /// login anonymously and return a user from firebase user
  @override
  Future<User> loginAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();

    return await _fireBaseUserToUser(authResult.user);
  }

  /// fire base to user converts the content of the autResult.user
  /// (firebaseUser type) to a model user from ower data format
  Future<User> _fireBaseUserToUser(FirebaseUser user) async {
    /// gets the user info from the user collection, user.uid
    /// is get from the authentication uid
    DocumentSnapshot userDoc =
        await _fireStore.collection(Paths.users).document(user.uid).get();

    /// user doc is converted from doc to entity object and then to model object
    /// if the user do exists
    if (userDoc.exists) {
      User user = User.fromEntity(UserEntity.fromSnapshot(userDoc));
      return user;
    }

    /// dont exists just returns empty user model
    return User(id: user.uid, email: '');
  }

  /// verify the current user and set the authCredentials with the email and pass
  /// set the current user to link with the credentials, to get the authenticated
  /// user.
  /// Converts the authResult to User Model.
  /// and save the new authenticated user to the Users collection.
  /// Converting the user (model) to back to entity and then to document object
  ///
  @override
  Future<User> signupWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    final currentUser = await _firebaseAuth.currentUser();
    final authCredential =
        EmailAuthProvider.getCredential(email: email, password: password);
    final authResult = await currentUser.linkWithCredential(authCredential);
    final user = await _fireBaseUserToUser(authResult.user);

    _fireStore
        .collection(Paths.users)
        .document(user.id)
        .setData(user.toEntity().toDocument());

    return user;
  }

  @override
  Future<User> loginWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    return await _fireBaseUserToUser(authResult.user);
  }

  @override
  Future<User> logout() async {
    await _firebaseAuth.signOut();
    return await loginAnonymously();
  }

  @override
  Future<User> getCurrentUser() async {
    final currentUser = await _firebaseAuth.currentUser();

    if (currentUser == null) return null;
    return await _fireBaseUserToUser(currentUser);
  }

  @override
  Future<bool> isAnonymous() async {
    final currenUser = await _firebaseAuth.currentUser();
    return currenUser.isAnonymous;
  }
}
