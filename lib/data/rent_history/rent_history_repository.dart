import 'package:drift/drift.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/database/app_database.dart';
import 'package:tenant_tracker/data/database/repository_guard.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_model.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_repository_interface.dart';
import 'package:uuid/uuid.dart';

class RentHistoryRepository implements RentHistoryRepositoryInterface {
  final AppDatabase _db;

  final Uuid _uuid;

  RentHistoryRepository(this._db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  @override
  Future<Result<void>> changeRent({
    required String tenantUuid,
    required String effectiveFromMonth,
    required int amount,
  }) {
    return guard(() => _db.transaction(() async {
          await _db.into(_db.rentHistories).insert(
                RentHistoriesCompanion.insert(
                  uuid: _uuid.v4(),
                  tenantUuid: tenantUuid,
                  effectiveFromMonth: effectiveFromMonth,
                  amount: amount,
                ),
                onConflict: DoUpdate(
                  (old) => RentHistoriesCompanion(amount: Value(amount)),
                  target: [
                    _db.rentHistories.tenantUuid,
                    _db.rentHistories.effectiveFromMonth,
                  ],
                ),
              );
          await (_db.update(_db.rentRecords)
                ..where((r) =>
                    r.tenantUuid.equals(tenantUuid) &
                    r.month.equals(effectiveFromMonth)))
              .write(RentRecordsCompanion(requiredAmount: Value(amount)));
        }));
  }

  @override
  Future<Result<List<RentHistoryModel>>> getHistory(String tenantUuid) {
    return guard(() async {
      final rows = await (_db.select(_db.rentHistories)
            ..where((r) => r.tenantUuid.equals(tenantUuid))
            ..orderBy([(r) => OrderingTerm.asc(r.effectiveFromMonth)]))
          .get();
      return rows.map(_fromRow).toList();
    });
  }

  @override
  Stream<Result<List<RentHistoryModel>>> watchHistory(String tenantUuid) {
    final query = _db.select(_db.rentHistories)
      ..where((r) => r.tenantUuid.equals(tenantUuid))
      ..orderBy([(r) => OrderingTerm.asc(r.effectiveFromMonth)]);
    return guardStream(
      query.watch().map((rows) => rows.map(_fromRow).toList()),
    );
  }

  @override
  Future<Result<int?>> getRentForMonth(String tenantUuid, String month) {
    return guard(() async {
      final row = await (_db.select(_db.rentHistories)
            ..where((r) =>
                r.tenantUuid.equals(tenantUuid) &
                r.effectiveFromMonth.isSmallerOrEqualValue(month))
            ..orderBy([(r) => OrderingTerm.desc(r.effectiveFromMonth)])
            ..limit(1))
          .getSingleOrNull();
      return row?.amount;
    });
  }

  RentHistoryModel _fromRow(RentHistoryRow r) => RentHistoryModel(
        uuid: r.uuid,
        tenantUuid: r.tenantUuid,
        effectiveFromMonth: r.effectiveFromMonth,
        amount: r.amount,
      );
}
