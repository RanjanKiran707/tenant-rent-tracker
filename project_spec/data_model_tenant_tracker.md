# Tenant Tracker – Data Model

Reference for the database tables. Rules come from `specs.md`. Storage is drift (SQLite), used only inside `data/`. A diagram of the tables is in `erd_tenant_tracker.md`.

## Conventions

- Primary key: `uuid` (String). No separate integer id.
- Money: `int` whole rupees (not `double`; the mockup only accepts whole numbers and floats cause rounding errors).
- Month: text `YYYY-MM`. Calendar date: text `YYYY-MM-DD`. Both are in the one fixed timezone, so there are no timezone surprises.
- `DateTime` (UTC epoch ms in drift) only for audit timestamps such as `createdOn`.
- Status, paid total, balance and old dues are **never stored**. They are computed from RentRecord + Payment + today.
- Nothing is hard-deleted. Deleting a tenant is a soft delete.

## Tables

### TenantGroup (shown to the user as just "Group")

| Field | Type | Notes |
|---|---|---|
| uuid | String PK | the built-in Uncategorized group uses the fixed uuid `uncategorized` (constant `uncategorizedGroupUuid` in `core/`), so a fresh install and the migration agree |
| name | String | trimmed, not empty. Unique among non-deleted groups, ignoring case (checked by the use case) |
| createdOn | DateTime | audit only; groups are listed oldest first |
| deletedMonth | String? `YYYY-MM` | null = active. Set = deleted (soft delete, like Tenant) |

- Every tenant belongs to exactly one group. **Uncategorized** is a real row, so `Tenant.groupUuid` is never null.
- Uncategorized cannot be renamed or deleted. Its stored name is `Uncategorized`; the app shows the translated text (English / Kannada) for that uuid.
- A group can be deleted only when it has **no active tenants**. It is a soft delete because archived tenants still point at it.
- Home shows Uncategorized only while it has tenants. Every other active group is shown, even when empty.

### Tenant

| Field | Type | Notes |
|---|---|---|
| uuid | String PK | |
| groupUuid | String FK -> TenantGroup | not null, default `uncategorized`. Changed only by "Move to group"; rent, records and payments are not touched |
| name | String | trimmed, not empty |
| createdOn | DateTime | audit only (when the row was added) |
| dueDay | int | 1-31, default **10**. If a month is shorter, use its last day. Not editable in v1 (changing it would change past statuses). |
| startMonth | String `YYYY-MM` | first month with a record. Differs from createdOn: the user picks it. |
| deletedMonth | String? `YYYY-MM` | null = Active. Set = Deleted (archived). No records generated after this month. |

Changes from the first draft: **`rentAmount` removed** (moves to RentHistory, per the spec rule "never overwrite a rent field that past months depend on"); `startMonth` and `deletedMonth` added. Later: `groupUuid` added with the Groups feature (schema version 2).

### RentHistory (each rent change)

| Field | Type | Notes |
|---|---|---|
| uuid | String PK | |
| tenantUuid | String FK -> Tenant | |
| effectiveFromMonth | String `YYYY-MM` | |
| amount | int | > 0 |

- Unique `(tenantUuid, effectiveFromMonth)`: a second change in the same month replaces the first (spec: last one wins).
- The first row is created with the tenant: `effectiveFromMonth = startMonth`.
- Rent for month M = the row with the greatest `effectiveFromMonth <= M`.

### RentRecord (one row per tenant per month)

| Field | Type | Notes |
|---|---|---|
| uuid | String PK | |
| tenantUuid | String FK -> Tenant | |
| month | String `YYYY-MM` | |
| requiredAmount | int | snapshot of the rent for that month; never recalculated for past or current months |

- Unique `(tenantUuid, month)`.
- Generated on demand, for every month from `startMonth` to the current month (stopping at `deletedMonth`). Not tied to the app being opened on the 1st.

### Payment (each money-received entry)

| Field | Type | Notes |
|---|---|---|
| uuid | String PK | |
| rentRecordUuid | String FK -> RentRecord | the month it pays for (can be an older month) |
| amount | int | > 0 |
| paidOn | String `YYYY-MM-DD` | the date received; not after today |
| createdOn | DateTime | audit only |

- Undo = delete this row (the only hard delete, used only for the immediate Undo).
- Edit = change `amount` and `paidOn` of an existing row. `rentRecordUuid` (the month it pays for), `uuid` and `createdOn` never change, so the order of payments received on the same day is kept. The same rules apply as when recording: amount above 0, a real date, not after today.
- Overpayment is stored as is; the extra is not carried to the next month (v1).

## Relationships

```
TenantGroup 1 ──< Tenant 1 ──< RentHistory
                  Tenant 1 ──< RentRecord 1 ──< Payment
```

## Behaviours the model must support

| Spec rule | How |
|---|---|
| Rent change applies from next month | `RentHistoryRepository.changeRent(...)`: one transaction that upserts RentHistory at the month and, if that month's RentRecord already exists, updates its `requiredAmount`. The repository does not check the month: the **use case** must pass next month only (it knows today's date) |
| Past, current and backlog amounts unchanged | RentRecord snapshot, never rewritten except next month |
| Correct a payment | `PaymentRepository.updatePayment(uuid, amount, paidOn)` updates those two columns only. Status, balance and old dues are computed, so they follow the edit by themselves. The use case checks the payment exists (`payment_not_found`) and validates amount and date |
| Completed vs Late Completed vs Backlog Cleared | walk the month's Payments in `paidOn` order; the date the running total reaches `requiredAmount` is compared with the due date and month end |
| Due date | `min(dueDay, daysInMonth)` of the record's month |
| Delete tenant | set `deletedMonth`; keep all rows; list queries filter `deletedMonth IS NULL` |
| Archived view | `deletedMonth IS NOT NULL`, read-only, opened from the **Archived** tile in Settings. Stays a flat list (not grouped) in v1 |
| Home shows groups | list active `TenantGroup` rows (`deletedMonth IS NULL`); each card is computed from that group's active tenants: count, most urgent status, money still to receive. The totals at the top of Home still cover every tenant |
| Group screen | the active tenants whose `groupUuid` is that group (the list Home showed before groups) |
| Add tenant | the form picks a group; default = the group the user came from, else Uncategorized. The use case checks the group exists and is not deleted |
| Move tenant | `TenantRepository.setTenantGroup(uuid, groupUuid)`: updates one column. The use case rejects archived tenants and unknown or deleted groups |
| Delete group | soft delete (`deletedMonth`). Rejected for Uncategorized (`group_default_locked`) and when any active tenant is in it (`group_not_empty`) |
| Rename group | name only; rejected for Uncategorized, empty names, and names used by another active group |
| Archived tenant | keeps its `groupUuid`, even if the group is deleted later |

## Migration: schema version 1 -> 2 (Groups)

Users of the first release have tenants with no group. On upgrade:

1. Create the `TenantGroup` table and insert the Uncategorized row (`uuid = 'uncategorized'`).
2. Add `Tenant.groupUuid`, filled with `'uncategorized'` for every existing tenant (archived ones too).

SQLite will not add a NOT NULL column that has a REFERENCES clause while foreign keys are on, so the `tenants` table is rebuilt with drift's `TableMigration` and a column transformer, with foreign keys off for the rebuild and checked afterwards. A fresh install runs `onCreate`: all tables plus the Uncategorized row. No other table changes, so rent records and payments are untouched.

## Not in the database

- Settings in `shared_preferences`: language, show tips, seen welcome.
- Default due day: constant `10` in `core/`.

## Decisions to verify

1. `rentAmount` replaced by RentHistory + snapshot (chosen).
2. Money as `int`, not `double`.
3. `dueDay` and `startMonth` are fixed after creation in v1.
4. Still open in the spec: first-month proration, restoring a deleted tenant, and the months skipped while deleted.
5. Groups: Uncategorized is a real row with a fixed uuid (not a null `groupUuid`); group delete is a soft delete; one group per tenant; the Archived list is not grouped in v1.
