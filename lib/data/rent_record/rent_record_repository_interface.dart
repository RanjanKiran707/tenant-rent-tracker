import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_model.dart';

abstract interface class RentRecordRepositoryInterface {
  /// Saves the records that do not exist yet. A record that already exists
  /// for the same tenant and month is left untouched (snapshots never change).
  Future<Result<void>> insertMissing(List<RentRecordModel> records);

  /// Changes the snapshot of one month. Does nothing if the record is missing.
  Future<Result<void>> updateRequiredAmount(
    String tenantUuid,
    String month,
    int requiredAmount,
  );

  /// Records of a tenant, oldest month first.
  Future<Result<List<RentRecordModel>>> getRecords(String tenantUuid);

  /// Records of one tenant, re-emitted whenever they change.
  Stream<Result<List<RentRecordModel>>> watchRecordsOfTenant(String tenantUuid);

  /// Records of every tenant (active and deleted), re-emitted on change.
  Stream<Result<List<RentRecordModel>>> watchAllRecords();
}
