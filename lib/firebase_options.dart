import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Pas de configuration Web disponible.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Pas de configuration iOS disponible.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Pas de configuration macOS disponible.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Pas de configuration Windows disponible.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Pas de configuration Linux disponible.',
        );
      default:
        throw UnsupportedError(
          'Plateforme non supportée.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'VOTRE_API_KEY',
    appId: 'VOTRE_APP_ID',
    messagingSenderId: 'VOTRE_MESSAGING_SENDER_ID',
    projectId: 'VOTRE_PROJECT_ID',
    storageBucket: 'VOTRE_STORAGE_BUCKET',
  );
} 