import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/utils/status_text.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

/// The coloured tag that shows a month's status.
class StatusChip extends StatelessWidget {
  final MonthStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusLabel(AppLocalizations.of(context), status),
        style: TextStyle(
          color: colors.ink,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
