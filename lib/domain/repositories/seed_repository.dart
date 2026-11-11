/// Result of a seed operation. No Firestore or UI references.
class SeedResultEntity {
  const SeedResultEntity({
    required this.success,
    required this.message,
    this.categoriesCount = 0,
    this.productsCount = 0,
    this.ordersCount = 0,
  });

  final bool success;
  final String message;
  final int categoriesCount;
  final int productsCount;
  final int ordersCount;
}

abstract class SeedRepository {
  Future<SeedResultEntity> seed();
  Future<void> clear();
}
