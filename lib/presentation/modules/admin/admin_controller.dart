import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../domain/auth/permission.dart';
import '../../../domain/repositories/firestore_stats_repository.dart';
import '../../../domain/usecases/admin/clear_database_usecase.dart';
import '../../../domain/usecases/admin/get_firestore_stats_usecase.dart';
import '../../../domain/usecases/admin/seed_database_usecase.dart';
import '../../auth/auth_controller.dart';

class AdminController extends GetxController {
  AdminController(
    this._seedDatabaseUseCase,
    this._clearDatabaseUseCase,
    this._getFirestoreStatsUseCase,
  );

  final SeedDatabaseUseCase _seedDatabaseUseCase;
  final ClearDatabaseUseCase _clearDatabaseUseCase;
  final GetFirestoreStatsUseCase _getFirestoreStatsUseCase;

  final loading = false.obs;
  final stats = Rxn<FirestoreStatsEntity>();

  @override
  void onReady() {
    loadStats();
    super.onReady();
  }

  Future<void> loadStats() async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.manageEmployees)) return;
    loading.value = true;
    try {
      stats.value = await _getFirestoreStatsUseCase();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AdminController loadStats: $e');
        debugPrint(st.toString());
      }
    } finally {
      loading.value = false;
    }
  }

  Future<void> seedDatabase() async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.manageEmployees)) return;
    loading.value = true;
    try {
      final result = await _seedDatabaseUseCase();
      Get.snackbar(
        result.success ? 'Seeded' : 'Error',
        result.message,
      );
      await loadStats();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> clearDatabase() async {
    if (!Get.find<AuthController>().hasPermissionEnum(Permission.manageEmployees)) return;
    loading.value = true;
    try {
      await _clearDatabaseUseCase();
      Get.snackbar('Cleared', 'Firestore data cleared.');
      await loadStats();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      loading.value = false;
    }
  }
}
