import '../../repositories/firestore_stats_repository.dart';

class GetFirestoreStatsUseCase {
  GetFirestoreStatsUseCase(this._repository);

  final FirestoreStatsRepository _repository;

  Future<FirestoreStatsEntity> call() => _repository.getStats();
}
