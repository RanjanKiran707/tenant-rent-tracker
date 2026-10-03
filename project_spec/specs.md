# Tenant Tracker – Product Specs

## Basics

- Each tenant has a **monthly status** recorded for their rent payment.
- A user can create tenants with a **Name**, **Rent Amount** and **Due Day** (day of month; defaults to 10).
- Each tenant has a **start month**. Monthly records exist for every month from the start month onwards, generated on demand (not dependent on the app being opened on the 1st).

## Tenant States

A tenant is either **Active** or **Deleted**.

- **Active**: shown in the main tenant list. Monthly records are generated and payments can be recorded.
- **Deleted**: the tenant is archived, not erased. All their history (monthly records, payments, rent history) is kept.
- Deleted tenants are hidden from the main list. They are reached from a tile called **Archived** inside Settings, and are read-only there.
- No new monthly records are generated for a Deleted tenant after the month they were deleted.

## Definitions

- **Required amount**: that month's rent only. Unpaid amounts do not roll into the next month; each month's shortfall stays a separate debt on its own month.
- **Due date**: the tenant's due day in that month. If the month is shorter than the due day, use the last day of the month.
- **On/before due date**: inclusive of the due day itself.
- **Month end**: inclusive of the last day of the month.
- All dates use one fixed timezone.
- **Payments** are stored individually with their date (not only as a running total). Completed vs Late Completed depends on the date the total reached the required amount.
- A recorded payment can be corrected later: its **amount** and **date received** can be changed (not the month it is for). The month's status and balance are recomputed, so a correction can change them, for example lowering an amount can turn Completed into Partial, and moving the date past the due day can turn it into Late Completed. A payment cannot be dated after today. Payments of an archived tenant are read-only. A payment is never deleted except by the immediate Undo.

## Monthly States

| State | Condition |
|---|---|
| **Pending** | Due date has not passed AND paid = ₹0 |
| **Completed** | Required amount fully paid on/before due date |
| **Late Completed** | Required amount fully paid after due date but before month end |
| **Partial** | 0 < paid < required AND due date has not passed |
| **Partial Overdue** | 0 < paid < required AND due date has passed AND month has not ended |
| **Overdue** | paid = ₹0 AND due date has passed AND month has not ended |
| **Backlog** | paid < required AND month has ended |
| **Backlog Cleared** | Required amount fully paid after the month has ended |

### Overpayment

If paid > required, the month shows **Completed** (or Late Completed / Backlog Cleared based on timing). The excess is recorded but not carried forward to the next month (v1).

## Rent Increase / Decrease

1. There is an option to increase or decrease a tenant's rent.
2. A change applies **from the next month onwards only**.
3. Past and current months keep their existing required amount. This includes backlog, even after a decrease.
4. Store rent history (rent + effective-from month), or snapshot the required amount on each monthly record. Never overwrite a single rent field that past months depend on.
5. If several changes are made in the same month, the last one wins.
6. If next month's record already exists, it is updated to the new rent.

## Groups

Tenants are organised into **Groups** so a long list stays easy to scan.

1. Every tenant is in exactly one group. The Add Tenant form has a Group field, preselected to the group the user came from (otherwise Uncategorized).
2. **Home shows groups, not tenants.** A group card shows its name, number of tenants, the most urgent status among its tenants, and the money still to receive this month. Groups are sorted by urgency, empty groups last. The "This month" totals at the top still cover every tenant.
3. Tapping a group opens its tenant list (sorted by urgency, as Home was before groups). Tapping a tenant opens Tenant Detail as before.
4. **Uncategorized** is built in. Tenants that existed before groups were introduced are placed there automatically when the app is updated. It cannot be renamed or deleted, and Home lists it only while it has tenants.
5. A user can add a group, rename a group, move a tenant to another group (from Tenant Detail), and delete a group.
6. A group can be deleted only when it has no active tenants. Deleting keeps the record (like deleting a tenant).
7. Group names must not be empty and must be unique (ignoring case) among active groups.
8. Moving a tenant changes only its group. Rent, months and payments are not affected.
9. An archived tenant keeps its group. The Archived list in Settings is not grouped.

## Open Questions

- Is the first month prorated when a tenant joins mid-month?
- Can a Deleted tenant be restored to Active? If so, what happens to the months skipped while deleted?
- Does deleting a tenant with an outstanding backlog need a warning or confirmation?
