import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../presentation/auth/auth_controller.dart';
import 'app_routes.dart';

/// Redirects to login if user is not authenticated.
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
