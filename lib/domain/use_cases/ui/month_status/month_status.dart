import 'package:tenant_tracker/core/utils/month_utils.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';

/// The eight monthly states from specs.md. Never stored: always computed from
/// the month's required amount, its payments, the due day and today.
enum MonthStatus {
  pending,
  completed,
  lateCompleted,
  partial,
  partialOverdue,
  overdue,
  backlog,
  backlogCleared,
}

/// Lower number = needs attention sooner (the mockup's `RANK`).
const Map<MonthStatus, int> _rank = {
  MonthStatus.overdue: 0,
  MonthStatus.partialOverdue: 1,
  MonthStatus.backlog: 1,
  MonthStatus.partial: 2,
  MonthStatus.pending: 3,
  MonthStatus.lateCompleted: 4,
  MonthStatus.completed: 5,
  MonthStatus.backlogCleared: 5,
};

/// Sort key for the home list. A tenant with old dues moves half a step up.
double attentionRank(MonthStatus status, {required bool hasOldDues}) =>
    _rank[status]! - (hasOldDues ? 0.5 : 0);

/// Payments are ordered by the day received, then by when they were entered.
List<PaymentModel> _inOrder(Iterable<PaymentModel> payments) =>
    payments.toList()
      ..sort((a, b) {
        final byDay = a.paidOn.compareTo(b.paidOn);
        return byDay != 0 ? byDay : a.createdOn.compareTo(b.createdOn);
      });

/// Total of the payments received on or before [today].
int paidAsOf(Iterable<PaymentModel> payments, String today) => payments
    .where((p) => p.paidOn.compareTo(today) <= 0)
    .fold(0, (sum, p) => sum + p.amount);

/// What is still owed for the month, never below zero (overpayment is not
/// carried forward in v1).
int balanceOf(int requiredAmount, int paid) =>
    paid >= requiredAmount ? 0 : requiredAmount - paid;

/// The state of one month on [today] (a port of `computeState` in the mockup).
///
/// - Due date: [dueDay], or the last day of a shorter month; paying on the due
///   date is still on time.
/// - Month end is also inclusive.
/// - Fully paid: the day the running total reached the required amount decides
///   Completed / Late Completed / Backlog Cleared.
MonthStatus computeMonthStatus({
  required String month,
  required int requiredAmount,
  required int dueDay,
  required Iterable<PaymentModel> payments,
  required String today,
}) {
  final received =
      _inOrder(payments.where((p) => p.paidOn.compareTo(today) <= 0));
  final paid = received.fold(0, (sum, p) => sum + p.amount);
  final due = dueDateOf(month, dueDay);
  final end = monthEnd(month);

  if (paid >= requiredAmount) {
    var running = 0;
    var reachedOn = '';
    for (final p in received) {
      running += p.amount;
      if (running >= requiredAmount) {
        reachedOn = p.paidOn;
        break;
      }
    }
    if (reachedOn.compareTo(due) <= 0) return MonthStatus.completed;
    if (reachedOn.compareTo(end) <= 0) return MonthStatus.lateCompleted;
    return MonthStatus.backlogCleared;
  }

  if (today.compareTo(end) > 0) return MonthStatus.backlog;
  if (today.compareTo(due) > 0) {
    return paid == 0 ? MonthStatus.overdue : MonthStatus.partialOverdue;
  }
  return paid == 0 ? MonthStatus.pending : MonthStatus.partial;
}
