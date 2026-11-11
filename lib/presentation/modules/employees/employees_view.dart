import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/employee_entity.dart';
import '../../widgets/empty_state.dart';
import 'employees_controller.dart';

class EmployeesView extends GetView<EmployeesController> {
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr('employees')),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => _showAddDialog(context, tr),
              icon: const Icon(Icons.add, size: 20),
              label: Text(tr('add_employee')),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < AppSpacing.breakpointMobile;
          final padding = isMobile ? AppSpacing.sm : AppSpacing.md;
          return Container(
            constraints: const BoxConstraints.expand(),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FiltersRow(tr: tr, isMobile: isMobile),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Obx(() {
                    if (controller.loading.value) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              tr('loading'),
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final list = controller.filteredEmployees;
                    if (list.isEmpty) {
                      return EmptyState(
                        message: tr('no_employees'),
                        icon: Icons.people_outline,
                      );
                    }
                    if (isMobile) {
                      // Card list for mobile
                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, i) => _EmployeeMobileCard(
                          employee: list[i],
                          tr: tr,
                          onEdit: () => _showEditDialog(context, tr, list[i]),
                          onToggle: () => controller.setActive(
                            list[i].id,
                            !list[i].isActive,
                          ),
                          onResetPassword: () =>
                              _showResetPasswordDialog(context, tr, list[i].id),
                          onDelete: list[i].isActive
                              ? () => _confirmDelete(context, tr, list[i].id)
                              : null,
                        ),
                      );
                    }
                    // DataTable for desktop/tablet
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.surfaceVariant,
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                tr('name'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                tr('email'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                tr('role'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                tr('status'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                tr('actions'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          rows: list
                              .map((e) => _employeeRow(e, context, tr))
                              .toList(),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  DataRow _employeeRow(
    EmployeeEntity e,
    BuildContext context,
    String Function(String key, [String? fallback]) tr,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(e.name)),
        DataCell(Text(e.email)),
        DataCell(Text(e.role.displayName)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: e.isActive
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              e.isActive ? tr('active') : tr('disabled'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: e.isActive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showEditDialog(context, tr, e),
                tooltip: tr('edit'),
              ),
              IconButton(
                icon: Icon(
                  e.isActive ? Icons.toggle_on : Icons.toggle_off,
                  size: 24,
                ),
                onPressed: () => controller.setActive(e.id, !e.isActive),
                tooltip: e.isActive ? tr('deactivate') : tr('activate'),
              ),
              IconButton(
                icon: const Icon(Icons.lock_reset, size: 20),
                onPressed: () => _showResetPasswordDialog(context, tr, e.id),
                tooltip: tr('reset_password'),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.error,
                ),
                onPressed: e.isActive
                    ? () => _confirmDelete(context, tr, e.id)
                    : null,
                tooltip: tr('delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddDialog(
    BuildContext context,
    String Function(String key, [String? fallback]) tr,
  ) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passwordC = TextEditingController();
    var role = EmployeeRole.cashier;
    var isActive = true;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(tr('add_employee')),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(ctx).size.width * 0.9,
                minWidth: 280,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: InputDecoration(labelText: tr('name')),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailC,
                    decoration: InputDecoration(labelText: tr('email')),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordC,
                    decoration: InputDecoration(labelText: tr('password')),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EmployeeRole>(
                    value: role,
                    decoration: InputDecoration(labelText: tr('role')),
                    items: EmployeeRole.values
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => role = v ?? role),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        onChanged: (v) => setState(() => isActive = v ?? true),
                      ),
                      Text(tr('active')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(tr('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final ok = await controller.addEmployee(
                  name: nameC.text,
                  email: emailC.text,
                  password: passwordC.text,
                  role: role,
                  isActive: isActive,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (ok)
                  Get.snackbar(tr('success'), tr('employee_added'));
                else
                  Get.snackbar(tr('error'), tr('failed_to_add_employee'));
              },
              child: Text(tr('create')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String Function(String key, [String? fallback]) tr,
    EmployeeEntity e,
  ) {
    final nameC = TextEditingController(text: e.name);
    final emailC = TextEditingController(text: e.email);
    var role = e.role;
    var isActive = e.isActive;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(tr('edit_employee')),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(ctx).size.width * 0.9,
                minWidth: 280,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: InputDecoration(labelText: tr('name')),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailC,
                    decoration: InputDecoration(labelText: tr('email')),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EmployeeRole>(
                    value: role,
                    decoration: InputDecoration(labelText: tr('role')),
                    items: EmployeeRole.values
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => role = v ?? role),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        onChanged: (v) => setState(() => isActive = v ?? true),
                      ),
                      Text(tr('active')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(tr('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final ok = await controller.updateEmployee(
                  id: e.id,
                  name: nameC.text.trim().isEmpty ? null : nameC.text.trim(),
                  email: emailC.text.trim().isEmpty ? null : emailC.text.trim(),
                  role: role,
                  isActive: isActive,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (ok)
                  Get.snackbar(tr('success'), tr('employee_updated'));
                else
                  Get.snackbar(tr('error'), tr('failed_to_update_employee'));
              },
              child: Text(tr('update')),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordDialog(
    BuildContext context,
    String Function(String key, [String? fallback]) tr,
    String employeeId,
  ) {
    final passwordC = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('reset_password')),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(ctx).size.width * 0.9,
            minWidth: 280,
          ),
          child: TextField(
            controller: passwordC,
            decoration: InputDecoration(labelText: tr('new_password')),
            obscureText: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await controller.resetPassword(
                employeeId,
                passwordC.text,
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (ok)
                Get.snackbar(tr('success'), tr('password_reset'));
              else
                Get.snackbar(tr('error'), tr('failed_to_reset_password'));
            },
            child: Text(tr('update')),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String Function(String key, [String? fallback]) tr,
    String id,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('delete')),
        content: Text(tr('delete_employee_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteEmployee(id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              Get.snackbar(tr('success'), tr('employee_deactivated'));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );
  }
}

class _FiltersRow extends GetView<EmployeesController> {
  const _FiltersRow({required this.tr, this.isMobile = false});

  final String Function(String key, [String? fallback]) tr;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: tr('search_employees'),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: (v) => controller.searchQuery.value = v,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<EmployeeRole?>(
            value: controller.roleFilter.value,
            decoration: InputDecoration(
              labelText: tr('filter_by_role'),
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: [
              DropdownMenuItem<EmployeeRole?>(
                value: null,
                child: Text(tr('all_roles')),
              ),
              ...EmployeeRole.values.map(
                (r) => DropdownMenuItem<EmployeeRole?>(
                  value: r,
                  child: Text(r.displayName),
                ),
              ),
            ],
            onChanged: (v) => controller.roleFilter.value = v,
          ),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: tr('search_employees'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<EmployeeRole?>(
              value: controller.roleFilter.value,
              decoration: InputDecoration(
                labelText: tr('filter_by_role'),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                DropdownMenuItem<EmployeeRole?>(
                  value: null,
                  child: Text(tr('all_roles')),
                ),
                ...EmployeeRole.values.map(
                  (r) => DropdownMenuItem<EmployeeRole?>(
                    value: r,
                    child: Text(r.displayName),
                  ),
                ),
              ],
              onChanged: (v) => controller.roleFilter.value = v,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile employee card ────────────────────────────────────────

class _EmployeeMobileCard extends StatelessWidget {
  const _EmployeeMobileCard({
    required this.employee,
    required this.tr,
    required this.onEdit,
    required this.onToggle,
    required this.onResetPassword,
    this.onDelete,
  });

  final EmployeeEntity employee;
  final String Function(String key, [String? fallback]) tr;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onResetPassword;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        employee.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: employee.isActive
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    employee.isActive ? tr('active') : tr('disabled'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: employee.isActive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    employee.role.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  tooltip: tr('edit'),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(
                    employee.isActive ? Icons.toggle_on : Icons.toggle_off,
                    size: 24,
                  ),
                  onPressed: onToggle,
                  tooltip: employee.isActive
                      ? tr('deactivate')
                      : tr('activate'),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.lock_reset, size: 20),
                  onPressed: onResetPassword,
                  tooltip: tr('reset_password'),
                  visualDensity: VisualDensity.compact,
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.error,
                    ),
                    onPressed: onDelete,
                    tooltip: tr('delete'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
