import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/errors/result.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_model.dart';
import 'package:tenant_tracker/data/tenant_group/tenant_group_repository_interface.dart';
import 'package:uuid/uuid.dart';

/// Adds a group and returns its uuid. The name is trimmed.
///
/// Validation errors: `group_name_required`, `group_name_taken` (another
/// active group has the same name, ignoring case).
class AddGroupUsecase {
  final TenantGroupRepositoryInterface _groups;
  final Clock _clock;
  final Uuid _uuid;

  AddGroupUsecase(this._groups, this._clock, {Uuid uuid = const Uuid()})
    : _uuid = uuid;

  Future<Result<String>> call(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Err(ValidationFailure('group_name_required'));
    }

    final active = await _groups.getActiveGroups();
    switch (active) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        if (value.any((g) => _sameName(g.name, trimmed))) {
          return const Err(ValidationFailure('group_name_taken'));
        }
    }

    final group = TenantGroupModel(
      uuid: _uuid.v4(),
      name: trimmed,
      createdOn: _clock.nowUtc(),
    );
    final saved = await _groups.addGroup(group);
    return saved.map((_) => group.uuid);
  }
}

bool _sameName(String a, String b) =>
    a.trim().toLowerCase() == b.trim().toLowerCase();
