import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/data/payment/payment_model.dart';
import 'package:tenant_tracker/domain/use_cases/ui/month_status/month_status.dart';

PaymentModel pay(int amount, String on, {int order = 0}) => PaymentModel(
      uuid: '$on-$amount-$order',
      rentRecordUuid: 'r',
      amount: amount,
      paidOn: on,
      createdOn: DateTime.utc(2026, 1, 1, 0, 0, order),
    );

/// Rent 5000 for 2026-03, due on the 10th, unless a test says otherwise.
MonthStatus status(
  List<PaymentModel> payments, {
  required String today,
  String month = '2026-03',
  int required = 5000,
  int dueDay = 10,
}) =>
    computeMonthStatus(
      month: month,
      requiredAmount: required,
      dueDay: dueDay,
      payments: payments,
      today: today,
    );

void main() {
  group('not fully paid', () {
    test('Pending: before the due date, nothing paid', () {
      expect(status([], today: '2026-03-05'), MonthStatus.pending);
    });

    test('Pending on the due date itself (due date is inclusive)', () {
      expect(status([], today: '2026-03-10'), MonthStatus.pending);
    });

    test('Overdue: the day after the due date, nothing paid', () {
      expect(status([], today: '2026-03-11'), MonthStatus.overdue);
    });

    test('Overdue on the last day of the month (month end is inclusive)', () {
      expect(status([], today: '2026-03-31'), MonthStatus.overdue);
    });

    test('Partial: some paid, due date not passed', () {
      expect(status([pay(2000, '2026-03-02')], today: '2026-03-10'),
          MonthStatus.partial);
    });

    test('Partial Overdue: some paid, due date passed, month not over', () {
      expect(status([pay(2000, '2026-03-02')], today: '2026-03-20'),
          MonthStatus.partialOverdue);
    });

    test('Backlog: the month ended with something still owed', () {
      expect(status([pay(2000, '2026-03-02')], today: '2026-04-01'),
          MonthStatus.backlog);
    });

    test('Backlog also when nothing was paid at all', () {
      expect(status([], today: '2026-04-01'), MonthStatus.backlog);
    });
  });

  group('fully paid', () {
    test('Completed: paid in full on the due date', () {
      expect(status([pay(5000, '2026-03-10')], today: '2026-03-20'),
          MonthStatus.completed);
    });

    test('Completed: paid in full before the due date', () {
      expect(status([pay(5000, '2026-03-01')], today: '2026-03-01'),
          MonthStatus.completed);
    });

    test('Completed in two parts, both on time', () {
      expect(
          status([pay(3000, '2026-03-02'), pay(2000, '2026-03-09')],
              today: '2026-03-30'),
          MonthStatus.completed);
    });

    test('Late Completed: full amount reached after the due date', () {
      expect(status([pay(5000, '2026-03-11')], today: '2026-03-15'),
          MonthStatus.lateCompleted);
    });

    test('Late Completed: partly on time, the rest after the due date', () {
      expect(
          status([pay(3000, '2026-03-02'), pay(2000, '2026-03-25')],
              today: '2026-03-30'),
          MonthStatus.lateCompleted);
    });

    test('Late Completed on the last day of the month', () {
      expect(status([pay(5000, '2026-03-31')], today: '2026-03-31'),
          MonthStatus.lateCompleted);
    });

    test('Backlog Cleared: full amount reached after the month ended', () {
      expect(
          status([pay(3000, '2026-03-04'), pay(2000, '2026-04-12')],
              today: '2026-04-12'),
          MonthStatus.backlogCleared);
    });

    test('the status stays Completed long after the month ended', () {
      expect(status([pay(5000, '2026-03-05')], today: '2026-09-01'),
          MonthStatus.completed);
    });
  });

  group('the day the total is reached decides', () {
    test('a later extra payment does not change a Completed month', () {
      expect(
          status([pay(5000, '2026-03-05'), pay(500, '2026-03-25')],
              today: '2026-03-30'),
          MonthStatus.completed);
    });

    test('overpayment counts as paid, timing still decides the label', () {
      expect(status([pay(9000, '2026-03-12')], today: '2026-03-12'),
          MonthStatus.lateCompleted);
    });

    test('payments are ordered by day even if entered the other way round',
        () {
      // Entered late, but dated early: the total was reached on 2026-03-09.
      final payments = [pay(2000, '2026-03-09', order: 2), pay(3000, '2026-03-02', order: 1)];
      expect(status(payments, today: '2026-03-30'), MonthStatus.completed);
    });

    test('a payment dated after today is not counted yet', () {
      expect(status([pay(5000, '2026-03-20')], today: '2026-03-15'),
          MonthStatus.overdue);
    });
  });

  group('due day that does not exist in the month', () {
    test('due day 31 in a 30-day month falls back to the 30th', () {
      expect(status([], today: '2026-04-30', month: '2026-04', dueDay: 31),
          MonthStatus.pending);
      expect(
          status([pay(5000, '2026-04-30')],
              today: '2026-04-30', month: '2026-04', dueDay: 31),
          MonthStatus.completed);
    });

    test('due day 31 in February falls back to the 28th', () {
      expect(status([], today: '2026-02-28', month: '2026-02', dueDay: 31),
          MonthStatus.pending);
    });

    test('due day 30 in a leap February is the 29th', () {
      expect(status([], today: '2028-02-29', month: '2028-02', dueDay: 30),
          MonthStatus.pending);
    });
  });

  group('mockup sample data (today 2026-10-12)', () {
    const today = '2026-10-12';

    test('Manjunath: part paid in August, rest in September -> Backlog Cleared',
        () {
      expect(
          status([pay(3000, '2026-08-04'), pay(2500, '2026-09-12')],
              today: today, month: '2026-08', required: 5500, dueDay: 5),
          MonthStatus.backlogCleared);
    });

    test('Farida: September part paid, month over -> Backlog', () {
      expect(
          status([pay(4000, '2026-09-06')],
              today: today, month: '2026-09', required: 9000, dueDay: 5),
          MonthStatus.backlog);
    });

    test('Farida: October nothing paid, due day 5 passed -> Overdue', () {
      expect(
          status([],
              today: today, month: '2026-10', required: 9000, dueDay: 5),
          MonthStatus.overdue);
    });

    test('Anita: part paid, due day 20 not yet passed -> Partial', () {
      expect(
          status([pay(3000, '2026-10-06')],
              today: today, month: '2026-10', required: 7000, dueDay: 20),
          MonthStatus.partial);
    });

    test('Ramesh: October nothing paid, due day 15 not yet passed -> Pending',
        () {
      expect(
          status([],
              today: today, month: '2026-10', required: 8000, dueDay: 15),
          MonthStatus.pending);
    });
  });

  group('helpers', () {
    test('paidAsOf only counts payments up to today', () {
      final p = [pay(1000, '2026-03-01'), pay(2000, '2026-03-20')];
      expect(paidAsOf(p, '2026-03-10'), 1000);
      expect(paidAsOf(p, '2026-03-20'), 3000);
    });

    test('balanceOf is never negative', () {
      expect(balanceOf(5000, 2000), 3000);
      expect(balanceOf(5000, 5000), 0);
      expect(balanceOf(5000, 9000), 0);
    });

    test('attentionRank puts urgent first, and old dues half a step up', () {
      expect(attentionRank(MonthStatus.overdue, hasOldDues: false),
          lessThan(attentionRank(MonthStatus.partial, hasOldDues: false)));
      expect(attentionRank(MonthStatus.pending, hasOldDues: true), 2.5);
      expect(
          attentionRank(MonthStatus.pending, hasOldDues: true),
          lessThan(attentionRank(MonthStatus.pending, hasOldDues: false)));
      expect(attentionRank(MonthStatus.completed, hasOldDues: false), 5);
    });
  });
}
