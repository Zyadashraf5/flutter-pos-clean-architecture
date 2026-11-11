import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import 'local_storage.dart';

class SettingsLocalDatasource {
  Box<dynamic> get _box => LocalStorage.settingsBox;

  Future<double> getDefaultTaxPercent() async {
    final v = _box.get(AppConstants.keyDefaultTaxPercent);
    if (v is num) return v.toDouble();
    return AppConstants.defaultTaxPercent;
  }

  Future<void> setDefaultTaxPercent(double value) async {
    await _box.put(AppConstants.keyDefaultTaxPercent, value);
  }
}
