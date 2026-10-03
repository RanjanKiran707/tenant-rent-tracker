import 'package:tenant_tracker/core/constants.dart';

/// A group to choose from (Add Tenant, Move to group).
class GroupOption {
  final String groupUuid;

  /// As stored. For Uncategorized the screen shows its translated name
  /// instead.
  final String name;

  const GroupOption({required this.groupUuid, required this.name});

  bool get isUncategorized => groupUuid == uncategorizedGroupUuid;
}
