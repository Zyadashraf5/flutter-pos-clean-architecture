import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._datasource);

  final SettingsLocalDatasource _datasource;

  @override
  Future<double> getDefaultTaxPercent() =>
      _datasource.getDefaultTaxPercent();

  @override
  Future<void> setDefaultTaxPercent(double value) =>
      _datasource.setDefaultTaxPercent(value);
}
