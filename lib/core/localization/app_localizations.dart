import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App-level translations. Loads from assets/lang/{locale}.json.
/// Use [AppLocalizations.of(context)!.tr(key)] in UI.
class AppLocalizations {
  AppLocalizations(this._strings, this.locale);

  final Map<String, String> _strings;
  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String tr(String key, [String? fallback]) {
    return _strings[key] ?? fallback ?? key;
  }

  bool get isRTL => locale.languageCode == 'ar';

  static Future<AppLocalizations> load(Locale locale) async {
    final code = locale.languageCode;
    Map<String, String> strings = {};
    try {
      final json = await rootBundle.loadString('assets/lang/$code.json');
      final map = jsonDecode(json) as Map<String, dynamic>;
      for (final e in map.entries) {
        strings[e.key] = e.value.toString();
      }
    } catch (_) {
      // Fallback to English if locale file missing
      if (code != 'en') {
        return load(const Locale('en'));
      }
    }
    return AppLocalizations(strings, locale);
  }
}
