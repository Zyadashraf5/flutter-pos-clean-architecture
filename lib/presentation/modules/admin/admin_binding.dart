import 'package:get/get.dart';

import '../../../domain/usecases/admin/clear_database_usecase.dart';
import '../../../domain/usecases/admin/get_firestore_stats_usecase.dart';
import '../../../domain/usecases/admin/seed_database_usecase.dart';
import 'admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(
      () => AdminController(
        Get.find<SeedDatabaseUseCase>(),
        Get.find<ClearDatabaseUseCase>(),
        Get.find<GetFirestoreStatsUseCase>(),
      ),
    );
  }
}
