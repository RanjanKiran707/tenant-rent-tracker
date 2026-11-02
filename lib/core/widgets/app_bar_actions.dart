import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/core/utils/status_text.dart';
import 'package:tenant_tracker/core/widgets/big_button.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

/// The Help and language buttons on the right of an app bar.
/// [showLegend] adds the "what do the tags mean" list to the help dialog.
class AppBarActions extends StatelessWidget {
  final String helpText;
  final bool showLegend;

  const AppBarActions({
    super.key,
    required this.helpText,
    this.showLegend = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l.helpTooltip,
          icon: const Icon(Icons.help_outline),
          onPressed: () => showHelpDialog(context, helpText, showLegend),
        ),
        TextButton(
          onPressed: AppDependencies.instance.appViewModel.toggleLanguage,
          child: Text(
            l.langToggle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

Future<void> showHelpDialog(
  BuildContext context,
  String helpText,
  bool showLegend,
) {
  final l = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l.helpTooltip),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(helpText, style: const TextStyle(fontSize: 18)),
            if (showLegend) ...[
              const SizedBox(height: 16),
              Text(
                l.legendTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              for (final status in MonthStatus.values)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendChip(status: status, l: l),
                      const SizedBox(height: 2),
                      Text(
                        statusDescription(l, status),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        BigButton(label: l.ok, onPressed: () => Navigator.pop(dialogContext)),
      ],
    ),
  );
}

class _LegendChip extends StatelessWidget {
  final MonthStatus status;
  final AppLocalizations l;

  const _LegendChip({required this.status, required this.l});

  @override
  Widget build(BuildContext context) {
    final colors = statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusLabel(l, status),
        style: TextStyle(color: colors.ink, fontWeight: FontWeight.w700),
      ),
    );
  }
}
