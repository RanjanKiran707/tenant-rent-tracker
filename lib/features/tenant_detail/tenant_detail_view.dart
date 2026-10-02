import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
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

  static Route<void> route(TenantDetailBundle bundle) => MaterialPageRoute(
        builder: (_) => TenantDetailView(bundle: bundle),
      );

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
      undoPayment: deps.undoPayment,
    );
    ctrl.deleteState.addListener(_onDeleteStateChanged);
    WidgetsBinding.instance.addObserver(this);
    ctrl.refresh();
  }

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
      ..showSnackBar(SnackBar(
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
      ));
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
              actions: [AppBarActions(helpText: l.helpDetail, showLegend: true)],
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
  final VoidCallback onDelete;

  const _DetailBody({
    required this.data,
    required this.busy,
    required this.deleteState,
    required this.onPay,
    required this.onRent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final top = data.topMonth;
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
                  fontWeight: FontWeight.w700),
            ),
          )
        else
          TipBanner(text: l.helpDetail),
        const SizedBox(height: 10),
        Text(data.name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        Text(l.rentPerMonth(formatMoney(data.currentRent)),
            style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675))),
        if (top != null) _TopMonthCard(month: top),
        if (!data.readOnly && data.oldDues > 0)
          InfoBox(
            background: const Color(0xFFF6ECFD),
            border: const Color(0xFFDBBDF2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.oldDues(formatMoney(data.oldDues)),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
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
            child: Text(l.pendingRentNote(
              formatMonth(l, data.pendingRentMonth!),
              formatMoney(data.pendingRentAmount ?? 0),
            )),
          ),
        if (!data.readOnly) ...[
          BigButton(label: l.btnPay, onPressed: () => onPay(null)),
          BigButton(
            label: l.btnRent,
            kind: BigButtonKind.secondary,
            onPressed: onRent,
          ),
        ],
        const SizedBox(height: 22),
        Text(l.history,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: data.months.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(l.noHistory,
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF5B6675))),
                )
              : Column(
                  children: [
                    for (final month in data.months)
                      _HistoryMonth(
                        month: month,
                        canPay: !data.readOnly,
                        onPay: () => onPay(month.rentRecordUuid),
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

class _TopMonthCard extends StatelessWidget {
  final MonthDetail month;

  const _TopMonthCard({required this.month});

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
                child: Text(formatMonth(l, month.month),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              StatusChip(status: month.status),
            ],
          ),
          const SizedBox(height: 2),
          Text(statusDescription(l, month.status),
              style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675))),
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
          Text(l.received(
              formatMoney(month.paid), formatMoney(month.requiredAmount))),
          if (month.balance > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.balance(formatMoney(month.balance)),
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w700)),
            ),
          if (month.extra > 0)
            Text(l.extraNote(formatMoney(month.extra)),
                style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675))),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
                l.dueDate(formatDayMonth(l, month.dueDate)),
                style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675))),
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

  const _HistoryMonth({
    required this.month,
    required this.canPay,
    required this.onPay,
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
                child: Text(formatMonth(l, month.month),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              StatusChip(status: month.status),
            ],
          ),
          Text(
              l.received(
                  formatMoney(month.paid), formatMoney(month.requiredAmount)),
              style: sub),
          for (final p in month.payments)
            Text('₹${formatMoney(p.amount)} · ${formatDayMonth(l, p.paidOn)}',
                style: sub),
          if (canPay && month.balance > 0) ...[
            Text(l.balance(formatMoney(month.balance)),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
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
