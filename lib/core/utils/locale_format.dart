import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../localization/app_localizations.dart';

/// Locale-aware number and currency formatting. Safe against NaN/Infinity and locale errors.
class LocaleFormat {
  LocaleFormat._();

  static String _safeLocale(String code) => code == 'ar' ? 'ar_EG' : 'en_US';

  static String currency(double value, BuildContext? context) {
    if (!value.isFinite) return value.isNaN ? '0.00' : '0.00';
    try {
      final code = context != null ? (AppLocalizations.of(context)?.locale.languageCode ?? 'ar') : 'ar';
      final formatter = NumberFormat.currency(
        locale: _safeLocale(code),
        symbol: code == 'ar' ? 'ج.م' : '\$',
        decimalDigits: 2,
      );
      return formatter.format(value);
    } catch (_) {
      return NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(value);
    }
  }

  static String number(int value, BuildContext? context) {
    try {
      final code = context != null ? (AppLocalizations.of(context)?.locale.languageCode ?? 'ar') : 'ar';
      return NumberFormat('#,###', _safeLocale(code)).format(value);
    } catch (_) {
      return NumberFormat('#,###', 'en_US').format(value);
    }
  }

  static String decimal(double value, {int decimals = 2, BuildContext? context}) {
    if (!value.isFinite) return value.isNaN ? '0' : '0';
    try {
      final code = context != null ? (AppLocalizations.of(context)?.locale.languageCode ?? 'ar') : 'ar';
      return NumberFormat('#,##0.${'0' * decimals}', _safeLocale(code)).format(value);
    } catch (_) {
      return NumberFormat('#,##0.${'0' * decimals}', 'en_US').format(value);
    }
  }
}
