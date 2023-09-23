import 'dart:async';

import 'package:bookspark/domain/models/user.dart';
import 'package:cache/cache.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// {@template sign_up_with_email_and_password_failure}
/// Thrown if during the sign up process if a failure occurs.
/// {@endtemplate}
class SignUpWithEmailAndPasswordFailure implements Exception {
  /// {@macro sign_up_with_email_and_password_failure}
  const SignUpWithEmailAndPasswordFailure([
    this.message = 'Ha ocurrido un error inesperado.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/createUserWithEmailAndPassword.html
  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure(
          'El email no es valido',
        );
      case 'user-disabled':
        return const SignUpWithEmailAndPasswordFailure(
          'Ell usuario ha sido deshabilitado.',
        );
      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure(
          'Una cuenta ya existe con ese email.',
        );
      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure(
          'Operacion no permitida.',
        );
      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure(
          'Pon una contraseña mas fuerte',
        );
      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_email_and_password_failure}
/// Thrown during the login process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html
/// {@endtemplate}
class LogInWithEmailAndPasswordFailure implements Exception {
  /// {@macro log_in_with_email_and_password_failure}
  const LogInWithEmailAndPasswordFailure([
    this.message = 'Un error inesperado a ocurrido.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure(
          'El correo no es correcto.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure(
          'El usuario ha sido deshabilitado.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'Correo no encontrado, por favor crea una cuenta.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Contraseña incorrecta.',
        );
      default:
        return const LogInWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// {@template log_in_with_google_failure}
/// Thrown during the sign in with google process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
class LogInWithGoogleFailure implements Exception {
  /// {@macro log_in_with_google_failure}
  const LogInWithGoogleFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'La cuenta existe con otros credenciales.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'Ha expirado.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'La operacion no esta permitida.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'El usuario ha sido deshabilitado.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'El email no existe por favor, crea una cuenta.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Contraseña incorrecta, intentalo ded nuevo.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'La verficacion ha fallado.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'El Id es invalido.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }

  /// The associated error message.
  final String message;
}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _cache = cache ?? CacheClient(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Whether or not the current environment is web
  /// Should only be overriden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  bool isWeb = kIsWeb;

  /// User cache key.
  /// Should only be used for testing purposes.
  static const userCacheKey = '__user_cache_key__';

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
 Future<void> signUp({required String email, required String password, required String nickname}) async {
  try {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDoc.exists) {
      // Create a new user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'displayName': nickname,
        'createdAt': FieldValue.serverTimestamp(),
        'isNewUser': true,
      });
    }

  } on firebase_auth.FirebaseAuthException catch (e) {
    throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
  } catch (_) {
    throw const SignUpWithEmailAndPasswordFailure();
  }
}



  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
Future<User> logInWithGoogle() async {
  try {
    final googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw const LogInWithGoogleFailure('El usuario ha cancelado la autenticación.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user!;

    // Check if the user already exists in Firestore
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      // Create a new user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'isNewUser': true,
      });
    }


    final isNewUser = userDoc.exists ? userDoc['isNewUser'] : false;

    // Return the User object
    return User(
      id: user.uid,
      email: user.email!,
      isNew: isNewUser,
    );
  } on firebase_auth.FirebaseAuthException catch (e) {
    throw LogInWithGoogleFailure.fromCode(e.code);
  } on Exception {
    throw const LogInWithGoogleFailure();
  }
}

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  
  User get toUser {
    return User(id: uid, email: email, name: displayName, photo: photoURL);
  }
}

