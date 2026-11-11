import '../../repositories/supplier_repository.dart';

class DeleteSupplier {
  DeleteSupplier(this._repository);

  final SupplierRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
