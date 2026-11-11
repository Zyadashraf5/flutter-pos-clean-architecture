import '../../entities/employee_entity.dart';
import '../../repositories/employee_repository.dart';

class GetEmployees {
  GetEmployees(this._repository);

  final EmployeeRepository _repository;

  Future<List<EmployeeEntity>> call() => _repository.getAll();
}
