import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';

class PaymentItem {
  final String uuid;
  final int amount;

  /// `YYYY-MM-DD`
  final String paidOn;

  const PaymentItem({
    required this.uuid,
    required this.amount,
    required this.paidOn,
  });
}

/// One month of one tenant, ready to show.
class MonthDetail {
  final String rentRecordUuid;

  /// `YYYY-MM`
  final String month;
  final MonthStatus status;
  final int requiredAmount;

  /// Received as of today.
  final int paid;

  /// Still owed, never below zero.
  final int balance;

  /// Paid above the required amount (0 when none).
  final int extra;

  /// `YYYY-MM-DD`
  final String dueDate;

  /// Oldest first.
  final List<PaymentItem> payments;

  const MonthDetail({
    required this.rentRecordUuid,
    required this.month,
    required this.status,
    required this.requiredAmount,
    required this.paid,
    required this.balance,
    required this.extra,
    required this.dueDate,
    required this.payments,
  });
}

class WatchTenantDetailReturnModel {
  final String tenantUuid;
  final String name;

  /// The tenant's group (Uncategorized unless moved), and its name as stored.
  /// For Uncategorized the screen shows its translated name instead.
  final String groupUuid;
  final String groupName;
  final int dueDay;

  /// True for a deleted (archived) tenant: no actions, latest month on top.
  final bool readOnly;

  /// `YYYY-MM` the tenant was deleted in; null for an active tenant.
  final String? deletedMonth;

  /// Rent of the month on top; for a tenant with no record yet, from history.
  final int currentRent;

  /// The big card: this month for an active tenant, the latest month for an
  /// archived one. Null when the tenant has no record yet, and for an active
  /// tenant whose current month is fully paid (it is in [months] instead).
  final MonthDetail? topMonth;

  /// Owed for months before the current one.
  final int oldDues;

  /// The oldest month with old dues (for "Record old dues received").
  final String? oldestOwingMonth;

  /// The record of [oldestOwingMonth].
  final String? oldestOwingRentRecordUuid;

  /// Old dues plus the balance of the current month (for the delete dialog).
  final int totalOwed;

  /// A rent change that has not started yet: effective from this month.
  final String? pendingRentMonth;
  final int? pendingRentAmount;

  /// The History list, newest first. For an active tenant it leaves out the
  /// month shown in [topMonth] and includes the current month once paid; for
  /// an archived tenant it has every month.
  final List<MonthDetail> months;

  const WatchTenantDetailReturnModel({
    required this.tenantUuid,
    required this.name,
    required this.groupUuid,
    required this.groupName,
    required this.dueDay,
    required this.readOnly,
    required this.deletedMonth,
    required this.currentRent,
    required this.topMonth,
    required this.oldDues,
    required this.oldestOwingMonth,
    required this.oldestOwingRentRecordUuid,
    required this.totalOwed,
    required this.pendingRentMonth,
    required this.pendingRentAmount,
    required this.months,
  });
}
