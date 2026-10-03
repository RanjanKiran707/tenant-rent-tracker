import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/utils/display_format.dart';

/// A coloured box with a label and a rupee amount ("Money received",
/// "Still to receive"). Used on Home and on the group screen.
class TotalBox extends StatelessWidget {
  final String label;
  final int amount;
  final Color ink;
  final Color background;

  const TotalBox({
    super.key,
    required this.label,
    required this.amount,
    required this.ink,
    required this.background,
  });

  /// The green "received" box.
  const TotalBox.received({
    super.key,
    required this.label,
    required this.amount,
  }) : ink = const Color(0xFF14683A),
       background = const Color(0xFFD9F5E4);

  /// The amber "still to receive" box.
  const TotalBox.toReceive({
    super.key,
    required this.label,
    required this.amount,
  }) : ink = const Color(0xFF8A5A00),
       background = const Color(0xFFFDEEC2);

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
          Text(
            label,
            style: TextStyle(
              color: ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${formatMoney(amount)}',
            style: TextStyle(
              color: ink,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
