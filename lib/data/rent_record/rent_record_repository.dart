import 'package:drift/drift.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/database/app_database.dart';
import 'package:tenant_tracker/data/database/repository_guard.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository_interface.dart';

class RentRecordRepository implements RentRecordRepositoryInterface {
  final AppDatabase _db;

  RentRecordRepository(this._db);

  @override
  Future<Result<void>> insertMissing(List<RentRecordModel> records) {
    return guard(() async {
      await _db.batch((batch) {
        batch.insertAll(
          _db.rentRecords,
          [
            for (final r in records)
              RentRecordsCompanion.insert(
                uuid: r.uuid,
                tenantUuid: r.tenantUuid,
                month: r.month,
                requiredAmount: r.requiredAmount,
              ),
          ],
          mode: InsertMode.insertOrIgnore,
        );
      });
    });
  }

  @override
  Future<Result<void>> updateRequiredAmount(
    String tenantUuid,
    String month,
    int requiredAmount,
  ) {
    return guard(() async {
      await (_db.update(_db.rentRecords)
            ..where(
                (r) => r.tenantUuid.equals(tenantUuid) & r.month.equals(month)))
          .write(RentRecordsCompanion(requiredAmount: Value(requiredAmount)));
    });
  }

  @override
  Future<Result<List<RentRecordModel>>> getRecords(String tenantUuid) {
    return guard(() async {
      final rows = await _ofTenant(tenantUuid).get();
      return rows.map(_fromRow).toList();
    });
  }

  @override
  Stream<Result<List<RentRecordModel>>> watchRecordsOfTenant(
    String tenantUuid,
  ) {
    return guardStream(
      _ofTenant(tenantUuid).watch().map((rows) => rows.map(_fromRow).toList()),
    );
  }

  @override
  Stream<Result<List<RentRecordModel>>> watchAllRecords() {
    final query = _db.select(_db.rentRecords)
      ..orderBy([(r) => OrderingTerm.asc(r.month)]);
    return guardStream(
      query.watch().map((rows) => rows.map(_fromRow).toList()),
    );
  }

  SimpleSelectStatement<$RentRecordsTable, RentRecordRow> _ofTenant(
    String tenantUuid,
  ) {
    return _db.select(_db.rentRecords)
      ..where((r) => r.tenantUuid.equals(tenantUuid))
      ..orderBy([(r) => OrderingTerm.asc(r.month)]);
  }

  RentRecordModel _fromRow(RentRecordRow r) => RentRecordModel(
        uuid: r.uuid,
        tenantUuid: r.tenantUuid,
        month: r.month,
        requiredAmount: r.requiredAmount,
      );
}
