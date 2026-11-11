/// Repository contract for Firebase connection verification.
/// Domain layer — no Firestore or UI references.
abstract class FirebaseConnectionRepository {
  /// Writes a test document to Firestore to confirm connection.
  Future<void> testConnection();
}
