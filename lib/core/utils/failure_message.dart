import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

/// The text shown to the user for a failure. A `ValidationFailure` carries a
/// code; anything else (storage, unexpected) gets the generic message.
String failureMessage(AppLocalizations l, Failure failure) {
  if (failure is! ValidationFailure) return l.errGeneric;
  return switch (failure.message) {
    'name_required' => l.errName,
    'rent_invalid' => l.errRent,
    'due_day_invalid' => l.errDueDay,
    'start_month_invalid' => l.errStartMonth,
    'start_month_in_future' => l.errStartFuture,
    'amount_invalid' => l.errAmount,
    'date_invalid' => l.errDate,
    'date_in_future' => l.errDateFuture,
    'tenant_not_found' => l.errTenantNotFound,
    'tenant_deleted' => l.errTenantDeleted,
    'language_unsupported' => l.errLanguage,
    _ => l.errGeneric,
  };
}
