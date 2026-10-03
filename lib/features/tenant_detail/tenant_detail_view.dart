import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/utils/display_format.dart';
import 'package:tenant_tracker/core/utils/failure_message.dart';
import 'package:tenant_tracker/core/utils/status_text.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/core/widgets/app_bar_actions.dart';
import 'package:tenant_tracker/core/widgets/big_button.dart';
import 'package:tenant_tracker/core/widgets/form_parts.dart';
import 'package:tenant_tracker/core/widgets/obx_value.dart';
import 'package:tenant_tracker/core/widgets/status_chip.dart';
import 'package:tenant_tracker/core/widgets/tip_banner.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_groups/watch_groups_return_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_tenant_detail/watch_tenant_detail_return_model.dart';
import 'package:tenant_tracker/features/change_rent/change_rent_view.dart';
import 'package:tenant_tracker/features/change_rent/change_rent_view_model.dart';
import 'package:tenant_tracker/features/record_payment/record_payment_view.dart';
import 'package:tenant_tracker/features/record_payment/record_payment_view_model.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view_model.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

class TenantDetailView extends StatefulWidget {
  final TenantDetailBundle bundle;

  const TenantDetailView({super.key, required this.bundle});

  static Route<void> route(TenantDetailBundle bundle) =>
      MaterialPageRoute(builder: (_) => TenantDetailView(bundle: bundle));

  static Future<void> open(BuildContext context, TenantDetailBundle bundle) =>
      Navigator.push(context, route(bundle));

  @override
  State<TenantDetailView> createState() => _TenantDetailViewState();
}

class _TenantDetailViewState extends State<TenantDetailView>
    with WidgetsBindingObserver {
  late final TenantDetailViewModel ctrl;

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.instance;
    ctrl = TenantDetailViewModel(
      bundle: widget.bundle,
      ensureRentRecords: deps.ensureRentRecords,
      watchTenantDetail: deps.watchTenantDetail,
      deleteTenant: deps.deleteTenant,
      renameTenant: deps.renameTenant,
      moveTenantToGroup: deps.moveTenantToGroup,
      watchGroups: deps.watchGroups,
      editPayment: deps.editPayment,
      undoPayment: deps.undoPayment,
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

  /// After "Yes, remove": back to the list, with a note.
  void _onDeleteStateChanged() {
    if (ctrl.deleteState.value is! ViewStateLoaded<void> || !mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = _loadedName ?? '';
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.removed(name))));
  }

  String? get _loadedName => switch (ctrl.state.value) {
    ViewStateLoaded(data: final d) => d.name,
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

  Future<void> _openPay(String? rentRecordUuid) async {
    final recorded = await RecordPaymentView.open(
      context,
      RecordPaymentBundle(
        tenantUuid: widget.bundle.tenantUuid,
        initialRentRecordUuid: rentRecordUuid,
      ),
    );
    if (recorded == null || !mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 7),
          content: Text(l.paymentSaved(formatMoney(recorded.amount))),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () async {
              final failure = await ctrl.undoPayment(recorded.paymentUuid);
              if (failure != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(failureMessage(l, failure))),
                );
              }
            },
          ),
        ),
      );
  }

  Future<void> _openRent() async {
    final from = await ChangeRentView.open(
      context,
      ChangeRentBundle(tenantUuid: widget.bundle.tenantUuid),
    );
    if (from == null || !mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l.rentSaved(formatMonth(l, from)))),
      );
  }

  Future<void> _openEditPayment(PaymentItem payment) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditPaymentDialog(
        payment: payment,
        today: AppDependencies.instance.clock.today(),
        onSave: (amount, paidOn) =>
            ctrl.editPayment(payment.uuid, amount: amount, paidOn: paidOn),
      ),
    );
    if (saved != true || !mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.paymentUpdated)));
  }

  Future<void> _openMove(WatchTenantDetailReturnModel data) async {
    final moved = await showDialog<GroupOption>(
      context: context,
      builder: (_) => _MoveGroupDialog(
        tenantName: data.name,
        currentGroupUuid: data.groupUuid,
        loadGroups: ctrl.loadGroups,
        onMove: ctrl.moveToGroup,
      ),
    );
    if (moved == null || !mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l.movedTo(
              data.name,
              groupDisplayName(l, moved.groupUuid, moved.name),
            ),
          ),
        ),
      );
  }

  Future<void> _openEditName(String currentName) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) =>
          _EditNameDialog(initialName: currentName, onSave: ctrl.rename),
    );
    if (newName == null || !mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.nameSaved(newName))));
  }

  Future<void> _askDelete(WatchTenantDetailReturnModel data) async {
    final l = AppLocalizations.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.delTitle(data.name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.delBody(data.name), style: const TextStyle(fontSize: 18)),
            if (data.totalOwed > 0)
              InfoBox(
                background: const Color(0xFFFDEEC2),
                border: const Color(0xFFF0D27A),
                child: Text(l.delOwed(formatMoney(data.totalOwed))),
              ),
          ],
        ),
        actions: [
          BigButton(
            label: l.delNo,
            kind: BigButtonKind.secondary,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          BigButton(
            label: l.delYes,
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
        final title = _loadedName ?? '';
        return PopScope(
          canPop: !busy,
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: [
                AppBarActions(helpText: l.helpDetail, showLegend: true),
              ],
            ),
            body: ctrl.state.value.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (failure) =>
                  LoadError(failure: failure, onRetry: ctrl.refresh),
              loaded: (data) => _DetailBody(
                data: data,
                busy: busy,
                deleteState: ctrl.deleteState.value,
                onPay: _openPay,
                onRent: _openRent,
                onEditName: () => _openEditName(data.name),
                onMove: () => _openMove(data),
                onEditPayment: _openEditPayment,
                onDelete: () => _askDelete(data),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  final WatchTenantDetailReturnModel data;
  final bool busy;
  final ViewState<void> deleteState;
  final Future<void> Function(String? rentRecordUuid) onPay;
  final VoidCallback onRent;
  final VoidCallback onEditName;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  /// Opens the edit dialog for a payment.
  final void Function(PaymentItem payment) onEditPayment;

  const _DetailBody({
    required this.data,
    required this.busy,
    required this.deleteState,
    required this.onPay,
    required this.onRent,
    required this.onEditName,
    required this.onMove,
    required this.onDelete,
    required this.onEditPayment,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final top = data.topMonth;
    final noPendingDue = top == null && !data.readOnly && data.oldDues == 0;
    // An archived tenant is read-only: its payments cannot be edited.
    final editPayment = data.readOnly ? null : onEditPayment;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        if (data.readOnly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFECDCFA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              l.archRemovedOn(formatMonth(l, data.deletedMonth ?? '')),
              style: const TextStyle(
                color: Color(0xFF4B1478),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          TipBanner(text: l.helpDetail),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                data.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (!data.readOnly)
              IconButton(
                key: const Key('editNameButton'),
                tooltip: l.btnEditName,
                icon: const Icon(Icons.edit),
                onPressed: busy ? null : onEditName,
              ),
          ],
        ),
        Text(
          l.rentPerMonth(formatMoney(data.currentRent)),
          style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675)),
        ),
        Text(
          l.inGroup(groupDisplayName(l, data.groupUuid, data.groupName)),
          key: const Key('tenantGroupLine'),
          style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675)),
        ),
        if (top != null)
          _TopMonthCard(month: top, onEditPayment: editPayment),
        if (noPendingDue)
          SectionCard(
            child: Text(
              l.noPendingDue,
              key: const Key('noPendingDue'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        if (!data.readOnly && data.oldDues > 0)
          InfoBox(
            background: const Color(0xFFF6ECFD),
            border: const Color(0xFFDBBDF2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.oldDues(formatMoney(data.oldDues)),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                BigButton(
                  label: l.btnPayOld,
                  small: true,
                  onPressed: () => onPay(data.oldestOwingRentRecordUuid),
                ),
              ],
            ),
          ),
        if (!data.readOnly && data.pendingRentMonth != null)
          InfoBox(
            child: Text(
              l.pendingRentNote(
                formatMonth(l, data.pendingRentMonth!),
                formatMoney(data.pendingRentAmount ?? 0),
              ),
            ),
          ),
        if (!data.readOnly) ...[
          if (!noPendingDue)
            BigButton(label: l.btnPay, onPressed: () => onPay(null)),
          BigButton(
            label: l.btnRent,
            kind: BigButtonKind.secondary,
            onPressed: onRent,
          ),
          BigButton(
            key: const Key('moveGroupButton'),
            label: l.btnMoveGroup,
            kind: BigButtonKind.secondary,
            onPressed: busy ? null : onMove,
          ),
        ],
        const SizedBox(height: 22),
        Text(
          l.history,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: data.months.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    l.noHistory,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5B6675),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final month in data.months)
                      _HistoryMonth(
                        month: month,
                        canPay: !data.readOnly,
                        onPay: () => onPay(month.rentRecordUuid),
                        onEditPayment: editPayment,
                      ),
                  ],
                ),
        ),
        if (!data.readOnly) ...[
          const SizedBox(height: 16),
          BigButton(
            label: l.btnDelete,
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

/// Lists the groups; tapping one moves the tenant there. Pops with the chosen
/// group, or null when cancelled. A failed move is shown inside the dialog.
class _MoveGroupDialog extends StatefulWidget {
  final String tenantName;
  final String currentGroupUuid;
  final Future<List<GroupOption>?> Function() loadGroups;
  final Future<Failure?> Function(String groupUuid) onMove;

  const _MoveGroupDialog({
    required this.tenantName,
    required this.currentGroupUuid,
    required this.loadGroups,
    required this.onMove,
  });

  @override
  State<_MoveGroupDialog> createState() => _MoveGroupDialogState();
}

class _MoveGroupDialogState extends State<_MoveGroupDialog> {
  List<GroupOption>? _groups;
  bool _loaded = false;
  Failure? _failure;
  bool _moving = false;

  @override
  void initState() {
    super.initState();
    widget.loadGroups().then((groups) {
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loaded = true;
      });
    });
  }

  Future<void> _move(GroupOption group) async {
    if (_moving) return; // blocking rule: ignore re-entry
    if (group.groupUuid == widget.currentGroupUuid) {
      Navigator.pop(context);
      return;
    }
    setState(() => _moving = true);
    final failure = await widget.onMove(group.groupUuid);
    if (!mounted) return;
    if (failure == null) {
      Navigator.pop(context, group);
    } else {
      setState(() {
        _moving = false;
        _failure = failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final groups = _groups;
    return AlertDialog(
      title: Text(l.moveTitle(widget.tenantName)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.moveBody, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            if (!_loaded)
              const Center(child: CircularProgressIndicator())
            else if (groups == null)
              Text(l.errGeneric)
            else
              RadioGroup<String>(
                groupValue: widget.currentGroupUuid,
                onChanged: (uuid) {
                  if (_moving || uuid == null) return;
                  _move(groups.firstWhere((g) => g.groupUuid == uuid));
                },
                child: Column(
                  children: [
                    for (final g in groups)
                      RadioListTile<String>(
                        key: Key('moveGroup-${g.groupUuid}'),
                        value: g.groupUuid,
                        enabled: !_moving,
                        title: Text(
                          groupDisplayName(l, g.groupUuid, g.name),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (_failure != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  failureMessage(l, _failure!),
                  style: const TextStyle(color: Color(0xFFB3261E)),
                ),
              ),
          ],
        ),
      ),
      actions: [
        BigButton(
          label: l.cancel,
          kind: BigButtonKind.secondary,
          onPressed: _moving ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }
}

/// Asks for the new name. Pops with the saved name, or null when cancelled.
/// A failed save (for example an empty name) is shown inside the dialog.
class _EditNameDialog extends StatefulWidget {
  final String initialName;
  final Future<Failure?> Function(String name) onSave;

  const _EditNameDialog({required this.initialName, required this.onSave});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );
  Failure? _failure;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return; // blocking rule: ignore re-entry
    final name = _controller.text.trim();
    setState(() => _saving = true);
    final failure = await widget.onSave(name);
    if (!mounted) return;
    if (failure == null) {
      Navigator.pop(context, name);
    } else {
      setState(() {
        _saving = false;
        _failure = failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.editNameTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('editNameField'),
            controller: _controller,
            enabled: !_saving,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          if (_failure != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                failureMessage(l, _failure!),
                style: const TextStyle(color: Color(0xFFB3261E)),
              ),
            ),
        ],
      ),
      actions: [
        BigButton(
          label: l.cancel,
          kind: BigButtonKind.secondary,
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        BigButton(label: l.save, busy: _saving, onPressed: _save),
      ],
    );
  }
}

/// One received payment, "₹3,000 · 4 Jan". Tapping it (and the pencil) opens
/// the edit dialog; when [onEdit] is null the line is plain text.
class _PaymentLine extends StatelessWidget {
  final PaymentItem payment;
  final void Function(PaymentItem payment)? onEdit;

  const _PaymentLine({required this.payment, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const style = TextStyle(fontSize: 16, color: Color(0xFF5B6675));
    final text = Text(
      '₹${formatMoney(payment.amount)} · ${formatDayMonth(l, payment.paidOn)}',
      style: style,
    );
    final edit = onEdit;
    if (edit == null) return text;
    return InkWell(
      key: Key('payment-${payment.uuid}'),
      borderRadius: BorderRadius.circular(8),
      onTap: () => edit(payment),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: text),
            Tooltip(
              message: l.editPaymentTooltip,
              child: const Icon(Icons.edit, size: 18, color: Color(0xFF5B6675)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Edits the amount and the date received of one payment, full screen. Pops
/// with true once saved, or null when cancelled. A failed save is shown on the
/// screen.
class _EditPaymentDialog extends StatefulWidget {
  final PaymentItem payment;

  /// `YYYY-MM-DD`; a payment cannot be dated after today.
  final String today;
  final Future<Failure?> Function(int amount, String paidOn) onSave;

  const _EditPaymentDialog({
    required this.payment,
    required this.today,
    required this.onSave,
  });

  @override
  State<_EditPaymentDialog> createState() => _EditPaymentDialogState();
}

class _EditPaymentDialogState extends State<_EditPaymentDialog> {
  late final TextEditingController _amount = TextEditingController(
    text: '${widget.payment.amount}',
  );
  late String _date = widget.payment.paidOn;
  Failure? _failure;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_date),
      firstDate: DateTime(2000),
      lastDate: DateTime.parse(widget.today),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    if (_saving) return; // blocking rule: ignore re-entry
    // An empty or non-numeric amount becomes 0, which the use case rejects.
    final amount = int.tryParse(_amount.text.trim()) ?? 0;
    setState(() => _saving = true);
    final failure = await widget.onSave(amount, _date);
    if (!mounted) return;
    if (failure == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _saving = false;
        _failure = failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.editPaymentTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _saving ? null : () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel(label: l.payAmount),
                        TextField(
                          key: const Key('editPaymentAmount'),
                          controller: _amount,
                          enabled: !_saving,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        FormLabel(label: l.payDate),
                        InkWell(
                          key: const Key('editPaymentDate'),
                          onTap: _saving ? null : _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(),
                            child: Text(
                              formatDate(l, _date),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        if (_failure != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              failureMessage(l, _failure!),
                              style: const TextStyle(color: Color(0xFFB3261E)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                BigButton(label: l.save, busy: _saving, onPressed: _save),
                const SizedBox(height: 8),
                BigButton(
                  label: l.cancel,
                  kind: BigButtonKind.secondary,
                  onPressed: _saving ? null : () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopMonthCard extends StatelessWidget {
  final MonthDetail month;

  /// Opens the edit dialog for a payment; null when payments cannot be edited
  /// (an archived tenant).
  final void Function(PaymentItem payment)? onEditPayment;

  const _TopMonthCard({required this.month, required this.onEditPayment});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ratio = month.requiredAmount == 0
        ? 0.0
        : (month.paid / month.requiredAmount).clamp(0.0, 1.0);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatMonth(l, month.month),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(status: month.status),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            statusDescription(l, month.status),
            style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 12,
                backgroundColor: const Color(0xFFE5E9EF),
                color: statusColors(month.status).ink,
              ),
            ),
          ),
          Text(
            l.received(
              formatMoney(month.paid),
              formatMoney(month.requiredAmount),
            ),
          ),
          for (final p in month.payments)
            _PaymentLine(payment: p, onEdit: onEditPayment),
          if (month.balance > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l.balance(formatMoney(month.balance)),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (month.extra > 0)
            Text(
              l.extraNote(formatMoney(month.extra)),
              style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675)),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l.dueDate(formatDayMonth(l, month.dueDate)),
              style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryMonth extends StatelessWidget {
  final MonthDetail month;
  final bool canPay;
  final VoidCallback onPay;

  /// Opens the edit dialog for a payment; null when payments cannot be edited
  /// (an archived tenant).
  final void Function(PaymentItem payment)? onEditPayment;

  const _HistoryMonth({
    required this.month,
    required this.canPay,
    required this.onPay,
    required this.onEditPayment,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const sub = TextStyle(fontSize: 16, color: Color(0xFF5B6675));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatMonth(l, month.month),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(status: month.status),
            ],
          ),
          Text(
            l.received(
              formatMoney(month.paid),
              formatMoney(month.requiredAmount),
            ),
            style: sub,
          ),
          for (final p in month.payments)
            _PaymentLine(payment: p, onEdit: onEditPayment),
          if (canPay && month.balance > 0) ...[
            Text(
              l.balance(formatMoney(month.balance)),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            BigButton(
              label: l.btnPayMonth,
              kind: BigButtonKind.secondary,
              small: true,
              onPressed: onPay,
            ),
          ],
        ],
      ),
    );
  }
}
