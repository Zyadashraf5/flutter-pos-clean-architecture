import 'package:flutter/foundation.dart';

/// Centralized logging for data flow debugging. No UI or business logic.
class AppLogger {
  AppLogger._();

  static void dataSource(String layer, String message, [Object? detail]) {
    if (kDebugMode) {
      debugPrint('[DS:$layer] $message${detail != null ? ' $detail' : ''}');
    }
  }

  static void repository(String layer, String message, [Object? detail]) {
    if (kDebugMode) {
      debugPrint('[REPO:$layer] $message${detail != null ? ' $detail' : ''}');
    }
  }

  static void useCase(String layer, String message, [Object? detail]) {
    if (kDebugMode) {
      debugPrint('[UC:$layer] $message${detail != null ? ' $detail' : ''}');
    }
  }

  static void controller(String layer, String message, [Object? detail]) {
    if (kDebugMode) {
      debugPrint('[CTRL:$layer] $message${detail != null ? ' $detail' : ''}');
    }
  }
}
