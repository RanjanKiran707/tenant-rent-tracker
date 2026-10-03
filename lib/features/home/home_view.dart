import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/core/utils/display_format.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/core/widgets/app_bar_actions.dart';
import 'package:tenant_tracker/core/widgets/big_button.dart';
import 'package:tenant_tracker/core/widgets/form_parts.dart';
import 'package:tenant_tracker/core/widgets/obx_value.dart';
import 'package:tenant_tracker/core/widgets/status_chip.dart';
import 'package:tenant_tracker/core/widgets/tip_banner.dart';
import 'package:tenant_tracker/core/widgets/total_box.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';
import 'package:tenant_tracker/features/group/group_name_dialog.dart';
import 'package:tenant_tracker/features/group/group_view.dart';
import 'package:tenant_tracker/features/group/group_view_model.dart';
import 'package:tenant_tracker/features/home/home_view_model.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  late final HomeViewModel ctrl;

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.instance;
    ctrl = HomeViewModel(
      ensureRentRecords: deps.ensureRentRecords,
      addGroup: deps.addGroup,
      watchHome: deps.watchHome,
    );
    WidgetsBinding.instance.addObserver(this);
    deps.clock.addListener(_onDateChanged);
    ctrl.refresh();
  }

  /// The simulated date changed: reload so the statuses match the new today.
  void _onDateChanged() => ctrl.refresh();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ctrl.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppDependencies.instance.clock.removeListener(_onDateChanged);
    ctrl.dispose();
    super.dispose();
  }

  Future<void> _openAddGroup() async {
    final l = AppLocalizations.of(context);
    final name = await GroupNameDialog.show(
      context,
      title: l.addGroupTitle,
      onSave: ctrl.addGroup,
    );
    if (name == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.groupAdded(name))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [AppBarActions(helpText: l.helpHome, showLegend: true)],
      ),
      body: ObxValue<ViewState<WatchHomeReturnModel>>(
        listenable: ctrl.state,
        builder: (state) => state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (failure) =>
              LoadError(failure: failure, onRetry: ctrl.refresh),
          loaded: (data) => _HomeBody(data: data, onAddGroup: _openAddGroup),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final WatchHomeReturnModel data;
  final VoidCallback onAddGroup;

  const _HomeBody({required this.data, required this.onAddGroup});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        TipBanner(text: l.helpHome),
        const SizedBox(height: 8),
        Text(
          l.thisMonth(formatMonth(l, data.currentMonth)),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TotalBox.received(
                label: l.collected,
                amount: data.received,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TotalBox.toReceive(
                label: l.toCollect,
                amount: data.toReceive,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          l.groupsCount(data.groups.length),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        Text(
          l.sortNoteGroups,
          style: const TextStyle(fontSize: 15, color: Color(0xFF5B6675)),
        ),
        if (data.groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Text(
              l.noGroups,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Color(0xFF5B6675),
              ),
            ),
          )
        else
          for (final group in data.groups) _GroupCard(group: group),
        BigButton(
          key: const Key('addGroupButton'),
          label: l.addGroupBtn,
          onPressed: onAddGroup,
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final HomeGroupRow group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final status = group.worstStatus;
    final count = switch (group.tenantCount) {
      0 => l.groupNoTenants,
      1 => l.groupOneTenant,
      final n => l.groupTenantsCount(n),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFD9DFE6)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => GroupView.open(
            context,
            GroupBundle(groupUuid: group.groupUuid),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        groupDisplayName(l, group.groupUuid, group.name),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(width: 8),
                      StatusChip(status: status),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  group.tenantCount == 0
                      ? count
                      : '$count · ${l.groupToReceive(formatMoney(group.toReceive))}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5B6675),
                  ),
                ),
                if (group.oldDues > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l.oldDues(formatMoney(group.oldDues)),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B21A8),
                      ),
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
