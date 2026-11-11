import '../../entities/purchase_entity.dart';
import '../../repositories/purchase_repository.dart';

class GetPurchases {
  GetPurchases(this._repository);

  final PurchaseRepository _repository;

  Future<List<PurchaseEntity>> call() => _repository.getAll();
}
