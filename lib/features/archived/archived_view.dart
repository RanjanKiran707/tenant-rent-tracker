import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/core/utils/display_format.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/core/widgets/app_bar_actions.dart';
import 'package:tenant_tracker/core/widgets/form_parts.dart';
import 'package:tenant_tracker/core/widgets/obx_value.dart';
import 'package:tenant_tracker/core/widgets/tip_banner.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_archived_tenants/watch_archived_tenants_return_model.dart';
import 'package:tenant_tracker/features/archived/archived_view_model.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view.dart';
import 'package:tenant_tracker/features/tenant_detail/tenant_detail_view_model.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

class ArchivedView extends StatefulWidget {
  const ArchivedView({super.key});

  static Future<void> open(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ArchivedView()),
  );

  @override
  State<ArchivedView> createState() => _ArchivedViewState();
}

class _ArchivedViewState extends State<ArchivedView> {
  late final ArchivedViewModel ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = ArchivedViewModel(
      watchArchived: AppDependencies.instance.watchArchivedTenants,
    );
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.archTitle),
        actions: [AppBarActions(helpText: l.helpArchive)],
      ),
      body: ObxValue<ViewState<WatchArchivedTenantsReturnModel>>(
        listenable: ctrl.state,
        builder: (state) => state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (failure) => LoadError(failure: failure),
          loaded: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              TipBanner(text: l.helpArchive),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECDCFA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  l.archNote,
                  style: const TextStyle(
                    color: Color(0xFF4B1478),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (data.rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    l.archEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF5B6675),
                    ),
                  ),
                )
              else
                for (final row in data.rows) _ArchivedCard(row: row),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchivedCard extends StatelessWidget {
  final ArchivedTenantRow row;

  const _ArchivedCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final removed = l.archRemovedOn(formatMonth(l, row.deletedMonth));
    final rent = row.lastRent;
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  rent == null
                      ? removed
                      : '$removed · ${l.rentPerMonth(formatMoney(rent))}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5B6675),
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
