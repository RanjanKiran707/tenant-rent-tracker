# Tenant Groups – Progress

Feature: tenants are organised into **Groups**. Home shows groups; a group opens its tenant list; existing tenants go to **Uncategorized** on upgrade.

Rules: `../specs.md` (section Groups). Screens: `../mockup.html`. Tables: `../data_model_tenant_tracker.md` and `../erd_tenant_tracker.md`. Other layers: `data_layer_progress.md`, `usecase_progress.md`.

Decisions (confirmed with the user):
- Uncategorized is a **real group row** with the fixed uuid `uncategorized`, so `Tenant.groupUuid` is never null.
- v1 actions: add group, rename group, move a tenant to another group, delete a group (only with no active tenants; soft delete).
- Home group card: name, tenant count, most urgent status, money still to receive. Top totals still cover every tenant.
- Add Tenant has a Group picker, defaulting to the group the user came from.
- The Archived list stays flat in v1.

Working rules for this feature: tests are written but the user runs `flutter test`; only `flutter analyze` and `build_runner` are run here. Widget tests stay commented out.

## Steps

| # | Step | State |
|---|---|---|
| 1 | Mockup: groups on Home, group screen, add/rename/delete group, group picker, move tenant | done |
| 2 | Docs: data model, ERD, specs (Groups section) | done |
| 3 | Data layer: `TenantGroups` table, `Tenants.groupUuid`, schema 2 migration, group repository | done |
| 4 | Use cases: group business use cases, `AddTenantUsecase` group, Home / group / groups watchers, DI | done |
| 5 | Presentation: Home, group screen, add/rename group, Add Tenant picker, Move to group, l10n (en + kn) | done |
| 6 | Tests: harness updates, group tests, migration test (schema 1 -> 2). Written; not run by the assistant | done |
| 7 | Final `flutter analyze` is clean. User runs `flutter test` and checks an upgrade by hand | todo (user) |

## Log

### Steps 1 and 2 – mockup and docs (done)
- `mockup.html`: sample data has groups (Block A, Block B, Block C, Uncategorized) and `groupId` on every tenant. Manjunath S is in Uncategorized to show the migrated case; Block C is empty to show deleting a group.
- Home lists group cards (urgency order, empty groups last, Uncategorized hidden while empty) plus "+ Add a group" (the Home "Add a tenant" button was removed later; tenants are added from a group screen). The group screen holds the tenant list that Home used to show, with Add tenant, Rename group and Delete group (not for Uncategorized).
- Delete group: a confirm dialog, or a note when the group still has tenants. Deleting is a soft delete in the mockup too, so an archived tenant's group still resolves.
- Tenant Detail shows "Group: ..." and a "Move to another group" button with a radio-list dialog. Adding a tenant replaces the form with the tenant page, so Back returns to the group.
- English and Kannada strings added for all new text. The Kannada was written by the assistant and needs a native check.
- `data_model_tenant_tracker.md` (TenantGroup table, `Tenant.groupUuid`, behaviours, migration), `erd_tenant_tracker.md` (five tables) and `specs.md` (Groups section) are updated.
- Not yet verified: the mockup script passes `node --check`, but it has not been clicked through in a browser.

### Steps 3 to 6 – code and tests (done; tests not run by the assistant)
- **Data layer.** `TenantGroups` table; `Tenants.groupUuid` (not null, default `uncategorized`, references `TenantGroups`). `AppDatabase` is schema 2: `onCreate` creates all tables and inserts Uncategorized; `onUpgrade` from 1 creates the table, inserts Uncategorized and rebuilds `tenants` with `TableMigration` (a plain `addColumn` cannot add a NOT NULL column that has a REFERENCES clause). drift runs migrations with foreign keys off, and `beforeOpen` switches them on afterwards. `app_database.g.dart` was regenerated with `build_runner`.
- New `lib/data/tenant_group/` (model, interface, repository): `addGroup`, `getGroup`, `getActiveGroups`, `watchActiveGroups`, `watchAllGroups` (includes deleted groups, so an archived tenant's group can still be named), `renameGroup`, `deleteGroup`. `TenantRepository` gained `setTenantGroup`. `TenantModel.groupUuid` defaults to Uncategorized, so older call sites and tests still compile.
- **Use cases.** Business: `AddGroupUsecase`, `RenameGroupUsecase`, `DeleteGroupUsecase`, `MoveTenantToGroupUsecase`; `AddTenantUsecase` now takes the group repository and checks the chosen group. UI: `WatchHomeUsecase` returns group cards (`HomeGroupRow`) built from a shared `buildTenantRows`; new `WatchGroupUsecase` (tenants of one group) and `WatchGroupsUsecase` (pickers); `WatchTenantDetailUsecase` also returns `groupUuid` and `groupName`.
- **Presentation.** Home shows group cards plus "+ Add a group" (no Add a tenant button; tenants are added from a group screen). New `features/group/` (group screen with Add tenant, Rename, Delete; shared `GroupNameDialog`). Add Tenant has a Group picker. Tenant Detail shows "Group: ..." and a "Move to another group" dialog. `TotalBox` moved to `core/widgets`. English and Kannada strings added; `helpHome` rewritten. The Kannada was written by the assistant and needs a native check.
- **Tests (written, not run here).** New group repository tests, `watchTenant` and `setTenantGroup` tests, business tests for the four group use cases and `AddTenantUsecase` groups, UI use-case tests for the group cards, group screen, group list and detail group, view-model tests, and `test/data/migration_test.dart` (a schema-1 database built with raw SQL, upgraded by `AppDatabase`). Existing Home tests were rewritten for group cards; their tenant-row checks now read the Uncategorized group screen.
- `flutter analyze` is clean for `lib` and `test`.

Differences from the plan and the mockup:
- Add group and Rename group are **dialogs** (like Edit name), not full screens as drawn in `mockup.html`. Behaviour and strings are the same.
- No `countActiveTenants` on the repository: `DeleteGroupUsecase` counts active tenants with `getActiveTenants`, which keeps each repository to one table.
- Added `watchAllGroups` and `TenantRepository.watchTenant` (the latter was added earlier for the rename fix).

To check by hand: install the previous build, add tenants, upgrade to this one, and confirm every tenant is under Uncategorized.
