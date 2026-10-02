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
import 'package:tenant_tracker/domain/use_cases/ui/load_rent_change_info/load_rent_change_info_return_model.dart';
import 'package:tenant_tracker/features/change_rent/change_rent_view_model.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

class ChangeRentView extends StatefulWidget {
  final ChangeRentBundle bundle;

  const ChangeRentView({super.key, required this.bundle});

  /// Resolves to the month the new rent starts from (`YYYY-MM`), or null when
  /// the user left without saving.
  static Future<String?> open(BuildContext context, ChangeRentBundle bundle) =>
      Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => ChangeRentView(bundle: bundle)),
      );

  @override
  State<ChangeRentView> createState() => _ChangeRentViewState();
}

class _ChangeRentViewState extends State<ChangeRentView> {
  late final ChangeRentViewModel ctrl;
  final rentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.instance;
    ctrl = ChangeRentViewModel(
      bundle: widget.bundle,
      loadInfo: deps.loadRentChangeInfo,
      changeRent: deps.changeRent,
    );
    ctrl.saveState.addListener(_onSaveStateChanged);
    ctrl.load();
  }

  void _onSaveStateChanged() {
    if (ctrl.saveState.value is! ViewStateLoaded<void> || !mounted) return;
    final info = ctrl.loadState.value;
    final from = info is ViewStateLoaded<LoadRentChangeInfoReturnModel>
        ? info.data.effectiveFromMonth
        : null;
    Navigator.pop(context, from);
  }

  @override
  void dispose() {
    ctrl.saveState.removeListener(_onSaveStateChanged);
    rentController.dispose();
    ctrl.dispose();
    super.dispose();
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
              title: Text(l.rentTitle),
              actions: [AppBarActions(helpText: l.helpRent)],
            ),
            body: ctrl.loadState.value.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (failure) =>
                  LoadError(failure: failure, onRetry: ctrl.load),
              loaded: (info) => _form(context, info, busy),
            ),
          ),
        );
      },
    );
  }

  Widget _form(
    BuildContext context,
    LoadRentChangeInfoReturnModel info,
    bool busy,
  ) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        TipBanner(text: l.helpRent),
        const SizedBox(height: 8),
        Text(info.tenantName,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
        Text(l.rentCurrent(formatMoney(info.currentRent)),
            style: const TextStyle(fontSize: 16, color: Color(0xFF5B6675))),
        FormLabel(label: l.rentNew),
        TextField(
          key: const Key('newRentField'),
          controller: rentController,
          enabled: !busy,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: ctrl.onRentChanged,
        ),
        ObxValue<ViewState<void>>(
          listenable: ctrl.saveState,
          builder: (state) => ErrorLine(state: state),
        ),
        ObxValue<int?>(
          listenable: ctrl.newRent,
          builder: (_) {
            final hint = ctrl.hint;
            if (hint == null) return const SizedBox.shrink();
            final d = hint.difference;
            final headline = d > 0
                ? l.rentUp(formatMoney(d))
                : d < 0
                    ? l.rentDown(formatMoney(-d))
                    : l.rentSame;
            return InfoBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(headline,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(l.rentNotice(
                    formatMonth(l, info.effectiveFromMonth),
                    formatMonth(l, info.currentMonth),
                    formatMoney(info.currentRent),
                  )),
                ],
              ),
            );
          },
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
}
