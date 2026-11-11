import '../../entities/supplier_entity.dart';
import '../../repositories/supplier_repository.dart';

class UpdateSupplier {
  UpdateSupplier(this._repository);

  final SupplierRepository _repository;

  Future<void> call(SupplierEntity entity) => _repository.update(entity);
}
