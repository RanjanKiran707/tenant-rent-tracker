class AppSettings {
  /// `en` or `kn`.
  final String languageCode;
  final bool showTips;
  final bool seenWelcome;

  const AppSettings({
    this.languageCode = 'en',
    this.showTips = true,
    this.seenWelcome = false,
  });
}
