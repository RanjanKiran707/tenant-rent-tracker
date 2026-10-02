import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/settings/app_settings.dart';
import 'package:tenant_tracker/data/settings/settings_repository_interface.dart';

/// Languages the app has translations for.
const List<String> supportedLanguageCodes = ['en', 'kn'];

class LoadSettingsUsecase {
  final SettingsRepositoryInterface _settings;

  LoadSettingsUsecase(this._settings);

  Future<Result<AppSettings>> call() => _settings.load();
}

/// Validation error: `language_unsupported`.
class SetLanguageUsecase {
  final SettingsRepositoryInterface _settings;

  SetLanguageUsecase(this._settings);

  Future<Result<void>> call(String languageCode) {
    if (!supportedLanguageCodes.contains(languageCode)) {
      return Future.value(const Err(ValidationFailure('language_unsupported')));
    }
    return _settings.setLanguage(languageCode);
  }
}

class SetShowTipsUsecase {
  final SettingsRepositoryInterface _settings;

  SetShowTipsUsecase(this._settings);

  Future<Result<void>> call(bool value) => _settings.setShowTips(value);
}

/// Marks the welcome screens as seen so they are not shown again.
class MarkWelcomeSeenUsecase {
  final SettingsRepositoryInterface _settings;

  MarkWelcomeSeenUsecase(this._settings);

  Future<Result<void>> call() => _settings.setSeenWelcome(true);
}
