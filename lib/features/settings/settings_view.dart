import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/core/widgets/app_bar_actions.dart';
import 'package:tenant_tracker/core/widgets/big_button.dart';
import 'package:tenant_tracker/core/widgets/form_parts.dart';
import 'package:tenant_tracker/core/widgets/obx_value.dart';
import 'package:tenant_tracker/core/widgets/tip_banner.dart';
import 'package:tenant_tracker/data/settings/app_settings.dart';
import 'package:tenant_tracker/features/app/app_scope.dart';
import 'package:tenant_tracker/features/archived/archived_view.dart';
import 'package:tenant_tracker/features/welcome/welcome_view.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

/// Settings only reads and changes the app-wide settings, so it uses the
/// `AppViewModel` directly and has no view model of its own.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.setTitle),
        actions: [AppBarActions(helpText: l.helpSettings)],
      ),
      body: ObxValue<ViewState<AppSettings>>(
        listenable: app.state,
        builder: (state) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            TipBanner(text: l.helpSettings),
            const SizedBox(height: 8),
            Text(
              l.setLang,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            _LanguageChoice(
              label: 'English',
              selected: app.settings.languageCode == 'en',
              onTap: () => app.setLanguage('en'),
            ),
            _LanguageChoice(
              label: 'ಕನ್ನಡ',
              selected: app.settings.languageCode == 'kn',
              onTap: () => app.setLanguage('kn'),
            ),
            SectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.setTips,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Switch(
                    key: const Key('tipsSwitch'),
                    value: app.settings.showTips,
                    onChanged: app.setShowTips,
                  ),
                ],
              ),
            ),
            BigButton(
              label: l.archTitle,
              kind: BigButtonKind.secondary,
              onPressed: () => ArchivedView.open(context),
            ),
            BigButton(
              label: l.setWelcome,
              kind: BigButtonKind.secondary,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (routeContext) => WelcomeView(
                    onFinish: () async => Navigator.pop(routeContext),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l.setAbout,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.appTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.version,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5B6675),
                    ),
                  ),
                ],
              ),
            ),
            ErrorLine(state: state),
          ],
        ),
      ),
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1D4ED8);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: selected ? const Color(0xFFEEF3FF) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? blue : const Color(0xFFD9DFE6),
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? blue : const Color(0xFFAAB4C0),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: selected ? blue : const Color(0xFF1B2430),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
