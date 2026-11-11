import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import 'local_storage.dart';

class FinancialLocalDatasource {
  Box<dynamic> get _box => LocalStorage.financialBox;

  Future<double> getTotalCash() async {
    final v = _box.get(AppConstants.keyTotalCash);
    if (v is num) return v.toDouble();
    return 0.0;
  }

  Future<double> getTotalCredit() async {
    final v = _box.get(AppConstants.keyTotalCredit);
    if (v is num) return v.toDouble();
    return 0.0;
  }

  Future<void> setTotalCash(double value) async {
    await _box.put(AppConstants.keyTotalCash, value);
  }

  Future<void> setTotalCredit(double value) async {
    await _box.put(AppConstants.keyTotalCredit, value);
  }

  Future<void> addToCash(double amount) async {
    final current = await getTotalCash();
    await setTotalCash(current + amount);
  }

  Future<void> addToCredit(double amount) async {
    final current = await getTotalCredit();
    await setTotalCredit(current + amount);
  }
}
