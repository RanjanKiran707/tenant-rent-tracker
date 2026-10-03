# Use Case Layer – Progress

Plan: business use cases (`lib/domain/use_cases/business/`) and UI use cases (`lib/domain/use_cases/ui/`). Rules: `../specs.md`. Screens: `../mockup.html`. Data layer: `data_layer_progress.md`.

Decisions: missing monthly records are created by `EnsureRentRecordsUsecase` (a ViewModel calls it, UI use cases never write). "Today" is fixed IST (UTC+5:30) from a `Clock`. The "rent changes from next month only" rule is in `ChangeRentUsecase`.

## Steps

| # | Step | State |
|---|---|---|
| 1 | core: `Clock`, `month_utils`, `Result.map/flatMap`, `combineLatest3`, constants (+ tests) | done |
| 2 | data additions: `getActiveTenants`, `watchHistory` (+ tests) | done |
| 3 | `month_status` (status calculation, + tests) | done |
| 4 | business use cases (+ tests) | done |
| 5 | UI use cases (+ tests) | done |
| 6 | wiring in `AppDependencies`, architecture doc note, final analyze + test run | done |
| 7 | Tenant Groups: group use cases, group-aware Home, `WatchGroupUsecase` (see `groups_progress.md`) | done |
| 8 | Edit a recorded payment: `EditPaymentUsecase`, `PaymentRepository.getPayment/updatePayment`, tappable payment lines on Tenant Detail (branch `feature/edit-payment`) | done, tests written not run |

## Log


### Step 8 – edit a recorded payment (done; tests written, not run by the assistant)
- Only the **amount** and the **date received** can be changed. The month a payment is for, its uuid and `createdOn` stay, so the order of payments received on the same day is kept. No delete button: the immediate Undo is still the only way a payment is removed.
- `EditPaymentUsecase(payments, clock)`: `amount_invalid`, `date_invalid`, `date_in_future` (today is allowed), `payment_not_found`. New data-layer methods `getPayment` and `updatePayment`; the payment streams re-emit, so statuses and balances follow by themselves (Completed can become Partial, Late Completed or Backlog, and a fully paid month moves back from History to the top card).
- Tenant Detail: each payment line is tappable (with a pencil) and opens an "Edit payment" dialog (amount field, date picker up to today). Payment lines are now also listed on the top "this month" card, because a part-paid current month is not in History. Archived tenants stay read-only.
- New string `errPaymentNotFound` and three dialog strings in en and kn (the Kannada was written by the assistant and needs a check). Spec, data model and mockup are updated.
- Tests: use case, repository and view-model tests added; `flutter analyze` is clean.
### Steps 5 and 6 – UI use cases, wiring, docs (done)
- In `lib/domain/use_cases/ui/`: `WatchHomeUsecase`, `WatchTenantDetailUsecase` (active and archived), `WatchArchivedTenantsUsecase`, `LoadPaymentOptionsUsecase`, `LoadRentChangeInfoUsecase`, `LoadAddTenantFormUsecase`, plus `month_status/tenant_dues.dart` (old dues, oldest owing month).
- `LoadAddTenantFormUsecase` has no I/O and cannot fail, so it returns its model directly instead of a `Result` (a change from the plan).
- Added `combineLatest2` to core (built on `combineLatest3`), with a test. The detail screen reads the tenant once when the stream starts, then combines records, payments and rent history.
- A tenant with no record for the current month yet is listed as Pending and adds nothing to the totals, until `EnsureRentRecordsUsecase` runs.
- `LoadPaymentOptionsUsecase` reads payments with `watchPaymentsOfTenant(...).first`; there is no one-shot payment query in the data layer.
- Tests in `test/domain/ui/ui_usecases_test.dart` use the mockup's sample tenants (today 2026-10-12): home order and totals, old dues, re-emit after a payment, delete and rent change, archived read-only detail, payment month options and default, rent change info.
- `AppDependencies` now builds the `SystemClock` and every use case, and exposes use cases only (the repositories are no longer public fields).
- Added section 6.3.1 (business vs UI use cases) to `flutter_arch_general.md`.
- **Final run: `flutter analyze` clean, 161 tests passing** (core 29, data 25, business 42, month_status 31, UI use cases 33, plus the widget test).
- Not done: no ViewModel or screen calls these yet; nothing is committed.

### Step 4 – business use cases (done)
- In `lib/domain/use_cases/business/`: `AddTenantUsecase` (+ argument model), `EnsureRentRecordsUsecase`, `RecordPaymentUsecase` (+ argument model), `UndoPaymentUsecase`, `ChangeRentUsecase`, `DeleteTenantUsecase`, and the settings use cases (`LoadSettings`, `SetLanguage`, `SetShowTips`, `MarkWelcomeSeen`).
- Validation errors are `ValidationFailure` with a code the ViewModel maps to a message: `name_required`, `rent_invalid`, `due_day_invalid`, `start_month_invalid`, `start_month_in_future`, `amount_invalid`, `date_invalid`, `date_in_future`, `tenant_not_found`, `tenant_deleted`, `language_unsupported`.
- `EnsureRentRecordsUsecase` reads each tenant's history once and works out each month's rent in memory, then inserts all missing records in one call.
- `ChangeRentUsecase` always targets next month, so the first month is never changed once it exists.
- Not checked in the use case: that a payment's record exists. The foreign key rejects it and it comes back as `StorageFailure` (tested).
- 42 tests in `test/domain/business/`, using real repositories on an in-memory database and a `FakeClock` (`test/domain/harness.dart`). All pass; `flutter analyze` clean.

### Step 3 – month_status (done)
- `ui/month_status/month_status.dart`: `MonthStatus` (8 states), `computeMonthStatus`, `paidAsOf`, `balanceOf`, `attentionRank` (the mockup's `RANK`, half a step up with old dues).
- 31 tests in `test/domain/ui/month_status_test.dart`: all 8 states, due date and month end inclusive, completed in parts, late completion, backlog cleared, overpayment, payments entered out of order, future-dated payment ignored, due day 31 in short months and a leap February, and the mockup's sample tenants.
- `flutter analyze` clean.

### Step 2 – data additions (done)
- `TenantRepositoryInterface.getActiveTenants()` and `RentHistoryRepositoryInterface.watchHistory(tenantUuid)`, with one test each.
- Full suite: 54 tests passing; `flutter analyze` clean.

### Step 1 – core (done)
- Added `core/constants.dart`, `utils/month_utils.dart`, `utils/clock.dart` (`SystemClock` on IST), `utils/combine_latest.dart`, and `Result.map` / `flatMap`.
- 28 tests in `test/core/`, all passing; `flutter analyze` clean.
- Bug found by the tests: `addMonths` was off by one (Dart months are 1-based), so `addMonths(m, 1)` returned the same month and `monthsBetween` looped forever. That was the cause of the earlier test-run hang. Fixed.
- One test (`combineLatest3` re-emit) assumed an order between events on different controllers; it now waits for each event to land first.
