import 'package:flutter/material.dart';

enum BigButtonKind { primary, secondary, danger }

/// The large, full-width button used for every main action.
class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BigButtonKind kind;
  final bool small;
  final bool busy;

  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = BigButtonKind.primary,
    this.small = false,
    this.busy = false,
  });

  static const _blue = Color(0xFF1D4ED8);
  static const _red = Color(0xFFB42318);

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (kind) {
      BigButtonKind.primary => (_blue, Colors.white, _blue),
      BigButtonKind.secondary => (Colors.white, _blue, _blue),
      BigButtonKind.danger => (Colors.white, _red, _red),
    };
    final child = busy
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3, color: fg),
          )
        : Text(label, textAlign: TextAlign.center);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        height: small ? 48 : 56,
        child: FilledButton(
          onPressed: busy ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg.withValues(alpha: 0.6),
            disabledForegroundColor: fg.withValues(alpha: 0.6),
            textStyle: TextStyle(
              fontSize: small ? 17 : 20,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: border, width: 2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
