import '../../entities/financial_entity.dart';
import '../../repositories/financial_repository.dart';

class GetFinancialSummary {
  GetFinancialSummary(this._repository);

  final FinancialRepository _repository;

  Future<FinancialSummaryEntity> call() => _repository.getSummary();
}
