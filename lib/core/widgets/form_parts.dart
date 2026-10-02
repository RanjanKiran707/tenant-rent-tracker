import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/utils/failure_message.dart';
import 'package:tenant_tracker/core/utils/view_state.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

/// A bold field label with a small grey hint under it.
class FormLabel extends StatelessWidget {
  final String label;
  final String? hint;

  const FormLabel({super.key, required this.label, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          if (hint != null)
            Text(
              hint!,
              style: const TextStyle(fontSize: 15, color: Color(0xFF5B6675)),
            ),
        ],
      ),
    );
  }
}

/// Red error text, shown when [state] is an error whose validation code is in
/// [codes]. With [exceptCodes] it shows every error except those (the
/// catch-all place for errors no field shows).
class ErrorLine extends StatelessWidget {
  final ViewState<Object?> state;
  final Set<String>? codes;
  final Set<String>? exceptCodes;

  const ErrorLine({
    super.key,
    required this.state,
    this.codes,
    this.exceptCodes,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      idle: () => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      loaded: (_) => const SizedBox.shrink(),
      error: (failure) {
        if (codes != null && !codes!.contains(failure.message)) {
          return const SizedBox.shrink();
        }
        if (exceptCodes != null && exceptCodes!.contains(failure.message)) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            failureMessage(AppLocalizations.of(context), failure),
            style: const TextStyle(
              color: Color(0xFFB42318),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}

/// Light-blue (or custom colour) information box.
class InfoBox extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color border;

  const InfoBox({
    super.key,
    required this.child,
    this.background = const Color(0xFFEEF3FF),
    this.border = const Color(0xFFC5D5FF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 16),
        child: child,
      ),
    );
  }
}

/// White rounded card.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9DFE6)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

/// Centered error text with a "Try again" button, for a screen that failed to
/// load.
class LoadError extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const LoadError({super.key, required this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              failureMessage(l, failure),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text(l.retry)),
          ],
        ),
      ),
    );
  }
}
