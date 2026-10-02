import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:tenant_tracker/data/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tenants, RentHistories, RentRecords, Payments])
class AppDatabase extends _$AppDatabase {
  /// Opens the real on-device database.
  AppDatabase() : super(driftDatabase(name: 'tenant_tracker'));

  /// For tests: pass an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // SQLite ignores foreign keys unless this is switched on.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
