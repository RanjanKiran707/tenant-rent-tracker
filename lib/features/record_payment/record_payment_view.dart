import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/core/utils/display_format.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/core/widgets/app_bar_actions.dart';
import 'package:tenant_tracker/core/widgets/big_button.dart';
import 'package:tenant_tracker/core/widgets/form_parts.dart';
import 'package:tenant_tracker/core/widgets/obx_value.dart';
import 'package:tenant_tracker/core/widgets/tip_banner.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_payment_options/load_payment_options_return_model.dart';
import 'package:tenant_tracker/features/record_payment/record_payment_view_model.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

class RecordPaymentView extends StatefulWidget {
  final RecordPaymentBundle bundle;

  const RecordPaymentView({super.key, required this.bundle});

  /// Resolves to the saved payment, or null when the user left without saving.
  static Future<RecordedPayment?> open(
    BuildContext context,
    RecordPaymentBundle bundle,
  ) => Navigator.push<RecordedPayment>(
    context,
    MaterialPageRoute(builder: (_) => RecordPaymentView(bundle: bundle)),
  );

  @override
  State<RecordPaymentView> createState() => _RecordPaymentViewState();
}

class _RecordPaymentViewState extends State<RecordPaymentView> {
  late final RecordPaymentViewModel ctrl;
  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.instance;
    ctrl = RecordPaymentViewModel(
      bundle: widget.bundle,
      loadPaymentOptions: deps.loadPaymentOptions,
      recordPayment: deps.recordPayment,
    );
    ctrl.saveState.addListener(_onSaveStateChanged);
    ctrl.load();
  }

  void _onSaveStateChanged() {
    final state = ctrl.saveState.value;
    if (state is! ViewStateLoaded<String> || !mounted) return;
    Navigator.pop(
      context,
      RecordedPayment(paymentUuid: state.data, amount: ctrl.amount.value ?? 0),
    );
  }

  @override
  void dispose() {
    ctrl.saveState.removeListener(_onSaveStateChanged);
    amountController.dispose();
    ctrl.dispose();
    super.dispose();
  }

  void _fillFull() {
    final balance = ctrl.fullBalance;
    amountController.text = '$balance';
    ctrl.onAmountChanged('$balance');
  }

  Future<void> _pickDate(String current, String today) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(current),
      firstDate: DateTime(2000),
      lastDate: DateTime.parse(today),
    );
    if (picked == null) return;
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    ctrl.onDateChanged('${picked.year}-$month-$day');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ObxMulti(
      listenables: [ctrl.loadState, ctrl.saveState],
      builder: () {
        final busy = ctrl.saveState.value.isLoading;
        return PopScope(
          canPop: !busy,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l.payTitle),
              actions: [AppBarActions(helpText: l.helpPay)],
            ),
            body: ctrl.loadState.value.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (failure) =>
                  LoadError(failure: failure, onRetry: ctrl.load),
              loaded: (data) => _form(context, data, busy),
            ),
          ),
        );
      },
    );
  }

  Widget _form(
    BuildContext context,
    LoadPaymentOptionsReturnModel data,
    bool busy,
  ) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        TipBanner(text: l.helpPay),
        const SizedBox(height: 8),
        Text(
          data.tenantName,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        FormLabel(label: l.payMonth, hint: l.payMonthHint),
        ObxValue<String?>(
          listenable: ctrl.selectedRecord,
          builder: (selected) => DropdownButtonFormField<String>(
            key: const Key('monthField'),
            initialValue: selected,
            isExpanded: true,
            items: [
              for (final o in data.options)
                DropdownMenuItem(
                  value: o.rentRecordUuid,
                  child: Text(
                    '${formatMonth(l, o.month)} – '
                    '${l.balance(formatMoney(o.balance))}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: busy
                ? null
                : (v) {
                    if (v != null) ctrl.onMonthChanged(v);
                  },
          ),
        ),
        FormLabel(label: l.payAmount),
        TextField(
          key: const Key('amountField'),
          controller: amountController,
          enabled: !busy,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: ctrl.onAmountChanged,
        ),
        ObxValue<ViewState<String>>(
          listenable: ctrl.saveState,
          builder: (state) =>
              ErrorLine(state: state, codes: const {'amount_invalid'}),
        ),
        ObxValue<String?>(
          listenable: ctrl.selectedRecord,
          builder: (_) => ctrl.fullBalance > 0
              ? BigButton(
                  label: l.payFull(formatMoney(ctrl.fullBalance)),
                  kind: BigButtonKind.secondary,
                  small: true,
                  onPressed: busy ? null : _fillFull,
                )
              : const SizedBox.shrink(),
        ),
        ObxMulti(
          listenables: [ctrl.amount, ctrl.selectedRecord],
          builder: () => _hint(l, ctrl.hint),
        ),
        FormLabel(label: l.payDate),
        ObxValue<String>(
          listenable: ctrl.date,
          builder: (date) => InkWell(
            key: const Key('dateField'),
            onTap: busy ? null : () => _pickDate(date, data.today),
            child: InputDecorator(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                formatDate(l, date),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
        ObxValue<ViewState<String>>(
          listenable: ctrl.saveState,
          builder: (state) =>
              ErrorLine(state: state, exceptCodes: const {'amount_invalid'}),
        ),
        BigButton(label: l.save, busy: busy, onPressed: ctrl.onSave),
        BigButton(
          label: l.cancel,
          kind: BigButtonKind.secondary,
          onPressed: busy ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _hint(AppLocalizations l, PaymentHint? hint) {
    if (hint == null) return const SizedBox.shrink();
    if (!hint.fullyPaid) {
      return InfoBox(child: Text(l.payAfter(formatMoney(hint.balanceAfter))));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            l.payAfterDone,
            style: const TextStyle(
              color: Color(0xFF14683A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (hint.extra > 0)
          InfoBox(child: Text(l.payExtra(formatMoney(hint.extra)))),
      ],
    );
  }
}
