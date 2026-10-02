# Data Layer – Progress

Source of truth for the tables: `../data_model_tenant_tracker.md`. Architecture rules: `../flutter_arch_general.md` (section 5).

**Status: data layer complete.** `flutter analyze` is clean and 24 tests pass (23 data-layer tests + the app widget test).

## Done

| Item | Files | State |
|---|---|---|
| drift tables (Tenants, RentHistories, RentRecords, Payments) | `lib/data/database/tables.dart` | done |
| Database class, `PRAGMA foreign_keys = ON`, schema version 1 | `lib/data/database/app_database.dart` (+ generated `.g.dart`) | done |
| Exception -> `Err(StorageFailure)` helpers (`guard`, `guardStream`) | `lib/data/database/repository_guard.dart` | done |
| Tenant: model, interface, repository | `lib/data/tenant/` | done |
| RentHistory: model, interface, repository | `lib/data/rent_history/` | done |
| RentRecord: model, interface, repository | `lib/data/rent_record/` | done |
| Payment: model, interface, repository | `lib/data/payment/` | done |
| Settings (`shared_preferences`): model, interface, repository | `lib/data/settings/` | done |
| Wired into `AppDependencies.init()` | `lib/core/di/app_dependencies.dart` | done |
| Repository tests (in-memory database) | `test/data/repositories_test.dart` | done |
| ERD diagram (Mermaid) | `project_spec/erd_tenant_tracker.md` | done |

## What each repository offers

| Repository | Operations |
|---|---|
| Tenant | `addTenant(tenant, initialRent)` (tenant + first RentHistory in one transaction), `getTenant`, `watchActiveTenants`, `watchArchivedTenants`, `deleteTenant(uuid, deletedMonth)` (soft delete) |
| RentHistory | `changeRent` (one transaction: upsert history, update that month's record if it exists; no month check), `getHistory`, `getRentForMonth` (greatest `effectiveFromMonth <= month`) |
| RentRecord | `insertMissing` (existing records are left alone), `updateRequiredAmount`, `getRecords`, `watchRecordsOfTenant`, `watchAllRecords` |
| Payment | `addPayment`, `deletePayment` (Undo only), `getPaymentsOfRecord`, `watchPaymentsOfTenant`, `watchAllPayments` |
| Settings | `load`, `setLanguage`, `setShowTips`, `setSeenWelcome` (defaults: `en`, tips on, welcome not seen) |

All one-shot calls return `Future<Result<T>>`. All watch calls return `Stream<Result<T>>`; a stream error is emitted as `Err` and the stream keeps running. Only the repositories catch exceptions.

## What the tests cover

- Add tenant saves the first rent; a bad rent rolls the whole add back; a duplicate uuid is an `Err`, not a thrown exception.
- Soft delete moves a tenant from the active list to the archived list; the list stream re-emits on change.
- Rent for a month picks the latest change at or before it; a second change in the same month replaces the first.
- `insertMissing` never overwrites a snapshot; `updateRequiredAmount` changes one month only.
- Payments are ordered by `paidOn`; per-tenant payments come only from that tenant's records; Undo removes the row.
- Database rules reject bad data: unknown tenant or record (foreign keys), amount 0.
- Settings: defaults and round trip.

## Decisions made while building

- Models are plain classes in `data/<entity>/`. drift's generated row classes are named `...Row` and never leave `data/`.
- `TenantRepository` owns the "tenant + first rent" transaction, because the two inserts must succeed together.
- Validation (trimmed name, amount > 0, `paidOn` not after today, due day range) belongs to the use cases. The database `CHECK` constraints on amounts and due day are a second line of defence only.
- Dates `createdOn` are stored by drift as epoch **seconds**, not milliseconds as `data_model_tenant_tracker.md` says. This is only an audit field, so the doc line can be relaxed to "epoch".
- `changeRent` replaced `setRent` so the history row and that month's record are updated together. It does **not** check which month is changed: that is a business rule (needs today's date) and belongs to the use case. Until that use case exists, nothing stops a caller changing a past month.
- `watchAllRecords` and `watchAllPayments` return every tenant, active and deleted. The use case filters (the home screen needs only active tenants).

## Not part of the data layer (next: domain)

- Generating missing RentRecords from `startMonth` to the current month (stopping at `deletedMonth`), using `RentHistory` for the amount.
- Status calculation (Completed / Late Completed / Backlog Cleared / Pending / Late), due date `min(dueDay, daysInMonth)`.
- Rent change use case: read today from a `Clock` (in the one fixed timezone), reject any month that is not next month (this also protects the first month once its record exists), then call `changeRent`. Tests for these rejections belong with the use case.
- Validation and the Argument/Return models of each use case.

## Open spec questions (still affect the domain, not the tables)

1. First-month proration.
2. Restoring a deleted tenant, and the months skipped while deleted.
3. Warning when deleting a tenant with a backlog.

## Housekeeping

- Regenerate drift code after changing tables: `dart run build_runner build`.
- Changing a table later needs a `schemaVersion` bump and a migration.
- Generated `app_database.g.dart` is committed, like the l10n files.
