import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

/// Central Hive initialization and box access.
class LocalStorage {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(AppConstants.boxCategories);
    await Hive.openBox<dynamic>(AppConstants.boxProducts);
    await Hive.openBox<dynamic>(AppConstants.boxOrders);
    await Hive.openBox<dynamic>(AppConstants.boxSettings);
    await Hive.openBox<dynamic>(AppConstants.boxFinancial);
    await Hive.openBox<dynamic>(AppConstants.boxAuth);
    _initialized = true;
  }

  static Box<dynamic> get authBox => Hive.box<dynamic>(AppConstants.boxAuth);

  static Box<dynamic> get categoriesBox =>
      Hive.box<dynamic>(AppConstants.boxCategories);
  static Box<dynamic> get productsBox =>
      Hive.box<dynamic>(AppConstants.boxProducts);
  static Box<dynamic> get ordersBox =>
      Hive.box<dynamic>(AppConstants.boxOrders);
  static Box<dynamic> get settingsBox =>
      Hive.box<dynamic>(AppConstants.boxSettings);
  static Box<dynamic> get financialBox =>
      Hive.box<dynamic>(AppConstants.boxFinancial);
}
