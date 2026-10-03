import 'package:drift/drift.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/database/app_database.dart';
import 'package:tenant_tracker/data/database/repository_guard.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_model.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository_interface.dart';

class TenantGroupRepository implements TenantGroupRepositoryInterface {
  final AppDatabase _db;

  TenantGroupRepository(this._db);

  @override
  Future<Result<void>> addGroup(TenantGroupModel group) {
    return guard(() async {
      await _db.into(_db.tenantGroups).insert(
        TenantGroupsCompanion.insert(
          uuid: group.uuid,
          name: group.name,
          createdOn: group.createdOn,
          deletedMonth: Value(group.deletedMonth),
        ),
      );
    });
  }

  @override
  Future<Result<TenantGroupModel?>> getGroup(String uuid) {
    return guard(() async {
      final row = await (_db.select(
        _db.tenantGroups,
      )..where((g) => g.uuid.equals(uuid))).getSingleOrNull();
      return row == null ? null : _fromRow(row);
    });
  }

  @override
  Future<Result<List<TenantGroupModel>>> getActiveGroups() {
    return guard(() async {
      final rows = await _activeQuery().get();
      return rows.map(_fromRow).toList();
    });
  }

  @override
  Stream<Result<List<TenantGroupModel>>> watchActiveGroups() {
    return guardStream(
      _activeQuery().watch().map((rows) => rows.map(_fromRow).toList()),
    );
  }

  @override
  Stream<Result<List<TenantGroupModel>>> watchAllGroups() {
    final query = _db.select(_db.tenantGroups)
      ..orderBy([(g) => OrderingTerm.asc(g.createdOn)]);
    return guardStream(
      query.watch().map((rows) => rows.map(_fromRow).toList()),
    );
  }

  @override
  Future<Result<void>> renameGroup(String uuid, String name) {
    return guard(() async {
      await (_db.update(_db.tenantGroups)..where((g) => g.uuid.equals(uuid)))
          .write(TenantGroupsCompanion(name: Value(name)));
    });
  }

  @override
  Future<Result<void>> deleteGroup(String uuid, String deletedMonth) {
    return guard(() async {
      await (_db.update(_db.tenantGroups)..where((g) => g.uuid.equals(uuid)))
          .write(TenantGroupsCompanion(deletedMonth: Value(deletedMonth)));
    });
  }

  SimpleSelectStatement<$TenantGroupsTable, TenantGroupRow> _activeQuery() =>
      _db.select(_db.tenantGroups)
        ..where((g) => g.deletedMonth.isNull())
        ..orderBy([(g) => OrderingTerm.asc(g.createdOn)]);

  TenantGroupModel _fromRow(TenantGroupRow r) => TenantGroupModel(
    uuid: r.uuid,
    name: r.name,
    createdOn: r.createdOn,
    deletedMonth: r.deletedMonth,
  );
}
