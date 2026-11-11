import '../../repositories/settings_repository.dart';

class SetDefaultTax {
  SetDefaultTax(this._repository);

  final SettingsRepository _repository;

  Future<void> call(double value) => _repository.setDefaultTaxPercent(value);
}
