// drift's `.check()` refers to the column being defined; the analyzer
// reads that as recursion.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

/// Table definitions. See project_spec/data_model_tenant_tracker.md.
/// Months are text `YYYY-MM`, dates are text `YYYY-MM-DD`, money is int rupees.

@DataClassName('TenantRow')
class Tenants extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdOn => dateTime()();
  IntColumn get dueDay => integer()
      .withDefault(const Constant(10))
      .check(dueDay.isBetweenValues(1, 31))();
  TextColumn get startMonth => text()();

  /// null = active, set = deleted (archived).
  TextColumn get deletedMonth => text().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

@DataClassName('RentHistoryRow')
class RentHistories extends Table {
  TextColumn get uuid => text()();
  TextColumn get tenantUuid => text().references(Tenants, #uuid)();
  TextColumn get effectiveFromMonth => text()();
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();

  @override
  Set<Column> get primaryKey => {uuid};

  @override
  List<Set<Column>> get uniqueKeys => [
        {tenantUuid, effectiveFromMonth},
      ];
}

@DataClassName('RentRecordRow')
class RentRecords extends Table {
  TextColumn get uuid => text()();
  TextColumn get tenantUuid => text().references(Tenants, #uuid)();
  TextColumn get month => text()();

  /// Snapshot of the rent for that month.
  IntColumn get requiredAmount =>
      integer().check(requiredAmount.isBiggerThanValue(0))();

  @override
  Set<Column> get primaryKey => {uuid};

  @override
  List<Set<Column>> get uniqueKeys => [
        {tenantUuid, month},
      ];
}

@DataClassName('PaymentRow')
class Payments extends Table {
  TextColumn get uuid => text()();
  TextColumn get rentRecordUuid => text().references(RentRecords, #uuid)();
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();
  TextColumn get paidOn => text()();
  DateTimeColumn get createdOn => dateTime()();

  @override
  Set<Column> get primaryKey => {uuid};
}
