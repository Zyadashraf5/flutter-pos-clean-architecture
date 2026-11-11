import '../../repositories/seed_repository.dart';

class SeedDatabaseUseCase {
  SeedDatabaseUseCase(this._repository);

  final SeedRepository _repository;

  Future<SeedResultEntity> call() => _repository.seed();
}
