import '../entities/purchase_entity.dart';

abstract class PurchaseRepository {
  Future<List<PurchaseEntity>> getAll();
  Future<List<PurchaseEntity>> getByDateRange(DateTime start, DateTime end);
  Future<void> create(PurchaseEntity purchase);
}
