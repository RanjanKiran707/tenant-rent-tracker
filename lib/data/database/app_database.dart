import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/data/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [TenantGroups, Tenants, RentHistories, RentRecords, Payments],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the real on-device database.
  AppDatabase()
      : super(
          driftDatabase(
            name: 'tenant_tracker',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  /// For tests: pass an in-memory executor.
  AppDatabase.forTesting(super.executor);

  /// 1: first release. 2: groups (`TenantGroups`, `Tenants.groupUuid`).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _insertUncategorizedGroup();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(tenantGroups);
        await _insertUncategorizedGroup();
        // A plain addColumn cannot add a NOT NULL column that references
        // another table, so the tenants table is rebuilt (drift handles the
        // foreign keys). Every existing tenant, archived ones too, goes to
        // Uncategorized.
        await m.alterTable(
          TableMigration(
            tenants,
            newColumns: [tenants.groupUuid],
            columnTransformer: {
              tenants.groupUuid: const Constant(uncategorizedGroupUuid),
            },
          ),
        );
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign keys unless this is switched on.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// The built-in group. Its name is stored in English; the app shows the
  /// translated text for this uuid.
  Future<void> _insertUncategorizedGroup() => into(tenantGroups).insert(
    TenantGroupsCompanion.insert(
      uuid: uncategorizedGroupUuid,
      name: 'Uncategorized',
      createdOn: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    ),
  );
}
