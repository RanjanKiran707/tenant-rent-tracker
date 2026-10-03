import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository_interface.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_groups/watch_groups_return_model.dart';

/// Every active group, Uncategorized included whether or not it has tenants,
/// oldest first (Uncategorized is the oldest). For the pickers. Presentation
/// only: it never writes.
class WatchGroupsUsecase {
  final TenantGroupRepositoryInterface _groups;

  WatchGroupsUsecase(this._groups);

  Stream<Result<List<GroupOption>>> call() {
    return _groups.watchActiveGroups().map(
      (result) => result.map(
        (groups) => [
          for (final g in groups) GroupOption(groupUuid: g.uuid, name: g.name),
        ],
      ),
    );
  }
}
