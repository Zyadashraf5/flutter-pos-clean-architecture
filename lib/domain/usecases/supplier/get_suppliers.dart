import '../../entities/supplier_entity.dart';
import '../../repositories/supplier_repository.dart';

class GetSuppliers {
  GetSuppliers(this._repository);

  final SupplierRepository _repository;

  Future<List<SupplierEntity>> call() => _repository.getAll();
}
