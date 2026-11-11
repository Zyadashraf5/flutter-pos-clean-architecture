import 'package:cashiere_system/core/routes/app_routes.dart';
import 'package:cashiere_system/domain/entities/user_entity.dart';
import 'package:cashiere_system/domain/repositories/auth_repository.dart';
import 'package:cashiere_system/presentation/auth/auth_controller.dart';
import 'package:cashiere_system/presentation/layout/main_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestAuthController extends AuthController {
  TestAuthController() : super(UnusedAuthRepository());

  @override
  void onReady() {}
}

void main() {
  late AuthController auth;
  late MainController navigation;

  setUp(() {
    Get.testMode = true;
    auth = Get.put<AuthController>(TestAuthController());
    navigation = MainController();
  });

  tearDown(() => Get.reset());

  void signIn(UserRole role) {
    auth.currentUser.value = UserEntity(
      uid: 'test-user',
      name: 'Test user',
      email: 'test@example.invalid',
      role: role,
      isActive: true,
      createdAt: DateTime(2026),
    );
  }

  test('signed-out users cannot navigate to a protected screen', () {
    navigation.goTo(AppRoutes.orders);
    expect(navigation.currentRoute.value, AppRoutes.dashboard);
  });

  test('cashiers cannot navigate directly to finance or admin screens', () {
    signIn(UserRole.cashier);
    navigation.goTo(AppRoutes.orders);
    expect(navigation.currentRoute.value, AppRoutes.orders);
    for (final route in [AppRoutes.financial, AppRoutes.admin, AppRoutes.employees]) {
      navigation.goTo(route);
      expect(navigation.currentRoute.value, AppRoutes.orders);
    }
  });

  test('finance users can reach financials but cannot create orders', () {
    signIn(UserRole.finance);
    navigation.goTo(AppRoutes.financial);
    expect(navigation.currentRoute.value, AppRoutes.financial);
    navigation.goTo(AppRoutes.orderCreate);
    expect(navigation.currentRoute.value, AppRoutes.financial);
  });

  test('admins can reach known screens but not unmapped routes', () {
    signIn(UserRole.admin);
    navigation.goTo(AppRoutes.admin);
    expect(navigation.currentRoute.value, AppRoutes.admin);
    navigation.goTo('/unmapped-screen');
    expect(navigation.currentRoute.value, AppRoutes.admin);
  });

  test('navigation is denied after the session is cleared', () {
    signIn(UserRole.admin);
    navigation.goTo(AppRoutes.orders);
    auth.currentUser.value = null;
    navigation.goTo(AppRoutes.admin);
    expect(navigation.currentRoute.value, AppRoutes.orders);
  });
}
