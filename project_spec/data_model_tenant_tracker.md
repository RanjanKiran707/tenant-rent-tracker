# Tenant Tracker – Data Model

Reference for the database tables. Rules come from `specs.md`. Storage is drift (SQLite), used only inside `data/`.

## Conventions

- Primary key: `uuid` (String). No separate integer id.
- Money: `int` whole rupees (not `double`; the mockup only accepts whole numbers and floats cause rounding errors).
- Month: text `YYYY-MM`. Calendar date: text `YYYY-MM-DD`. Both are in the one fixed timezone, so there are no timezone surprises.
- `DateTime` (UTC epoch ms in drift) only for audit timestamps such as `createdOn`.
- Status, paid total, balance and old dues are **never stored**. They are computed from RentRecord + Payment + today.
- Nothing is hard-deleted. Deleting a tenant is a soft delete.

## Tables

### Tenant

| Field | Type | Notes |
|---|---|---|
| uuid | String PK | |
| name | String | trimmed, not empty |
| createdOn | DateTime | audit only (when the row was added) |
| dueDay | int | 1-31, default **10**. If a month is shorter, use its last day. Not editable in v1 (changing it would change past statuses). |
| startMonth | String `YYYY-MM` | first month with a record. Differs from createdOn: the user picks it. |
| deletedMonth | String? `YYYY-MM` | null = Active. Set = Deleted (archived). No records generated after this month. |

Changes from the first draft: **`rentAmount` removed** (moves to RentHistory, per the spec rule "never overwrite a rent field that past months depend on"); `startMonth` and `deletedMonth` added.

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
- Overpayment is stored as is; the extra is not carried to the next month (v1).

## Relationships

```
Tenant 1 ──< RentHistory
Tenant 1 ──< RentRecord 1 ──< Payment
```

## Behaviours the model must support

| Spec rule | How |
|---|---|
| Rent change applies from next month | upsert RentHistory at `nextMonth`; if next month's RentRecord already exists, update its `requiredAmount` |
| Past, current and backlog amounts unchanged | RentRecord snapshot, never rewritten except next month |
| Completed vs Late Completed vs Backlog Cleared | walk the month's Payments in `paidOn` order; the date the running total reaches `requiredAmount` is compared with the due date and month end |
| Due date | `min(dueDay, daysInMonth)` of the record's month |
| Delete tenant | set `deletedMonth`; keep all rows; list queries filter `deletedMonth IS NULL` |
| Archived view | `deletedMonth IS NOT NULL`, read-only, opened from the **Archived** tile in Settings |

## Not in the database

- Settings in `shared_preferences`: language, show tips, seen welcome.
- Default due day: constant `10` in `core/`.

## Decisions to verify

1. `rentAmount` replaced by RentHistory + snapshot (chosen).
2. Money as `int`, not `double`.
3. `dueDay` and `startMonth` are fixed after creation in v1.
4. Still open in the spec: first-month proration, restoring a deleted tenant, and the months skipped while deleted.
