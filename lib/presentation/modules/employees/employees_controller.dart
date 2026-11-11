import 'package:get/get.dart';

import '../../../domain/auth/permission.dart';
import '../../../domain/entities/employee_entity.dart';
import '../../../domain/usecases/employee/create_employee.dart';
import '../../../domain/usecases/employee/get_employees.dart';
import '../../../domain/usecases/employee/reset_employee_password.dart';
import '../../../domain/usecases/employee/update_employee.dart';
import '../../auth/auth_controller.dart';

class EmployeesController extends GetxController {
  EmployeesController(
    this._getEmployees,
    this._createEmployee,
    this._updateEmployee,
    this._resetPassword,
  );

  final GetEmployees _getEmployees;
  final CreateEmployee _createEmployee;
  final UpdateEmployee _updateEmployee;
  final ResetEmployeePassword _resetPassword;

  final employees = <EmployeeEntity>[].obs;
  final loading = false.obs;
  final searchQuery = ''.obs;
  final roleFilter = Rx<EmployeeRole?>(null);
  final saving = false.obs;

  @override
  void onReady() {
    loadEmployees();
    super.onReady();
  }

  bool get _hasPermission =>
      Get.find<AuthController>().hasPermissionEnum(Permission.manageEmployees);

  Future<void> loadEmployees() async {
    if (!_hasPermission) return;
    loading.value = true;
    try {
      final list = await _getEmployees();
      employees.assignAll(list);
    } finally {
      loading.value = false;
    }
  }

  List<EmployeeEntity> get filteredEmployees {
    List<EmployeeEntity> list = List.from(employees);
    final role = roleFilter.value;
    if (role != null) {
      list = list.where((e) => e.role == role).toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((e) =>
              e.name.toLowerCase().contains(q) || e.email.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Future<bool> addEmployee({
    required String name,
    required String email,
    required String password,
    required EmployeeRole role,
    bool isActive = true,
  }) async {
    if (!_hasPermission) return false;
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) return false;
    saving.value = true;
    try {
      final id = 'emp_${DateTime.now().millisecondsSinceEpoch}';
      await _createEmployee(
        id: id,
        name: name,
        email: email,
        plainPassword: password,
        role: role,
        isActive: isActive,
      );
      await loadEmployees();
      return true;
    } finally {
      saving.value = false;
    }
  }

  Future<bool> updateEmployee({
    required String id,
    String? name,
    String? email,
    EmployeeRole? role,
    bool? isActive,
  }) async {
    if (!_hasPermission) return false;
    saving.value = true;
    try {
      await _updateEmployee(id: id, name: name, email: email, role: role, isActive: isActive);
      await loadEmployees();
      return true;
    } finally {
      saving.value = false;
    }
  }

  Future<bool> setActive(String id, bool active) async {
    if (!_hasPermission) return false;
    saving.value = true;
    try {
      await _updateEmployee(id: id, isActive: active);
      await loadEmployees();
      return true;
    } finally {
      saving.value = false;
    }
  }

  Future<bool> resetPassword(String id, String newPassword) async {
    if (!_hasPermission) return false;
    if (newPassword.isEmpty) return false;
    saving.value = true;
    try {
      await _resetPassword(id, newPassword);
      return true;
    } finally {
      saving.value = false;
    }
  }

  /// Soft delete: set isActive = false
  Future<bool> deleteEmployee(String id) async {
    if (!_hasPermission) return false;
    return setActive(id, false);
  }
}
