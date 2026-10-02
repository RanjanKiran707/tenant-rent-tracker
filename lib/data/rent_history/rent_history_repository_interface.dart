import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_model.dart';

abstract interface class RentHistoryRepositoryInterface {
  /// Changes the rent from [effectiveFromMonth] onwards, in one transaction:
  /// the history entry is saved (a second change for the same month replaces
  /// the first) and, if that month's RentRecord already exists, its
  /// `requiredAmount` is updated too.
  ///
  /// No rule about which month may be changed: the use case decides that
  /// (spec: a change applies from next month only).
  Future<Result<void>> changeRent({
    required String tenantUuid,
    required String effectiveFromMonth,
    required int amount,
  });

  /// All changes of a tenant, oldest `effectiveFromMonth` first.
  Future<Result<List<RentHistoryModel>>> getHistory(String tenantUuid);

  /// Same as [getHistory], but re-emits whenever the history changes.
  Stream<Result<List<RentHistoryModel>>> watchHistory(String tenantUuid);

  /// Rent for [month]: the entry with the greatest `effectiveFromMonth`
  /// that is <= [month]. Null inside `Ok` when there is none.
  Future<Result<int?>> getRentForMonth(String tenantUuid, String month);
}
