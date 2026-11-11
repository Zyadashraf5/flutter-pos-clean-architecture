import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in with email and password via Firebase Auth, then fetch user profile from Firestore.
  /// Throws [AuthException] if user not found, inactive, or login fails.
  Future<UserEntity> login(String email, String password);

  /// Sign out from Firebase Auth.
  Future<void> logout();

  /// Get currently signed-in user profile (from Firebase Auth UID + Firestore).
  /// Returns null if not signed in or user doc missing/inactive.
  Future<UserEntity?> getCurrentUser();

  /// Fetch user profile from Firestore by Firebase Auth UID.
  Future<UserEntity?> getUserProfile(String uid);
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
