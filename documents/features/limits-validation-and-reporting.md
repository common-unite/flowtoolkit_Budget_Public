# Limits, Validation & Reporting

The grid enforces guardrails as people type and, in reporting mode, tracks actual spend against the plan. Validation is always advisory — it flags problems clearly but never blocks saving, so a grantee is never stuck mid-entry.

## Limits you can set

Limits live at three levels and feed the same validation system:

- **Category** — minimum amount, maximum amount, a **maximum percentage** (the category may not exceed that share of the total budget), and minimum/maximum quantity for quantity-mode categories.
- **Period** — a **maximum funding amount** for everything budgeted in that column.
- **Budget** — an overall requested amount, minimum, and maximum. The overall requested amount typically mirrors the amount on the related grant or request.

Set these on the budget, category, and period edit forms. Leaving a limit blank means "no limit."

## How violations surface

As values change, the grid re-checks every limit:

- A cell or category **at or over** a limit shows a red advisory.
- One **approaching** a limit shows a yellow advisory with the remaining headroom (for example, "$1 left before the maximum").
- The header shows a running count — **"N limits need attention"** — with a **Review issues** button.

![A category over its maximum, with the advisory chip](../screenshots/33-advisory-chips.png)

**Review issues** opens a checklist of every current problem across the whole budget at once — the overall budget over its maximum and its requested amount, a category over its percentage cap, a period over its maximum — so an admin or grantee can see everything to fix in one place.

![The Review issues panel listing every current violation, then drilling into a category](../screenshots/33-review-issues-demo.gif)

You can also click any category to see its start date, end date, and any limits that apply to it, without opening the edit form.

## Requested vs. budgeted

The header contrasts **Requested** (what the grant or request is for) with **Budgeted** (what the categories currently add up to), plus an allocation bar and an over/under indicator. This is the fastest read on whether a budget is balanced.

## Reporting mode (budget vs. actuals)

Point the component at a budget **period** record instead of the whole budget and the grid flips into **reporting mode** — an actuals-entry grid for that period.

> **See it live:** [Year 2 reporting window](https://common-unite.my.site.com/s/budget/a0rRQ00000pF7dPYAS/year-2) — budgeted vs. actual vs. variance on a public demo site.

- Each line item shows **budgeted**, **actual**, and **variance** side by side.
- A cumulative, grant-to-date strip tracks spend across periods.
- Categories over their variance threshold are flagged for review. The threshold is configurable per budget.

![Reporting mode: entering actuals against budgeted amounts, with live variance and grant-to-date totals](../screenshots/33-reporting-actuals-demo.gif)

### Submitted periods lock

When a period is marked submitted, its reporting grid becomes read-only — the component reads the mapped "submitted" flag and never writes it, so *how* a period gets submitted stays in your org's own workflow (a Flow, an approval, a button). Once submitted, actuals for that period are locked from further edits.

![A submitted period, locked read-only](../screenshots/33-submitted-lock.png)
