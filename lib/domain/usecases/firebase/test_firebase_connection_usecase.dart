import '../../repositories/firebase_connection_repository.dart';

/// Use case: write a test document to Firestore to confirm Firebase connection.
/// Controller calls this — no Firestore logic in UI or controller.
class TestFirebaseConnectionUseCase {
  TestFirebaseConnectionUseCase(this._repository);

  final FirebaseConnectionRepository _repository;

  Future<void> call() => _repository.testConnection();
}
