import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/settings/app_settings.dart';

abstract interface class SettingsRepositoryInterface {
  /// Missing values fall back to the defaults in `AppSettings`.
  Future<Result<AppSettings>> load();

  Future<Result<void>> setLanguage(String languageCode);
  Future<Result<void>> setShowTips(bool value);
  Future<Result<void>> setSeenWelcome(bool value);
}
