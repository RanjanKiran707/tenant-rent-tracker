import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/core/widgets/form_parts.dart';
import 'package:tenant_tracker/core/widgets/obx_value.dart';
import 'package:tenant_tracker/data/settings/app_settings.dart';
import 'package:tenant_tracker/features/app/app_scope.dart';
import 'package:tenant_tracker/features/app/app_view_model.dart';
import 'package:tenant_tracker/features/main_shell/main_shell_view.dart';
import 'package:tenant_tracker/features/welcome/welcome_view.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AppDependencies.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppViewModel app;

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.instance;
    app = AppViewModel(
      loadSettings: deps.loadSettings,
      setLanguage: deps.setLanguage,
      setShowTips: deps.setShowTips,
      markWelcomeSeen: deps.markWelcomeSeen,
    );
    app.load();
  }

  @override
  void dispose() {
    app.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObxValue<ViewState<AppSettings>>(
      listenable: app.state,
      builder: (_) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: _theme,
        locale: Locale(app.settings.languageCode),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // Above the Navigator, so every pushed screen can reach the settings.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_textScale)),
          child: AppScope(app: app, child: child!),
        ),
        home: _Root(app: app),
      ),
    );
  }
}

/// First screen: a spinner while settings load, then the welcome guide on the
/// first run, otherwise the tabs.
class _Root extends StatelessWidget {
  final AppViewModel app;

  const _Root({required this.app});

  @override
  Widget build(BuildContext context) {
    return ObxValue<ViewState<AppSettings>>(
      listenable: app.state,
      builder: (state) => state.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (failure) => Scaffold(
          body: LoadError(failure: failure, onRetry: app.load),
        ),
        loaded: (settings) => settings.seenWelcome
            ? const MainShellView()
            : WelcomeView(onFinish: app.markWelcomeSeen),
      ),
    );
  }
}

const _blue = Color(0xFF1D4ED8);

final ThemeData _baseTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _blue),
);

/// Larger text than the default: the app is read by people who may not see
/// small print well. Applied via MediaQuery because the unlocalized base
/// textTheme has no font sizes, so TextTheme.apply(fontSizeFactor:) asserts.
const _textScale = 1.15;

final ThemeData _theme = _baseTheme.copyWith(
  scaffoldBackgroundColor: const Color(0xFFF4F6F8),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Color(0xFF1B2430),
      fontSize: 21,
      fontWeight: FontWeight.w700,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFAAB4C0), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFAAB4C0), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _blue, width: 2),
    ),
  ),
);
