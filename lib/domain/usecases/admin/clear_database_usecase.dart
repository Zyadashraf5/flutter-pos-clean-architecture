import '../../repositories/seed_repository.dart';

class ClearDatabaseUseCase {
  ClearDatabaseUseCase(this._repository);

  final SeedRepository _repository;

  Future<void> call() => _repository.clear();
}
