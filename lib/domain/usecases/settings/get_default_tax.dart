import '../../repositories/settings_repository.dart';

class GetDefaultTax {
  GetDefaultTax(this._repository);

  final SettingsRepository _repository;

  Future<double> call() => _repository.getDefaultTaxPercent();
}
