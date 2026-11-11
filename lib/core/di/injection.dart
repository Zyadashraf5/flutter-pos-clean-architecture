import 'package:get/get.dart';

import '../../data/datasources/firebase/firebase_category_datasource.dart';
import '../../data/datasources/firebase/firebase_connection_datasource.dart';
import '../../data/datasources/firebase/firebase_financial_summary_datasource.dart';
import '../../data/datasources/firebase/firebase_order_datasource.dart';
import '../../data/datasources/firebase/firebase_product_datasource.dart';
import '../../data/datasources/firebase/firebase_product_firestore_datasource.dart';
import '../../data/datasources/firebase/firebase_seeder_datasource.dart';
import '../../data/datasources/firebase/firebase_system_settings_datasource.dart';
import '../../data/datasources/firebase/firebase_supplier_datasource.dart';
import '../../data/datasources/firebase/firebase_purchase_datasource.dart';
import '../../data/datasources/firebase/firebase_employee_datasource.dart';
import '../../data/datasources/firebase/firebase_user_datasource.dart';
import '../../data/datasources/firebase/firebase_inventory_device_datasource.dart';
import '../../data/datasources/local/category_local_datasource.dart';
import '../../data/datasources/local/financial_local_datasource.dart';
import '../../data/datasources/local/order_local_datasource.dart';
import '../../data/datasources/local/product_local_datasource.dart';
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/repositories/firebase_connection_repository_impl.dart';
import '../../data/repositories/firestore_stats_repository_impl.dart';
import '../../data/repositories/seed_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/financial_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import '../../data/repositories/purchase_repository_impl.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/inventory_device_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/financial_repository.dart';
import '../../domain/repositories/firebase_connection_repository.dart';
import '../../domain/repositories/firestore_stats_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/seed_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/inventory_device_repository.dart';
import '../../domain/usecases/admin/clear_database_usecase.dart';
import '../../domain/usecases/admin/get_firestore_stats_usecase.dart';
import '../../domain/usecases/admin/seed_database_usecase.dart';
import '../../domain/usecases/firebase/test_firebase_connection_usecase.dart';
import '../../domain/usecases/category/create_category.dart';
import '../../domain/usecases/category/delete_category.dart';
import '../../domain/usecases/category/get_categories.dart';
import '../../domain/usecases/category/update_category.dart';
import '../../domain/usecases/financial/get_financial_summary.dart';
import '../../domain/usecases/order/create_order.dart';
import '../../domain/usecases/order/delete_order.dart';
import '../../domain/usecases/order/get_orders.dart';
import '../../domain/usecases/product/create_product.dart';
import '../../domain/usecases/product/delete_product.dart';
import '../../domain/usecases/product/get_product_by_barcode.dart';
import '../../domain/usecases/product/get_products.dart';
import '../../domain/usecases/product/increase_stock.dart';
import '../../domain/usecases/product/update_product.dart';
import '../../domain/usecases/purchase/create_purchase.dart';
import '../../domain/usecases/purchase/get_purchases.dart';
import '../../domain/usecases/supplier/create_supplier.dart';
import '../../domain/usecases/supplier/delete_supplier.dart';
import '../../domain/usecases/supplier/get_suppliers.dart';
import '../../domain/usecases/supplier/record_supplier_payment.dart';
import '../../domain/usecases/supplier/update_supplier.dart';
import '../../domain/usecases/settings/get_default_tax.dart';
import '../../domain/usecases/settings/set_default_tax.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/employee/create_employee.dart';
import '../../domain/usecases/employee/get_employees.dart';
import '../../domain/usecases/employee/reset_employee_password.dart';
import '../../domain/usecases/employee/update_employee.dart';
import '../../domain/usecases/inventory/add_inventory_device.dart';
import '../../domain/usecases/inventory/get_inventory_devices.dart';
import '../../domain/usecases/inventory/get_inventory_device_by_barcode.dart';
import '../../domain/usecases/inventory/update_inventory_device.dart';
import '../../presentation/auth/auth_controller.dart';

Future<void> initDependencies() async {
  // Local datasources
  Get.lazyPut<CategoryLocalDatasource>(
    () => CategoryLocalDatasource(),
    fenix: true,
  );
  Get.lazyPut<ProductLocalDatasource>(
    () => ProductLocalDatasource(),
    fenix: true,
  );
  Get.lazyPut<OrderLocalDatasource>(() => OrderLocalDatasource(), fenix: true);
  Get.lazyPut<SettingsLocalDatasource>(
    () => SettingsLocalDatasource(),
    fenix: true,
  );
  Get.lazyPut<FinancialLocalDatasource>(
    () => FinancialLocalDatasource(),
    fenix: true,
  );

  // Firebase datasources
  Get.lazyPut<FirebaseConnectionDataSource>(
    () => FirebaseConnectionDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseProductDataSource>(
    () => FirebaseProductDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseCategoryDataSource>(
    () => FirebaseCategoryDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseProductFirestoreDataSource>(
    () => FirebaseProductFirestoreDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseOrderDataSource>(
    () => FirebaseOrderDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseFinancialSummaryDataSource>(
    () => FirebaseFinancialSummaryDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseSystemSettingsDataSource>(
    () => FirebaseSystemSettingsDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseSupplierDataSource>(
    () => FirebaseSupplierDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebasePurchaseDataSource>(
    () => FirebasePurchaseDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseEmployeeDataSource>(
    () => FirebaseEmployeeDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseInventoryDeviceDataSource>(
    () => FirebaseInventoryDeviceDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseUserDataSource>(
    () => FirebaseUserDataSourceImpl(),
    fenix: true,
  );
  Get.lazyPut<FirebaseSeederDataSource>(
    () => FirebaseSeederDataSourceImpl(
      categoryDataSource: Get.find<FirebaseCategoryDataSource>(),
      productDataSource: Get.find<FirebaseProductFirestoreDataSource>(),
      orderDataSource: Get.find<FirebaseOrderDataSource>(),
      financialSummaryDataSource:
          Get.find<FirebaseFinancialSummaryDataSource>(),
      systemSettingsDataSource: Get.find<FirebaseSystemSettingsDataSource>(),
    ),
    fenix: true,
  );

  // Repositories
  Get.lazyPut<CategoryRepository>(
    () => CategoryRepositoryImpl(
      Get.find<CategoryLocalDatasource>(),
      firestore: Get.find<FirebaseCategoryDataSource>(),
    ),
    fenix: true,
  );
  Get.lazyPut<ProductRepository>(
    () => ProductRepositoryImpl(
      Get.find<ProductLocalDatasource>(),
      remote: Get.find<FirebaseProductDataSource>(),
      firestoreRead: Get.find<FirebaseProductFirestoreDataSource>(),
    ),
    fenix: true,
  );
  Get.lazyPut<FirebaseConnectionRepository>(
    () => FirebaseConnectionRepositoryImpl(
      Get.find<FirebaseConnectionDataSource>(),
    ),
    fenix: true,
  );
  Get.lazyPut<OrderRepository>(
    () => OrderRepositoryImpl(
      Get.find<OrderLocalDatasource>(),
      firestore: Get.find<FirebaseOrderDataSource>(),
    ),
    fenix: true,
  );
  Get.lazyPut<SettingsRepository>(
    () => SettingsRepositoryImpl(Get.find<SettingsLocalDatasource>()),
    fenix: true,
  );
  Get.lazyPut<FinancialRepository>(
    () => FinancialRepositoryImpl(
      Get.find<FinancialLocalDatasource>(),
      Get.find<OrderRepository>(),
      Get.find<ProductRepository>(),
      firestoreSummary: Get.find<FirebaseFinancialSummaryDataSource>(),
    ),
    fenix: true,
  );
  Get.lazyPut<SupplierRepository>(
    () => SupplierRepositoryImpl(Get.find<FirebaseSupplierDataSource>()),
    fenix: true,
  );
  Get.lazyPut<PurchaseRepository>(
    () => PurchaseRepositoryImpl(Get.find<FirebasePurchaseDataSource>()),
    fenix: true,
  );
  Get.lazyPut<EmployeeRepository>(
    () => EmployeeRepositoryImpl(Get.find<FirebaseEmployeeDataSource>()),
    fenix: true,
  );
  Get.lazyPut<AuthRepository>(
    () => AuthRepositoryImpl(Get.find<EmployeeRepository>()),
    fenix: true,
  );
  Get.lazyPut<InventoryDeviceRepository>(
    () => InventoryDeviceRepositoryImpl(
      Get.find<FirebaseInventoryDeviceDataSource>(),
    ),
    fenix: true,
  );

  // Use cases - Category
  Get.lazyPut(() => GetCategories(Get.find<CategoryRepository>()), fenix: true);
  Get.lazyPut(
    () => CreateCategory(Get.find<CategoryRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => UpdateCategory(Get.find<CategoryRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => DeleteCategory(Get.find<CategoryRepository>()),
    fenix: true,
  );

  // Use cases - Product
  Get.lazyPut(() => GetProducts(Get.find<ProductRepository>()), fenix: true);
  Get.lazyPut(
    () => GetProductByBarcode(Get.find<ProductRepository>()),
    fenix: true,
  );
  Get.lazyPut(() => CreateProduct(Get.find<ProductRepository>()), fenix: true);
  Get.lazyPut(() => UpdateProduct(Get.find<ProductRepository>()), fenix: true);
  Get.lazyPut(() => DeleteProduct(Get.find<ProductRepository>()), fenix: true);
  Get.lazyPut(() => IncreaseStock(Get.find<ProductRepository>()), fenix: true);

  // Use cases - Inventory Devices
  Get.lazyPut(
    () => AddInventoryDevice(Get.find<InventoryDeviceRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => GetInventoryDevices(Get.find<InventoryDeviceRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => GetInventoryDeviceByBarcode(Get.find<InventoryDeviceRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => UpdateInventoryDevice(Get.find<InventoryDeviceRepository>()),
    fenix: true,
  );

  // Use cases - Order
  Get.lazyPut(() => GetOrders(Get.find<OrderRepository>()), fenix: true);
  Get.lazyPut(() => DeleteOrder(Get.find<OrderRepository>()), fenix: true);
  Get.lazyPut(
    () => CreateOrder(
      Get.find<OrderRepository>(),
      Get.find<InventoryDeviceRepository>(),
      Get.find<FinancialRepository>(),
    ),
    fenix: true,
  );

  // Use cases - Financial & Settings
  Get.lazyPut(
    () => GetFinancialSummary(Get.find<FinancialRepository>()),
    fenix: true,
  );
  Get.lazyPut(() => GetDefaultTax(Get.find<SettingsRepository>()), fenix: true);
  Get.lazyPut(() => SetDefaultTax(Get.find<SettingsRepository>()), fenix: true);
  Get.lazyPut(
    () => CreatePurchase(
      Get.find<PurchaseRepository>(),
      Get.find<ProductRepository>(),
      Get.find<SupplierRepository>(),
      Get.find<FinancialRepository>(),
    ),
    fenix: true,
  );
  Get.lazyPut(
    () => RecordSupplierPayment(
      Get.find<SupplierRepository>(),
      Get.find<FinancialRepository>(),
    ),
    fenix: true,
  );
  Get.lazyPut(() => GetSuppliers(Get.find<SupplierRepository>()), fenix: true);
  Get.lazyPut(
    () => DeleteSupplier(Get.find<SupplierRepository>()),
    fenix: true,
  );
  Get.lazyPut(() => GetPurchases(Get.find<PurchaseRepository>()), fenix: true);
  Get.lazyPut(
    () => CreateSupplier(Get.find<SupplierRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => UpdateSupplier(Get.find<SupplierRepository>()),
    fenix: true,
  );

  // Auth - Firebase Auth + Firestore users (must be available before first route)
  Get.put<AuthController>(
    AuthController(Get.find<AuthRepository>()),
    permanent: true,
  );
  Get.lazyPut(() => LoginUseCase(Get.find<EmployeeRepository>()), fenix: true);
  Get.lazyPut(() => GetEmployees(Get.find<EmployeeRepository>()), fenix: true);
  Get.lazyPut(
    () => CreateEmployee(Get.find<EmployeeRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => UpdateEmployee(Get.find<EmployeeRepository>()),
    fenix: true,
  );
  Get.lazyPut(
    () => ResetEmployeePassword(Get.find<EmployeeRepository>()),
    fenix: true,
  );

  // Use cases - Firebase
  Get.lazyPut<TestFirebaseConnectionUseCase>(
    () =>
        TestFirebaseConnectionUseCase(Get.find<FirebaseConnectionRepository>()),
    fenix: true,
  );

  // Repositories - Admin / Firestore
  Get.lazyPut<SeedRepository>(
    () => SeedRepositoryImpl(Get.find<FirebaseSeederDataSource>()),
    fenix: true,
  );
  Get.lazyPut<FirestoreStatsRepository>(
    () => FirestoreStatsRepositoryImpl(
      categoryDataSource: Get.find<FirebaseCategoryDataSource>(),
      productDataSource: Get.find<FirebaseProductFirestoreDataSource>(),
      orderDataSource: Get.find<FirebaseOrderDataSource>(),
      financialSummaryDataSource:
          Get.find<FirebaseFinancialSummaryDataSource>(),
    ),
    fenix: true,
  );

  // Use cases - Admin
  Get.lazyPut<SeedDatabaseUseCase>(
    () => SeedDatabaseUseCase(Get.find<SeedRepository>()),
    fenix: true,
  );
  Get.lazyPut<ClearDatabaseUseCase>(
    () => ClearDatabaseUseCase(Get.find<SeedRepository>()),
    fenix: true,
  );
  Get.lazyPut<GetFirestoreStatsUseCase>(
    () => GetFirestoreStatsUseCase(Get.find<FirestoreStatsRepository>()),
    fenix: true,
  );
}
