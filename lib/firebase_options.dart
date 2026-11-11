// Firebase configuration is supplied at build time with --dart-define (or
// --dart-define-from-file), so no project identifiers are kept in source
// control. See README.md -> "Firebase setup".
//
// Alternatively run `flutterfire configure` locally to regenerate this file
// for your own Firebase project (do not commit the generated values).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static const _webApiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const _androidApiKey = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const _androidAppId = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
  static const _iosApiKey = String.fromEnvironment('FIREBASE_IOS_API_KEY');
  static const _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');

  /// Options for the current platform. Windows uses the web app registration,
  /// which is what the FlutterFire CLI generates for desktop.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return _web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _build(_androidApiKey, _androidAppId);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _build(_iosApiKey, _iosAppId, iosBundleId: _iosBundleId);
      case TargetPlatform.windows:
        return _web;
      default:
        throw UnsupportedError(
          'Firebase is not configured for $defaultTargetPlatform.',
        );
    }
  }

  static FirebaseOptions get _web =>
      _build(_webApiKey, _webAppId, authDomain: _authDomain);

  static FirebaseOptions _build(
    String apiKey,
    String appId, {
    String? authDomain,
    String? iosBundleId,
  }) {
    if (apiKey.isEmpty || appId.isEmpty || _projectId.isEmpty) {
      throw StateError(
        'Firebase is not configured. Copy firebase.env.example.json to '
        'firebase.env.json, fill in your project values and run '
        '`flutter run --dart-define-from-file=firebase.env.json`.',
      );
    }
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: _senderId,
      projectId: _projectId,
      storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
      authDomain: (authDomain == null || authDomain.isEmpty) ? null : authDomain,
      iosBundleId: (iosBundleId == null || iosBundleId.isEmpty) ? null : iosBundleId,
    );
  }
}
