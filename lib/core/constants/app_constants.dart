/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // Hive box names
  static const String boxCategories = 'categories';
  static const String boxProducts = 'products';
  static const String boxOrders = 'orders';
  static const String boxSettings = 'settings';
  static const String boxFinancial = 'financial';
  static const String boxAuth = 'auth';

  // Auth keys
  static const String keySessionEmployeeId = 'session_employee_id';
  static const String keySessionUid = 'session_uid';
  static const String keyRememberMe = 'remember_me';

  // Settings keys
  static const String keyDefaultTaxPercent = 'default_tax_percent';
  static const String keyTotalCash = 'total_cash';
  static const String keyTotalCredit = 'total_credit';

  // Defaults
  static const double defaultTaxPercent = 0.0;
  static const int lowStockThreshold = 5;

  // App
  static const String appName = 'Cashiere System';

  // Firestore collections (enterprise schema)
  static const String firestoreCollectionTest = 'test';
  static const String firestoreCollectionCategories = 'categories';
  static const String firestoreCollectionProducts = 'products';
  static const String firestoreCollectionOrders = 'orders';
  static const String firestoreSubcollectionOrderItems = 'order_items';
  static const String firestoreCollectionFinancialSummary = 'financial_summary';
  static const String firestoreCollectionSystemSettings = 'system_settings';
  static const String firestoreCollectionSuppliers = 'suppliers';
  static const String firestoreCollectionPurchases = 'purchases';
  static const String firestoreSubcollectionPurchaseItems = 'purchase_items';
  static const String firestoreCollectionStockAdjustments = 'stock_adjustments';
  static const String firestoreCollectionInventoryDevices = 'inventory_devices';
  static const String firestoreCollectionEmployees = 'employees';
  static const String firestoreCollectionUsers = 'users';
  static const String firestoreCollectionAuditLogs = 'audit_logs';

  // Single-document IDs
  static const String firestoreDocFinancialSummary = 'current';
  static const String firestoreDocSystemSettings = 'main';
  static const String firestoreDocSeedFlag = 'seed_run';
}
