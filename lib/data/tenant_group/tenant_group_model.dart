import 'package:tenant_tracker/core/constants.dart';

class TenantGroupModel {
  final String uuid;
  final String name;
  final DateTime createdOn;

  /// null = active, set = deleted, `YYYY-MM`.
  final String? deletedMonth;

  const TenantGroupModel({
    required this.uuid,
    required this.name,
    required this.createdOn,
    this.deletedMonth,
  });

  bool get isDeleted => deletedMonth != null;

  /// The built-in group: it cannot be renamed or deleted, and the app shows
  /// its translated name instead of [name].
  bool get isUncategorized => uuid == uncategorizedGroupUuid;
}
