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

## Open Questions

- Is the first month prorated when a tenant joins mid-month?
- Can a Deleted tenant be restored to Active? If so, what happens to the months skipped while deleted?
- Does deleting a tenant with an outstanding backlog need a warning or confirmation?
