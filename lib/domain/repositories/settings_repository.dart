abstract class SettingsRepository {
  Future<double> getDefaultTaxPercent();
  Future<void> setDefaultTaxPercent(double value);
}
