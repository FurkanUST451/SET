import 'package:get_storage/get_storage.dart';

/// Lokal anahtar/değer storage. Tema, oturum, onboarding flag gibi
/// hafif ayarlar için kullanılır.
class StorageService {
  StorageService._();

  static final GetStorage _box = GetStorage();

  // Keys
  static const String themeMode = 'theme_mode';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';

  static T? read<T>(String key) => _box.read<T>(key);

  static Future<void> write(String key, dynamic value) =>
      _box.write(key, value);

  static Future<void> remove(String key) => _box.remove(key);

  static Future<void> erase() => _box.erase();

  static bool has(String key) => _box.hasData(key);
}
