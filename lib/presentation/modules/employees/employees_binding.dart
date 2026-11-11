import 'package:get/get.dart';

import '../../../domain/usecases/employee/create_employee.dart';
import '../../../domain/usecases/employee/get_employees.dart';
import '../../../domain/usecases/employee/reset_employee_password.dart';
import '../../../domain/usecases/employee/update_employee.dart';
import 'employees_controller.dart';

class EmployeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeesController>(
      () => EmployeesController(
        Get.find<GetEmployees>(),
        Get.find<CreateEmployee>(),
        Get.find<UpdateEmployee>(),
        Get.find<ResetEmployeePassword>(),
      ),
    );
  }
}
