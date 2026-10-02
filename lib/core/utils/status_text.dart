import 'package:flutter/material.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

String statusLabel(AppLocalizations l, MonthStatus s) => switch (s) {
  MonthStatus.pending => l.stPending,
  MonthStatus.completed => l.stCompleted,
  MonthStatus.lateCompleted => l.stLateCompleted,
  MonthStatus.partial => l.stPartial,
  MonthStatus.partialOverdue => l.stPartialOverdue,
  MonthStatus.overdue => l.stOverdue,
  MonthStatus.backlog => l.stBacklog,
  MonthStatus.backlogCleared => l.stBacklogCleared,
};

String statusDescription(AppLocalizations l, MonthStatus s) => switch (s) {
  MonthStatus.pending => l.sdPending,
  MonthStatus.completed => l.sdCompleted,
  MonthStatus.lateCompleted => l.sdLateCompleted,
  MonthStatus.partial => l.sdPartial,
  MonthStatus.partialOverdue => l.sdPartialOverdue,
  MonthStatus.overdue => l.sdOverdue,
  MonthStatus.backlog => l.sdBacklog,
  MonthStatus.backlogCleared => l.sdBacklogCleared,
};

/// Text and background colours of a status (from the mockup).
({Color ink, Color background}) statusColors(MonthStatus s) => switch (s) {
  MonthStatus.pending => (
    ink: const Color(0xFF475569),
    background: const Color(0xFFE8EDF3),
  ),
  MonthStatus.completed => (
    ink: const Color(0xFF14683A),
    background: const Color(0xFFD9F5E4),
  ),
  MonthStatus.lateCompleted => (
    ink: const Color(0xFF0F6B6B),
    background: const Color(0xFFD3F3F1),
  ),
  MonthStatus.partial => (
    ink: const Color(0xFF8A5A00),
    background: const Color(0xFFFDEEC2),
  ),
  MonthStatus.partialOverdue => (
    ink: const Color(0xFFA14200),
    background: const Color(0xFFFFE0C7),
  ),
  MonthStatus.overdue => (
    ink: const Color(0xFFB42318),
    background: const Color(0xFFFDE0DD),
  ),
  MonthStatus.backlog => (
    ink: const Color(0xFF6B21A8),
    background: const Color(0xFFECDCFA),
  ),
  MonthStatus.backlogCleared => (
    ink: const Color(0xFF1E5AA8),
    background: const Color(0xFFDBE9FB),
  ),
};
