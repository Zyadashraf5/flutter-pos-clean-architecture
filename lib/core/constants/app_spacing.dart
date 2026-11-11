/// Consistent spacing for responsive layout.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Mobile: sidebar hidden behind drawer
  static const double breakpointMobile = 600;

  /// Tablet: sidebar collapsed to icons-only, toggleable
  static const double breakpointTablet = 900;

  /// Breakpoint below which compact layout is used.
  static const double breakpointCompact = 1100;
}
