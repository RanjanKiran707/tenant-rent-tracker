import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/widgets/obx_value.dart';
import 'package:tenant_tracker/features/home/home_view.dart';
import 'package:tenant_tracker/features/settings/settings_view.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

/// The two tabs: Home and Settings. Both stay alive while you switch.
class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  final ValueNotifier<int> tab = ValueNotifier(0);

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ObxValue<int>(
      listenable: tab,
      builder: (index) => Scaffold(
        body: IndexedStack(
          index: index,
          children: const [HomeView(), SettingsView()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => tab.value = i,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
