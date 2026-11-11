import 'package:get/get.dart';

import '../../presentation/auth/auth_binding.dart';
import '../../presentation/auth/login_view.dart';
import '../../presentation/layout/main_binding.dart';
import '../../presentation/layout/main_layout.dart';
import 'app_routes.dart';
import 'auth_guard.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.main;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainLayout(),
      binding: MainBinding(),
      middlewares: [AuthGuard()],
    ),
  ];
}
