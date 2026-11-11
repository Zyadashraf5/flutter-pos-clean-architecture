import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../domain/entities/user_entity.dart';
import '../auth/auth_controller.dart';
import 'main_controller.dart';

import '../modules/dashboard/dashboard_view.dart';
import '../modules/categories/categories_view.dart';
import '../modules/categories/category_form_view.dart';
import '../modules/orders/orders_view.dart';
import '../modules/orders/order_create_view.dart';
import '../modules/inventory/inventory_view.dart';
import '../modules/inventory/inventory_device_form_view.dart';
import '../modules/suppliers/suppliers_view.dart';
import '../modules/suppliers/supplier_form_view.dart';
import '../modules/purchases/purchase_create_view.dart';
import '../modules/qr_scanner/qr_scanner_view.dart';
import '../modules/qr_scanner/qr_scanner_binding.dart';
import '../modules/qr_scanner/qr_scanner_controller.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/dashboard/dashboard_controller.dart';
import '../modules/categories/categories_binding.dart';
import '../modules/categories/categories_controller.dart';
import '../modules/orders/orders_binding.dart';
import '../modules/orders/orders_controller.dart';
import '../modules/inventory/inventory_binding.dart';
import '../modules/inventory/inventory_controller.dart';
import '../modules/suppliers/suppliers_binding.dart';
import '../modules/suppliers/suppliers_controller.dart';
import '../modules/purchases/purchase_create_binding.dart';
import '../modules/purchases/purchase_create_controller.dart';
import '../modules/financial/financial_binding.dart';
import '../modules/financial/financial_controller.dart';
import '../modules/financial/financial_view.dart';
import '../modules/admin/admin_binding.dart';
import '../modules/admin/admin_controller.dart';
import '../modules/admin/admin_view.dart';
import '../modules/employees/employees_binding.dart';
import '../modules/employees/employees_controller.dart';
import '../modules/employees/employees_view.dart';

// ── Responsive tier helper ──────────────────────────────────────
enum ScreenTier { mobile, tablet, desktop }

ScreenTier screenTier(double width) {
  if (width < AppSpacing.breakpointMobile) return ScreenTier.mobile;
  if (width < AppSpacing.breakpointTablet) return ScreenTier.tablet;
  return ScreenTier.desktop;
}

// ─────────────────────────────────────────────────────────────────

class MainLayout extends GetView<MainController> {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final tier = screenTier(constraints.maxWidth);
        final isMobile = tier == ScreenTier.mobile;
        final isTablet = tier == ScreenTier.tablet;

        return Scaffold(
          // Drawer for mobile only
          drawer: isMobile
              ? Drawer(
                  backgroundColor: AppColors.sidebarBg,
                  child: SafeArea(
                    child: _SidebarContent(
                      compact: false,
                      auth: auth,
                      onNavTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                )
              : null,
          body: Row(
            children: [
              // Desktop: always show full sidebar
              // Tablet: collapsible icon-only ↔ full
              if (!isMobile)
                Obx(() {
                  final sidebarOpen = controller.sidebarOpen.value;
                  final expanded = tier == ScreenTier.desktop || sidebarOpen;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: expanded ? 220.0 : 68.0,
                    child: _SidebarShell(
                      expanded: expanded,
                      auth: auth,
                      showToggle: isTablet,
                    ),
                  );
                }),
              // Main content area
              Expanded(
                child: Column(
                  children: [
                    _TopBar(auth: auth, tier: tier),
                    Expanded(
                      child: Container(
                        color: AppColors.background,
                        child: Obx(
                          () => _buildContent(controller.currentRoute.value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _ensureBinding(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        if (!Get.isRegistered<DashboardController>()) {
          DashboardBinding().dependencies();
        }
        break;
      case AppRoutes.categories:
      case AppRoutes.categoryForm:
        if (!Get.isRegistered<CategoriesController>()) {
          CategoriesBinding().dependencies();
        }
        break;
      case AppRoutes.products:
      case AppRoutes.productForm:
        if (!Get.isRegistered<InventoryController>()) {
          InventoryBinding().dependencies();
        }
        break;
      case AppRoutes.orders:
      case AppRoutes.orderCreate:
        if (!Get.isRegistered<OrdersController>()) {
          OrdersBinding().dependencies();
        }
        break;
      case AppRoutes.inventory:
      case AppRoutes.inventoryDeviceForm:
        if (!Get.isRegistered<InventoryController>()) {
          InventoryBinding().dependencies();
        }
        break;
      case AppRoutes.financial:
        if (!Get.isRegistered<FinancialController>()) {
          FinancialBinding().dependencies();
        }
        break;
      case AppRoutes.suppliers:
      case AppRoutes.supplierForm:
        if (!Get.isRegistered<SuppliersController>()) {
          SuppliersBinding().dependencies();
        }
        break;
      case AppRoutes.qrScanner:
        if (!Get.isRegistered<QrScannerController>()) {
          QrScannerBinding().dependencies();
        }
        break;
      case AppRoutes.purchaseCreate:
        if (!Get.isRegistered<PurchaseCreateController>()) {
          PurchaseCreateBinding().dependencies();
        }
        break;
      case AppRoutes.admin:
        if (!Get.isRegistered<AdminController>()) {
          AdminBinding().dependencies();
        }
        break;
      case AppRoutes.employees:
        if (!Get.isRegistered<EmployeesController>()) {
          EmployeesBinding().dependencies();
        }
        break;
    }
  }

  Widget _buildContent(String route) {
    _ensureBinding(route);
    switch (route) {
      case AppRoutes.dashboard:
        return const DashboardView();
      case AppRoutes.categories:
        return const CategoriesView();
      case AppRoutes.categoryForm:
        return const CategoryFormView();
      case AppRoutes.products:
        return const InventoryView();
      case AppRoutes.productForm:
        return const InventoryDeviceFormView();
      case AppRoutes.orders:
        return const OrdersView();
      case AppRoutes.orderCreate:
        return const OrderCreateView();
      case AppRoutes.inventory:
        return const InventoryView();
      case AppRoutes.inventoryDeviceForm:
        return const InventoryDeviceFormView();
      case AppRoutes.financial:
        return const FinancialView();
      case AppRoutes.suppliers:
        return const SuppliersView();
      case AppRoutes.supplierForm:
        return const SupplierFormView();
      case AppRoutes.qrScanner:
        return const QrScannerView();
      case AppRoutes.purchaseCreate:
        return const PurchaseCreateView();
      case AppRoutes.admin:
        return const AdminView();
      case AppRoutes.employees:
        return const EmployeesView();
      default:
        return const DashboardView();
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.auth, required this.tier});
  final AuthController auth;
  final ScreenTier tier;

  @override
  Widget build(BuildContext context) {
    final isMobile = tier == ScreenTier.mobile;
    final isTablet = tier == ScreenTier.tablet;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hamburger / toggle button
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menu',
            )
          else if (isTablet)
            IconButton(
              icon: Obx(() {
                final open = Get.find<MainController>().sidebarOpen.value;
                return Icon(open ? Icons.menu_open : Icons.menu);
              }),
              onPressed: () => Get.find<MainController>().toggleSidebar(),
              tooltip: 'Toggle sidebar',
            ),
          if (isMobile || isTablet) const SizedBox(width: 4),
          const Spacer(),
          Obx(() {
            final user = auth.currentUser.value;
            if (user == null) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMobile) ...[
                  Icon(
                    Icons.person_outline,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      'Welcome, ${user.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                isMobile
                    ? IconButton(
                        icon: const Icon(Icons.logout, size: 20),
                        onPressed: () async {
                          await auth.logout();
                          Get.offAllNamed(AppRoutes.login);
                        },
                        tooltip: 'Logout',
                      )
                    : TextButton.icon(
                        onPressed: () async {
                          await auth.logout();
                          Get.offAllNamed(AppRoutes.login);
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Logout'),
                      ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// SIDEBAR SHELL (with shadow + decoration)
// ═════════════════════════════════════════════════════════════════

class _SidebarShell extends GetView<MainController> {
  const _SidebarShell({
    required this.expanded,
    required this.auth,
    this.showToggle = false,
  });
  final bool expanded;
  final AuthController auth;
  final bool showToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(4, 0),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: _SidebarContent(
        compact: !expanded,
        iconOnly: !expanded,
        auth: auth,
        showToggle: showToggle,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// SIDEBAR CONTENT (shared between Drawer & inline panel)
// ═════════════════════════════════════════════════════════════════

class _SidebarContent extends GetView<MainController> {
  const _SidebarContent({
    this.compact = false,
    this.iconOnly = false,
    required this.auth,
    this.onNavTap,
    this.showToggle = false,
  });
  final bool compact;
  final bool iconOnly;
  final AuthController auth;
  final VoidCallback? onNavTap;
  final bool showToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tr = l10n?.tr ?? (String k, [String? f]) => f ?? k;
    return Column(
      children: [
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
        if (!iconOnly)
          Text(
            tr('app_name'),
            style: TextStyle(
              color: AppColors.onPrimary,
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          const Icon(
            Icons.storefront_rounded,
            color: AppColors.onPrimary,
            size: 28,
          ),
        SizedBox(height: iconOnly ? 12 : (compact ? 20 : 32)),

        // Nav items in scrollable area
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (auth.canAccessRoute(AppRoutes.dashboard))
                  _NavItem(
                    icon: Icons.dashboard_rounded,
                    label: tr('dashboard'),
                    route: AppRoutes.dashboard,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.categories))
                  _NavItem(
                    icon: Icons.category_rounded,
                    label: tr('categories'),
                    route: AppRoutes.categories,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.products))
                  _NavItem(
                    icon: Icons.phone_android_rounded,
                    label: tr('devices', 'Devices'),
                    route: AppRoutes.products,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.productForm))
                  _NavItem(
                    icon: Icons.add_box_rounded,
                    label: tr('add_device', 'Add Device'),
                    route: AppRoutes.productForm,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.orders))
                  _NavItem(
                    icon: Icons.shopping_cart_rounded,
                    label: tr('orders'),
                    route: AppRoutes.orders,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.orderCreate))
                  _NavItem(
                    icon: Icons.add_shopping_cart_rounded,
                    label: tr('create_order', 'Create Order'),
                    route: AppRoutes.orderCreate,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.inventory))
                  _NavItem(
                    icon: Icons.warehouse_rounded,
                    label: tr('inventory'),
                    route: AppRoutes.inventory,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.financial))
                  _NavItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: tr('financial'),
                    route: AppRoutes.financial,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.suppliers))
                  _NavItem(
                    icon: Icons.business_center_rounded,
                    label: 'Suppliers',
                    route: AppRoutes.suppliers,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.qrScanner))
                  _NavItem(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'QR Scanner',
                    route: AppRoutes.qrScanner,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.admin))
                  _NavItem(
                    icon: Icons.admin_panel_settings_rounded,
                    label: tr('admin'),
                    route: AppRoutes.admin,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
                if (auth.canAccessRoute(AppRoutes.employees))
                  _NavItem(
                    icon: Icons.people_rounded,
                    label: tr('employees'),
                    route: AppRoutes.employees,
                    compact: compact,
                    iconOnly: iconOnly,
                    onNavTap: onNavTap,
                  ),
              ],
            ),
          ),
        ),

        if (!iconOnly) _LanguageSwitcher(compact: compact),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
      ],
    );
  }
}

class _LanguageSwitcher extends GetView<MainController> {
  const _LanguageSwitcher({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final current = Get.locale?.languageCode ?? 'ar';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
      child: Row(
        children: [
          Expanded(
            child: _LangChip(
              label: 'العربية',
              isSelected: current == 'ar',
              onTap: () => controller.setLocale('ar'),
              compact: compact,
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
          Expanded(
            child: _LangChip(
              label: 'English',
              isSelected: current == 'en',
              onTap: () => controller.setLocale('en'),
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.sidebarSelected : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: compact ? 8 : 10,
            horizontal: 4,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.onPrimary,
                fontSize: compact ? 12 : 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends GetView<MainController> {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.compact = false,
    this.iconOnly = false,
    this.onNavTap,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool compact;
  final bool iconOnly;
  final VoidCallback? onNavTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.currentRoute.value == route;
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: iconOnly ? 8 : (compact ? 8 : 12),
          vertical: 3,
        ),
        child: Tooltip(
          message: iconOnly ? label : '',
          preferBelow: false,
          child: Material(
            color: selected ? AppColors.sidebarSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                controller.goTo(route);
                onNavTap?.call();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: iconOnly ? 0 : (compact ? 12 : 16),
                  vertical: compact ? 10 : 12,
                ),
                child: iconOnly
                    ? Center(
                        child: Icon(icon, color: AppColors.onPrimary, size: 22),
                      )
                    : Row(
                        children: [
                          Icon(
                            icon,
                            color: AppColors.onPrimary,
                            size: compact ? 20 : 22,
                          ),
                          SizedBox(width: compact ? 8 : 12),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: AppColors.onPrimary,
                                fontSize: compact ? 13 : 15,
                                fontWeight: FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
