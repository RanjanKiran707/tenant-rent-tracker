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
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_return_model.dart';
import 'package:tenant_tracker/features/add_tenant/add_tenant_view.dart';
import 'package:tenant_tracker/features/home/home_view_model.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view_model.dart';
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
      watchHome: deps.watchHome,
    );
    WidgetsBinding.instance.addObserver(this);
    ctrl.refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ctrl.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ctrl.dispose();
    super.dispose();
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
          loaded: (data) => _HomeBody(data: data),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final WatchHomeReturnModel data;

  const _HomeBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        TipBanner(text: l.helpHome),
        const SizedBox(height: 8),
        Text(l.thisMonth(formatMonth(l, data.currentMonth)),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _TotalBox(
                label: l.collected,
                amount: data.received,
                ink: const Color(0xFF14683A),
                background: const Color(0xFFD9F5E4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TotalBox(
                label: l.toCollect,
                amount: data.toReceive,
                ink: const Color(0xFF8A5A00),
                background: const Color(0xFFFDEEC2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(l.tenantsCount(data.rows.length),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        Text(l.sortNote,
            style: const TextStyle(fontSize: 15, color: Color(0xFF5B6675))),
        if (data.rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Text(l.noTenants,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, height: 1.5, color: Color(0xFF5B6675))),
          )
        else
          for (final row in data.rows) _TenantCard(row: row),
        BigButton(
          label: l.addTenantBtn,
          onPressed: () => AddTenantView.open(context),
        ),
      ],
    );
  }
}

class _TotalBox extends StatelessWidget {
  final String label;
  final int amount;
  final Color ink;
  final Color background;

  const _TotalBox({
    required this.label,
    required this.amount,
    required this.ink,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: ink, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('₹${formatMoney(amount)}',
              style: TextStyle(
                  color: ink, fontSize: 26, fontWeight: FontWeight.w700)),
        ],
      ),
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
                      child: Text(row.name,
                          style: const TextStyle(
                              fontSize: 21, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: row.status),
                  ],
                ),
                if (row.oldDues > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(l.oldDues(formatMoney(row.oldDues)),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B21A8))),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
