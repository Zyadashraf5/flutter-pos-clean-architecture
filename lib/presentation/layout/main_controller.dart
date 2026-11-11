import 'dart:ui';

import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../auth/auth_controller.dart';
import '../../data/datasources/local/local_storage.dart';

class MainController extends GetxController {
  final currentRoute = AppRoutes.dashboard.obs;

  /// Whether the sidebar drawer is open (for mobile/tablet).
  final sidebarOpen = false.obs;

  void goTo(String route) {
    if (!Get.find<AuthController>().canAccessRoute(route)) return;
    currentRoute.value = route;
    // Auto-close sidebar on mobile after navigation
    sidebarOpen.value = false;
  }

  void toggleSidebar() => sidebarOpen.value = !sidebarOpen.value;

  /// Switch app language (ar / en) and persist.
  void setLocale(String languageCode) {
    LocalStorage.settingsBox.put('locale', languageCode);
    Get.updateLocale(Locale(languageCode));
  }
}
