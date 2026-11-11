import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'core/di/injection.dart';
import 'core/firebase/firebase_initializer.dart';
import 'presentation/auth/auth_controller.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/local_storage.dart';
import 'domain/usecases/firebase/test_firebase_connection_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseInitializer.initialize();
  await LocalStorage.init();
  await initDependencies();

  await Get.find<AuthController>().loadCurrentUser();

  await _testFirebaseConnection();

  // Restore saved language (ar/en)
  final savedLocale =
      LocalStorage.settingsBox.get('locale')?.toString() ?? 'ar';
  Get.locale = Locale(savedLocale);

  runApp(const CashiereApp());
}

Future<void> _testFirebaseConnection() async {
  try {
    await Get.find<TestFirebaseConnectionUseCase>().call();
    debugPrint(
      'Firebase connection test: document written to Firestore (test/connection).',
    );
  } catch (e, st) {
    debugPrint('Firebase connection test failed: $e');
    debugPrint(st.toString());
  }
}

class CashiereApp extends StatelessWidget {
  const CashiereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cashiere Systems new',
      debugShowCheckedModeBanner: false,
      locale: Get.locale ?? const Locale('ar'),
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      builder: (context, child) {
        final loc = AppLocalizations.of(context);
        final isRTL = loc?.isRTL ?? true;
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
