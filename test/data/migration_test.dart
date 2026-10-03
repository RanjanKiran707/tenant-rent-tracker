import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_tracker/core/constants.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/database/app_database.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository.dart';

/// Creates the schema-1 database (the first release, before groups) the way
/// that release did, with a few rows. Runs only on an empty database, so the
/// app database below finds `user_version = 1` and upgrades it to 2.
void _createSchema1(dynamic raw) {
  final version = raw.select('PRAGMA user_version').first.values.first as int;
  if (version != 0) return;

  raw.execute('''
    CREATE TABLE tenants (
      uuid TEXT NOT NULL,
      name TEXT NOT NULL,
      created_on INTEGER NOT NULL,
      due_day INTEGER NOT NULL DEFAULT 10 CHECK (due_day BETWEEN 1 AND 31),
      start_month TEXT NOT NULL,
      deleted_month TEXT NULL,
      PRIMARY KEY (uuid)
    )''');
  raw.execute('''
    CREATE TABLE rent_histories (
      uuid TEXT NOT NULL,
      tenant_uuid TEXT NOT NULL REFERENCES tenants (uuid),
      effective_from_month TEXT NOT NULL,
      amount INTEGER NOT NULL CHECK (amount > 0),
      PRIMARY KEY (uuid),
      UNIQUE (tenant_uuid, effective_from_month)
    )''');
  raw.execute('''
    CREATE TABLE rent_records (
      uuid TEXT NOT NULL,
      tenant_uuid TEXT NOT NULL REFERENCES tenants (uuid),
      month TEXT NOT NULL,
      required_amount INTEGER NOT NULL CHECK (required_amount > 0),
      PRIMARY KEY (uuid),
      UNIQUE (tenant_uuid, month)
    )''');
  raw.execute('''
    CREATE TABLE payments (
      uuid TEXT NOT NULL,
      rent_record_uuid TEXT NOT NULL REFERENCES rent_records (uuid),
      amount INTEGER NOT NULL CHECK (amount > 0),
      paid_on TEXT NOT NULL,
      created_on INTEGER NOT NULL,
      PRIMARY KEY (uuid)
    )''');

  // An active tenant with rent, a month and a payment, and an archived tenant.
  raw.execute(
    "INSERT INTO tenants VALUES ('t1', 'Ravi', 1767225600, 5, '2026-01', NULL)",
  );
  raw.execute(
    "INSERT INTO tenants VALUES ('t2', 'Lakshmi', 1767225600, 10, '2026-01', '2026-02')",
  );
  raw.execute(
    "INSERT INTO rent_histories VALUES ('h1', 't1', '2026-01', 8000)",
  );
  raw.execute(
    "INSERT INTO rent_histories VALUES ('h2', 't2', '2026-01', 6000)",
  );
  raw.execute("INSERT INTO rent_records VALUES ('r1', 't1', '2026-01', 8000)");
  raw.execute("INSERT INTO rent_records VALUES ('r2', 't2', '2026-01', 6000)");
  raw.execute(
    "INSERT INTO payments VALUES ('p1', 'r1', 3000, '2026-01-04', 1767225600)",
  );
  raw.execute('PRAGMA user_version = 1');
}

void main() {
  late AppDatabase db;

  setUp(() {
    // The setup callback runs when the database is opened, before drift looks
    // at user_version, so drift sees a schema-1 database and migrates it.
    db = AppDatabase.forTesting(NativeDatabase.memory(setup: _createSchema1));
  });

  tearDown(() => db.close());

  group('schema 1 -> 2 (groups)', () {
    test('creates the Uncategorized group', () async {
      final groups = await db.select(db.tenantGroups).get();

      expect(groups, hasLength(1));
      expect(groups.single.uuid, uncategorizedGroupUuid);
      expect(groups.single.name, 'Uncategorized');
      expect(groups.single.deletedMonth, isNull);
    });

    test('puts every existing tenant, archived ones too, in it', () async {
      final tenants = await db.select(db.tenants).get();

      expect(tenants.map((t) => t.uuid), unorderedEquals(['t1', 't2']));
      expect(
        tenants.map((t) => t.groupUuid),
        everyElement(uncategorizedGroupUuid),
      );
    });

    test('keeps every tenant field, record and payment', () async {
      final t1 = (await db.select(db.tenants).get()).firstWhere(
        (t) => t.uuid == 't1',
      );
      expect(t1.name, 'Ravi');
      expect(t1.dueDay, 5);
      expect(t1.startMonth, '2026-01');
      expect(t1.deletedMonth, isNull);

      final t2 = (await db.select(db.tenants).get()).firstWhere(
        (t) => t.uuid == 't2',
      );
      expect(t2.deletedMonth, '2026-02');

      expect(await db.select(db.rentHistories).get(), hasLength(2));
      expect(await db.select(db.rentRecords).get(), hasLength(2));
      final payments = await db.select(db.payments).get();
      expect(payments.single.amount, 3000);
      expect(payments.single.paidOn, '2026-01-04');
    });

    test('leaves no broken foreign keys, and keeps them switched on', () async {
      final broken = await db.customSelect('PRAGMA foreign_key_check').get();
      expect(broken, isEmpty);

      final on = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(on.read<int>('foreign_keys'), 1);
    });

    test('the upgraded database accepts new tenants and groups', () async {
      final tenants = TenantRepository(db);
      final groups = TenantGroupRepository(db);

      final added = await tenants.addTenant(
        TenantModel(
          uuid: 't3',
          name: 'New tenant',
          createdOn: DateTime.utc(2026, 3, 1),
          dueDay: 10,
          startMonth: '2026-03',
        ),
        7000,
      );
      expect(added, isA<Ok<void>>());

      final t3 = (await tenants.getTenant('t3') as Ok<TenantModel?>).value!;
      expect(t3.groupUuid, uncategorizedGroupUuid);
      expect(
        (await groups.getActiveGroups() as Ok).value.map((g) => g.uuid),
        [uncategorizedGroupUuid],
      );
    });
  });
}
