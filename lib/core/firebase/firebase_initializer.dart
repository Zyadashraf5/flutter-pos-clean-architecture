import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../constants/app_constants.dart';
import '../../firebase_options.dart';

/// Centralized Firebase initialization.
/// No UI or business logic — only initialization.
class FirebaseInitializer {
  FirebaseInitializer._();

  static bool _initialized = false;

  /// Call once at app startup (e.g. in main.dart).
  /// Uses [DefaultFirebaseOptions.currentPlatform] for the active platform.
  static Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (const bool.fromEnvironment('USE_FIREBASE_EMULATORS')) {
      if (!Firebase.app().options.projectId.startsWith('demo-')) {
        throw StateError('Emulator mode requires a demo- project id.');
      }
      FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8081);
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
    }
    _initialized = true;
  }

  static bool get isInitialized => _initialized;
}

/// Firestore path constants for multi-user / sync readiness.
class FirestorePaths {
  FirestorePaths._();

  static const String test = AppConstants.firestoreCollectionTest;
  static const String categories = AppConstants.firestoreCollectionCategories;
  static const String products = AppConstants.firestoreCollectionProducts;
  static const String orders = AppConstants.firestoreCollectionOrders;
  static const String orderItems =
      AppConstants.firestoreSubcollectionOrderItems;
  static const String financialSummary =
      AppConstants.firestoreCollectionFinancialSummary;
  static const String systemSettings =
      AppConstants.firestoreCollectionSystemSettings;
  static const String docFinancialSummary =
      AppConstants.firestoreDocFinancialSummary;
  static const String docSystemSettings =
      AppConstants.firestoreDocSystemSettings;
  static const String docSeedFlag = AppConstants.firestoreDocSeedFlag;
  static const String suppliers = AppConstants.firestoreCollectionSuppliers;
  static const String purchases = AppConstants.firestoreCollectionPurchases;
  static const String purchaseItems =
      AppConstants.firestoreSubcollectionPurchaseItems;
  static const String stockAdjustments =
      AppConstants.firestoreCollectionStockAdjustments;
  static const String inventoryDevices =
      AppConstants.firestoreCollectionInventoryDevices;
  static const String employees = AppConstants.firestoreCollectionEmployees;
  static const String users = AppConstants.firestoreCollectionUsers;
  static const String auditLogs = AppConstants.firestoreCollectionAuditLogs;
}
