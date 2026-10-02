import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/core/widgets/obx_value.dart';
import 'package:tenant_tracker/data/settings/app_settings.dart';
import 'package:tenant_tracker/features/app/app_scope.dart';

/// The yellow hint at the top of a screen. Hidden when tips are switched off.
class TipBanner extends StatelessWidget {
  final String text;

  const TipBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ObxValue<ViewState<AppSettings>>(
      listenable: AppScope.of(context).state,
      builder: (state) {
        final show = switch (state) {
          ViewStateLoaded(data: final s) => s.showTips,
          _ => true,
        };
        if (!show) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8DC),
            border: Border.all(color: const Color(0xFFF0DC8A)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
            ],
          ),
        );
      },
    );
  }
}
