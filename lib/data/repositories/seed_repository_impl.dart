import '../../domain/repositories/seed_repository.dart';
import '../datasources/firebase/firebase_seeder_datasource.dart';

class SeedRepositoryImpl implements SeedRepository {
  SeedRepositoryImpl(this._dataSource);

  final FirebaseSeederDataSource _dataSource;

  @override
  Future<SeedResultEntity> seed() async {
    final result = await _dataSource.seed();
    return SeedResultEntity(
      success: result.success,
      message: result.message,
      categoriesCount: result.categoriesCount,
      productsCount: result.productsCount,
      ordersCount: result.ordersCount,
    );
  }

  @override
  Future<void> clear() => _dataSource.clear();
}
