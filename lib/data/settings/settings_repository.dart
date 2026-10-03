import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/database/repository_guard.dart';
import 'package:tenant_tracker/data/settings/app_settings.dart';
import 'package:tenant_tracker/data/settings/settings_repository_interface.dart';

class SettingsRepository implements SettingsRepositoryInterface {
  static const _languageKey = 'language';
  static const _showTipsKey = 'show_tips';
  static const _seenWelcomeKey = 'seen_welcome';
  static const _simulatedDateKey = 'dev_simulated_date';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  @override
  Future<Result<AppSettings>> load() {
    return guard(() async {
      const defaults = AppSettings();
      return AppSettings(
        languageCode: _prefs.getString(_languageKey) ?? defaults.languageCode,
        showTips: _prefs.getBool(_showTipsKey) ?? defaults.showTips,
        seenWelcome: _prefs.getBool(_seenWelcomeKey) ?? defaults.seenWelcome,
      );
    });
  }

  @override
  Future<Result<void>> setLanguage(String languageCode) =>
      guard(() => _prefs.setString(_languageKey, languageCode));

  @override
  Future<Result<void>> setShowTips(bool value) =>
      guard(() => _prefs.setBool(_showTipsKey, value));

  @override
  Future<Result<void>> setSeenWelcome(bool value) =>
      guard(() => _prefs.setBool(_seenWelcomeKey, value));

  /// The saved simulated date, read at startup to build the app's clock.
  String? get simulatedDate => _prefs.getString(_simulatedDateKey);

  @override
  Future<Result<void>> setSimulatedDate(String? date) => guard(
    () => date == null
        ? _prefs.remove(_simulatedDateKey)
        : _prefs.setString(_simulatedDateKey, date),
  );
}
