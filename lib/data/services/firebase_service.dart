import 'dart:io' show Platform;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../../firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _activateAppCheck();
    _initialized = true;
  }

  // Keşfet ekranındaki Firestore/Storage çağrılarını bot ve otomasyon
  // trafiğine karşı korumak için App Check aktive edilir. Debug build'lerde
  // gerçek attestation sağlayıcıları (Play Integrity/DeviceCheck) çalışmaz,
  // bu yüzden debug provider kullanılır — cihazın debug token'ı Firebase
  // Console > App Check > Apps > Manage debug tokens altına eklenmelidir.
  static Future<void> _activateAppCheck() async {
    if (kIsWeb) return; // Web reCAPTCHA site key gerektirir, Faz 1 kapsamı dışında.
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return; // Windows/Linux masaüstü App Check tarafından desteklenmiyor.
    }

    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );
  }
}
