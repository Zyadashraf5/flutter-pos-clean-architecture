import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

/// Pure-Dart Firebase Auth via REST API.
/// Works on ALL platforms including Windows desktop.
/// https://firebase.google.com/docs/reference/rest/auth
class FirebaseAuthRest {
  FirebaseAuthRest({String? apiKey}) : _apiKey = apiKey ?? _resolveApiKey();

  final String _apiKey;

  static String _resolveApiKey() {
    try {
      return Firebase.app().options.apiKey;
    } catch (_) {
      throw Exception('Firebase not initialized. Call Firebase.initializeApp() first.');
    }
  }

  /// Sign in with email and password. Returns the localId (UID).
  Future<FirebaseAuthResult> signInWithEmailAndPassword(String email, String password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final error = body['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? 'Unknown error';
      throw FirebaseAuthRestException(message);
    }

    return FirebaseAuthResult(
      uid: body['localId'] as String,
      email: body['email'] as String,
      idToken: body['idToken'] as String,
      refreshToken: body['refreshToken'] as String,
    );
  }
}

class FirebaseAuthResult {
  const FirebaseAuthResult({
    required this.uid,
    required this.email,
    required this.idToken,
    required this.refreshToken,
  });

  final String uid;
  final String email;
  final String idToken;
  final String refreshToken;
}

class FirebaseAuthRestException implements Exception {
  FirebaseAuthRestException(this.rawCode);

  final String rawCode;

  String get userMessage {
    switch (rawCode) {
      case 'EMAIL_NOT_FOUND':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password.';
      case 'INVALID_PASSWORD':
        return 'Invalid password.';
      case 'INVALID_EMAIL':
        return 'Invalid email address.';
      case 'USER_DISABLED':
        return 'This account has been disabled.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Too many attempts. Try again later.';
      default:
        if (rawCode.contains('INVALID_LOGIN_CREDENTIALS')) {
          return 'Invalid email or password.';
        }
        return rawCode;
    }
  }

  @override
  String toString() => userMessage;
}
