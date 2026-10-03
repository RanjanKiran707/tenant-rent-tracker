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
import 'package:tenant_tracker/domain/use_cases/ui/watch_group/watch_group_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';
import 'package:tenant_tracker/features/add_tenant/add_tenant_view.dart';
import 'package:tenant_tracker/features/group/group_name_dialog.dart';
import 'package:tenant_tracker/features/group/group_view_model.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view_model.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

/// One group: its tenants, most urgent first. This is the list Home showed
/// before groups existed.
class GroupView extends StatefulWidget {
  final GroupBundle bundle;

  const GroupView({super.key, required this.bundle});

  static Future<void> open(BuildContext context, GroupBundle bundle) =>
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GroupView(bundle: bundle)),
      );

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> with WidgetsBindingObserver {
  late final GroupViewModel ctrl;

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.instance;
    ctrl = GroupViewModel(
      bundle: widget.bundle,
      ensureRentRecords: deps.ensureRentRecords,
      watchGroup: deps.watchGroup,
      renameGroup: deps.renameGroup,
      deleteGroup: deps.deleteGroup,
    );
    ctrl.deleteState.addListener(_onDeleteStateChanged);
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

  /// After "Yes, delete": back to Home, with a note.
  void _onDeleteStateChanged() {
    if (ctrl.deleteState.value is! ViewStateLoaded<void> || !mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = _loadedName(l) ?? '';
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.groupDeleted(name))));
  }

  String? _loadedName(AppLocalizations l) => switch (ctrl.state.value) {
    ViewStateLoaded(data: final d) => groupDisplayName(l, d.groupUuid, d.name),
    _ => null,
  };

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppDependencies.instance.clock.removeListener(_onDateChanged);
    ctrl.deleteState.removeListener(_onDeleteStateChanged);
    ctrl.dispose();
    super.dispose();
  }

  Future<void> _openRename(WatchGroupReturnModel data) async {
    final newName = await GroupNameDialog.show(
      context,
      title: AppLocalizations.of(context).renameGroupTitle,
      initialName: data.name,
      onSave: ctrl.rename,
    );
    if (newName == null || !mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.groupRenamed(newName))));
  }

  /// A group with tenants cannot be deleted: say so instead of asking.
  Future<void> _askDelete(WatchGroupReturnModel data) async {
    final l = AppLocalizations.of(context);
    final name = groupDisplayName(l, data.groupUuid, data.name);
    if (data.rows.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.delGroupTitle(name)),
          content: InfoBox(
            background: const Color(0xFFFDEEC2),
            border: const Color(0xFFF0D27A),
            child: Text(l.delGroupNotEmpty),
          ),
          actions: [
            BigButton(
              label: l.ok,
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
      );
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.delGroupTitle(name)),
        content: Text(l.delGroupBody, style: const TextStyle(fontSize: 18)),
        actions: [
          BigButton(
            label: l.delGroupNo,
            kind: BigButtonKind.secondary,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          BigButton(
            label: l.delGroupYes,
            kind: BigButtonKind.danger,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );
    if (yes == true) ctrl.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ObxMulti(
      listenables: [ctrl.state, ctrl.deleteState],
      builder: () {
        final busy = ctrl.deleteState.value.isLoading;
        return PopScope(
          canPop: !busy,
          child: Scaffold(
            appBar: AppBar(
              title: Text(_loadedName(l) ?? ''),
              actions: [
                AppBarActions(helpText: l.helpGroup, showLegend: true),
              ],
            ),
            body: ctrl.state.value.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (failure) =>
                  LoadError(failure: failure, onRetry: ctrl.refresh),
              loaded: (data) => _GroupBody(
                data: data,
                busy: busy,
                deleteState: ctrl.deleteState.value,
                onRename: () => _openRename(data),
                onDelete: () => _askDelete(data),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GroupBody extends StatelessWidget {
  final WatchGroupReturnModel data;
  final bool busy;
  final ViewState<void> deleteState;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _GroupBody({
    required this.data,
    required this.busy,
    required this.deleteState,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        TipBanner(text: l.helpGroup),
        if (data.isUncategorized) InfoBox(child: Text(l.defaultGroupNote)),
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
          l.tenantsCount(data.rows.length),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        if (data.rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Text(
              l.noTenantsInGroup,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Color(0xFF5B6675),
              ),
            ),
          )
        else ...[
          Text(
            l.sortNote,
            style: const TextStyle(fontSize: 15, color: Color(0xFF5B6675)),
          ),
          for (final row in data.rows) _TenantCard(row: row),
        ],
        BigButton(
          label: l.addTenantBtn,
          onPressed: () =>
              AddTenantView.open(context, groupUuid: data.groupUuid),
        ),
        if (!data.isUncategorized) ...[
          BigButton(
            key: const Key('renameGroupButton'),
            label: l.btnRenameGroup,
            kind: BigButtonKind.secondary,
            onPressed: busy ? null : onRename,
          ),
          const SizedBox(height: 16),
          BigButton(
            key: const Key('deleteGroupButton'),
            label: l.btnDeleteGroup,
            kind: BigButtonKind.danger,
            small: true,
            busy: busy,
            onPressed: onDelete,
          ),
          ErrorLine(state: deleteState),
        ],
      ],
    );
  }
}

class _TenantCard extends StatelessWidget {
  final HomeTenantRow row;

  const _TenantCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
          onTap: () => TenantDetailView.open(
            context,
            TenantDetailBundle(tenantUuid: row.tenantUuid),
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
                        row.name,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: row.status),
                  ],
                ),
                if (row.oldDues > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l.oldDues(formatMoney(row.oldDues)),
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
