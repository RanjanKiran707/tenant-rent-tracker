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
import 'package:tenant_tracker/features/add_tenant/add_tenant_view_model.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view_model.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

class AddTenantView extends StatefulWidget {
  const AddTenantView({super.key});

  static Future<void> open(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddTenantView()),
  );

  @override
  State<AddTenantView> createState() => _AddTenantViewState();
}

class _AddTenantViewState extends State<AddTenantView> {
  late final AddTenantViewModel ctrl;
  final nameController = TextEditingController();
  final rentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.instance;
    ctrl = AddTenantViewModel(
      loadForm: deps.loadAddTenantForm,
      addTenant: deps.addTenant,
    );
    ctrl.saveState.addListener(_onSaveStateChanged);
  }

  /// After a save, replace this screen with the new tenant's page.
  void _onSaveStateChanged() {
    final state = ctrl.saveState.value;
    if (state is! ViewStateLoaded<String> || !mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = nameController.text.trim();
    Navigator.pushReplacement(
      context,
      TenantDetailView.route(TenantDetailBundle(tenantUuid: state.data)),
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.tenantAdded(name))));
  }

  @override
  void dispose() {
    ctrl.saveState.removeListener(_onSaveStateChanged);
    nameController.dispose();
    rentController.dispose();
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ObxValue<ViewState<String>>(
      listenable: ctrl.saveState,
      builder: (state) {
        final busy = state.isLoading;
        return PopScope(
          canPop: !busy,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l.addTitle),
              actions: [AppBarActions(helpText: l.helpAdd)],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                TipBanner(text: l.helpAdd),
                FormLabel(label: l.fName, hint: l.fNameHint),
                TextField(
                  key: const Key('nameField'),
                  controller: nameController,
                  enabled: !busy,
                  textCapitalization: TextCapitalization.words,
                ),
                ErrorLine(state: state, codes: const {'name_required'}),
                FormLabel(label: l.fRent, hint: l.fRentHint),
                TextField(
                  key: const Key('rentField'),
                  controller: rentController,
                  enabled: !busy,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                ErrorLine(state: state, codes: const {'rent_invalid'}),
                FormLabel(label: l.fDue, hint: l.fDueHint),
                ObxValue<int>(
                  listenable: ctrl.dueDay,
                  builder: (day) => DropdownButtonFormField<int>(
                    key: const Key('dueDayField'),
                    initialValue: day,
                    items: [
                      for (var d = 1; d <= 31; d++)
                        DropdownMenuItem(value: d, child: Text('$d')),
                    ],
                    onChanged: busy
                        ? null
                        : (v) => ctrl.dueDay.value = v ?? day,
                  ),
                ),
                ErrorLine(state: state, codes: const {'due_day_invalid'}),
                FormLabel(label: l.fStart, hint: l.fStartHint),
                ObxValue<String>(
                  listenable: ctrl.startMonth,
                  builder: (month) => DropdownButtonFormField<String>(
                    key: const Key('startMonthField'),
                    initialValue: month,
                    items: [
                      for (final m in ctrl.form.startMonthOptions.reversed)
                        DropdownMenuItem(
                          value: m,
                          child: Text(formatMonth(l, m)),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (v) => ctrl.startMonth.value = v ?? month,
                  ),
                ),
                ErrorLine(
                  state: state,
                  codes: const {'start_month_invalid', 'start_month_in_future'},
                ),
                // Anything that is not about one of the fields above.
                ErrorLine(state: state, exceptCodes: _fieldCodes),
                BigButton(
                  label: l.save,
                  busy: busy,
                  onPressed: () => ctrl.onSave(
                    name: nameController.text,
                    rentText: rentController.text,
                  ),
                ),
                BigButton(
                  label: l.cancel,
                  kind: BigButtonKind.secondary,
                  onPressed: busy ? null : () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const _fieldCodes = {
    'name_required',
    'rent_invalid',
    'due_day_invalid',
    'start_month_invalid',
    'start_month_in_future',
  };
}
