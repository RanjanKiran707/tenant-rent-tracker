import 'package:drift/drift.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/database/app_database.dart';
import 'package:tenant_tracker/data/database/repository_guard.dart';
import 'package:tenant_tracker/data/tenant/tenant_model.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository_interface.dart';
import 'package:uuid/uuid.dart';

class TenantRepository implements TenantRepositoryInterface {
  final AppDatabase _db;
  final Uuid _uuid;

  TenantRepository(this._db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  @override
  Future<Result<void>> addTenant(TenantModel tenant, int initialRent) {
    return guard(
      () => _db.transaction(() async {
        await _db.into(_db.tenants).insert(_toCompanion(tenant));
        await _db
            .into(_db.rentHistories)
            .insert(
              RentHistoriesCompanion.insert(
                uuid: _uuid.v4(),
                tenantUuid: tenant.uuid,
                effectiveFromMonth: tenant.startMonth,
                amount: initialRent,
              ),
            );
      }),
    );
  }

  @override
  Future<Result<TenantModel?>> getTenant(String uuid) {
    return guard(() async {
      final row = await (_db.select(
        _db.tenants,
      )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
      return row == null ? null : _fromRow(row);
    });
  }

  @override
  Stream<Result<TenantModel?>> watchTenant(String uuid) {
    final query = _db.select(_db.tenants)..where((t) => t.uuid.equals(uuid));
    return guardStream(
      query.watchSingleOrNull().map(
        (row) => row == null ? null : _fromRow(row),
      ),
    );
  }

  @override
  Future<Result<List<TenantModel>>> getActiveTenants() {
    return guard(() async {
      final rows =
          await (_db.select(_db.tenants)
                ..where((t) => t.deletedMonth.isNull())
                ..orderBy([(t) => OrderingTerm.asc(t.createdOn)]))
              .get();
      return rows.map(_fromRow).toList();
    });
  }

  @override
  Stream<Result<List<TenantModel>>> watchActiveTenants() {
    final query = _db.select(_db.tenants)
      ..where((t) => t.deletedMonth.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.createdOn)]);
    return guardStream(
      query.watch().map((rows) => rows.map(_fromRow).toList()),
    );
  }

  @override
  Stream<Result<List<TenantModel>>> watchArchivedTenants() {
    final query = _db.select(_db.tenants)
      ..where((t) => t.deletedMonth.isNotNull())
      ..orderBy([(t) => OrderingTerm.desc(t.deletedMonth)]);
    return guardStream(
      query.watch().map((rows) => rows.map(_fromRow).toList()),
    );
  }

  @override
  Future<Result<void>> renameTenant(String uuid, String name) {
    return guard(() async {
      await (_db.update(_db.tenants)..where((t) => t.uuid.equals(uuid))).write(
        TenantsCompanion(name: Value(name)),
      );
    });
  }

  @override
  Future<Result<void>> setTenantGroup(String uuid, String groupUuid) {
    return guard(() async {
      await (_db.update(_db.tenants)..where((t) => t.uuid.equals(uuid))).write(
        TenantsCompanion(groupUuid: Value(groupUuid)),
      );
    });
  }

  @override
  Future<Result<void>> deleteTenant(String uuid, String deletedMonth) {
    return guard(() async {
      await (_db.update(_db.tenants)..where((t) => t.uuid.equals(uuid))).write(
        TenantsCompanion(deletedMonth: Value(deletedMonth)),
      );
    });
  }

  TenantsCompanion _toCompanion(TenantModel t) => TenantsCompanion.insert(
    uuid: t.uuid,
    groupUuid: Value(t.groupUuid),
    name: t.name,
    createdOn: t.createdOn,
    dueDay: Value(t.dueDay),
    startMonth: t.startMonth,
    deletedMonth: Value(t.deletedMonth),
  );

  TenantModel _fromRow(TenantRow r) => TenantModel(
    uuid: r.uuid,
    groupUuid: r.groupUuid,
    name: r.name,
    createdOn: r.createdOn,
    dueDay: r.dueDay,
    startMonth: r.startMonth,
    deletedMonth: r.deletedMonth,
  );
}
