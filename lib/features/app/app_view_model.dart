import 'package:flutter/foundation.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/data/settings/app_settings.dart';
import 'package:tenant_tracker/domain/use_cases/business/settings/settings_usecases.dart';

/// App-wide settings: language, tips and the welcome flag. Screens read
/// [state] through `AppDependencies.instance.appViewModel` and change
/// settings through the methods here.
class AppViewModel {
  final LoadSettingsUsecase _loadSettings;
  final SetLanguageUsecase _setLanguage;
  final SetShowTipsUsecase _setShowTips;
  final MarkWelcomeSeenUsecase _markWelcomeSeen;

  final ValueNotifier<ViewState<AppSettings>> state = ValueNotifier(
    const ViewStateLoading(),
  );

  AppViewModel({
    required LoadSettingsUsecase loadSettings,
    required SetLanguageUsecase setLanguage,
    required SetShowTipsUsecase setShowTips,
    required MarkWelcomeSeenUsecase markWelcomeSeen,
  }) : _loadSettings = loadSettings,
       _setLanguage = setLanguage,
       _setShowTips = setShowTips,
       _markWelcomeSeen = markWelcomeSeen;

  /// The settings once loaded, otherwise the defaults.
  AppSettings get settings => switch (state.value) {
    ViewStateLoaded(data: final s) => s,
    _ => const AppSettings(),
  };

  Future<void> load() async {
    state.value = const ViewStateLoading();
    await _reload();
  }

  Future<void> setLanguage(String code) async {
    if (settings.languageCode == code) return;
    await _change(_setLanguage(code));
  }

  Future<void> toggleLanguage() =>
      setLanguage(settings.languageCode == 'en' ? 'kn' : 'en');

  Future<void> setShowTips(bool value) => _change(_setShowTips(value));

  Future<void> markWelcomeSeen() => _change(_markWelcomeSeen());

  /// Saves a change, then re-reads the settings so the screen shows what is
  /// really stored. A failed save keeps the old settings on screen.
  Future<void> _change(Future<Result<void>> save) async {
    final result = await save;
    if (result is Ok<void>) await _reload();
  }

  Future<void> _reload() async {
    final result = await _loadSettings();
    state.value = result.fold(
      (failure) => ViewStateError(failure),
      (settings) => ViewStateLoaded(settings),
    );
  }

  void dispose() => state.dispose();
}
