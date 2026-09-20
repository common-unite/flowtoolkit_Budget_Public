# Claims & Allocation Mode

[Reporting mode](limits-validation-and-reporting.md#reporting-mode-budget-vs-actuals) captures **one actual per cell per period**. That is the right grain when a grantee files one financial report per period, and it stays the default.

It is the wrong grain when money moves in **claims**: a grantee asks for reimbursement several times inside one period, and each request has its own review and payment. **Allocation mode** is built for that. Each claim is a **disbursement** record, each claimed line is an **allocation** row that belongs to both the budget value (the cell) and the disbursement, and the grid opened from a disbursement becomes a **claim sheet**.

<!-- image pending: 53-claim-sheet.png — A claim sheet: Budgeted, This claim, Remaining, with the grant-to-date strip -->

## Two optional roles

Both roles are configuration only, so they work on NPC Grantmaking or on objects you built yourself. Leave them unmapped and nothing changes.

| Role | What you map | What it gives you |
| --- | --- | --- |
| **Disbursement** | The disbursement object, its lookup to the period, its amount, its name, and a "submitted" boolean | The grid opens from a disbursement record (record page, Flow screen, Experience Cloud) and shows that disbursement's period. The package keeps the disbursement's **amount** equal to the lines that produced it. |
| **Allocation** | The allocation object, its lookups to the value, the disbursement and the budget, its amount, quantity and name | The claim sheet: one allocation per value per disbursement, typed straight into the grid or edited through a mapped form. |

Field names are in [Mapping Your Data Model](../configuration/mapping-your-data-model.md#disbursement-fields-optional-role). The bundled **NPC** configuration maps `FundingDisbursement` and `BudgetAllocation`.

## Actuals mode: Direct or Allocation

The mode is a **picklist on the budget** (`Direct` or `Allocation`, mapped through `Budget_Actuals_Mode_Field__c`). Blank means Direct, so every existing budget keeps its behaviour. Because it lives on the budget record, cloning a template copies it, and one budget can still be changed by hand.

| | Direct | Allocation |
| --- | --- | --- |
| The editable figure | **Actual**, on the period sheet; with the disbursement role mapped, also on the sheet opened from a disbursement (same field, two doors) | **This claim**, on the claim sheet only |
| The computed figure | Variance | **Remaining** = Budgeted minus prior claims minus This claim (red when negative) |
| The value's actual field | Written by the grid | Derived by the package: the sum of the value's allocations |
| The disbursement's amount | Derived by the package from the period's actuals, when the period has exactly one disbursement | Derived by the package from the disbursement's allocations |
| The period sheet | Editable | Read-only, every figure derived from claims, header note says so |

Allocation requires the allocation role. A budget set to Allocation under a configuration without that role behaves as Direct, and the sheet header carries an admin-visible note, because a silent fallback would hide a misconfiguration.

## Reading a claim sheet

Every row carries four figures: **Budgeted**, **Prior claimed**, **This claim** (the only editable one), and **Remaining**. **Prior claimed** is the sum of this value's allocations on *other* disbursements. It is scoped to the period the disbursement pays against, like Budgeted and Remaining beside it, so it reads blank when a period carries a single claim and fills once a second claim is filed against the same period. Claims in other periods appear in the grant-to-date strip, not in this column. A category in line-item mode gets a Total row carrying the same four figures; a category with a single row does not, since its Total would repeat it. The sheet's grand total always shows.

- A line is created the first time a non-blank claim is typed; later edits update the same row. Clearing a cell writes zero and keeps the row. The grid never deletes an allocation.
- Quantity-mode lines claim a **quantity**; percent-mode lines cannot be claimed and render read-only.
- The pencil on a cell opens the mapped allocation form, so a grantee can add detail (a description, an attachment) to a line, or create it with the lookups prefilled.
- A category mapped **Requires Receipt** shows an attachment glyph in place of that pencil. It opens the same claim line form, so include the file upload field there and a grantee types the figure and attaches the receipt in one place. It lights once the line holds files.
- Claim a figure on such a line and leave the receipt off, and the icon turns **red** and the sheet raises a grouped advisory naming the lines that owe one. A line budgeted but not yet claimed is not asked for anything.
- The **grant-to-date strip** reads budgeted vs **claimed** across every claim on the budget, and it follows what you type.
- A claim sheet on a period with nothing claimable (every row unbudgeted or percent-only) explains itself: *Nothing in this period can be claimed against.*

## Claiming across periods

By default every figure on a claim sheet belongs to the claim's period. A budget can instead measure each line
across the whole grant: map `Budget_Claim_Across_Periods_Field__c` to a checkbox on the budget (the NPC bundle
ships **Claim Across Periods** and maps it), or to a formula over your own program, stage or template fields.
Blank or unchecked keeps the period scope, so existing budgets do not change.

When it is checked:

- **Budgeted**, **Prior claimed** and **Remaining** each show two lines: the claim's period on top, at the
  usual size, and the grant total below in smaller text. The column headers read *Period / Total*. The grant
  total of Prior claimed is every claim on the line in any period except this disbursement's, and each
  Remaining line is its own Budgeted minus its own Prior claimed minus this claim, so both lines add up on
  their own. Quantity lines sum their quantities; percent lines keep a single period figure and still cannot
  be claimed.
- Each Remaining line turns red on its own. A claim that draws ahead of the period's plan reads red on top and
  fine below, which is exactly what a reviewer checks before approving.
- Category totals and the sheet total stack the same way; the category limit advisory reads the grant totals.
  The reviewer and the grantee see the same numbers; there is no switch on the sheet.
- The claim still has a period, from the disbursement, and the sheet still opens on it. A category shows when
  its own start and end dates cover that period and it holds a value in any period; a line shows when it has a
  value in any period. Dates only limit what the sheet shows: the sheet total always includes every fundable
  category, shown or not, so it agrees with the grant-to-date strip.
- A line with nothing planned in the claim's period can still be claimed. Saving the claim first adds that line
  to the period at zero (same grouping, and the line name on a line-item category), then attaches the claim, so
  every claim stays reportable by period. Nothing is added until a figure is typed, and a second claim reuses
  the value instead of adding another.
- A zero value changes no budget total, so it never raises a budget limit or trips a period minimum.

Change a disbursement's budget period only before it has claim lines. Its existing lines stay on the old period's
values, so the new sheet counts them as neither This claim nor Prior claimed and the grant Remaining reads too high,
while the disbursement's Amount still includes them. Move or clear the lines first.

How the period is chosen stays your decision: your process can pick it for the grantee (the current period,
the disbursement's scheduled period) or let the grantee choose the period in which the expenses occurred.
Drawing ahead is always a reviewer's call; the package warns and never blocks.

## What the package writes, and what it never writes

The sync runs inside the package, in **system mode**, whenever an allocation, a value or a disbursement changes (on NPC through three bundled record-triggered Flows; on your own objects through the same invocable action those Flows call). It writes exactly two things:

- the **value's actual** (Allocation mode: the sum of its allocations), and
- the **disbursement's amount** (Allocation: its allocations; Direct: the period's actuals, only when the period has a single disbursement).

It never writes the disbursement's status or anything else about payment, never creates a disbursement, and never rolls values up to the budget's own amount. Creating disbursements, submitting, approving and paying stay in your org's workflow (a Flow, an approval, a button). A late-created disbursement catches up: the package fills its amount on insert.

Only **fundable** categories reach a disbursement amount. Mark the exceptions (a match, other funding sources) with the mapped **Not Fundable** flag; they stay on the authoring grid and leave the reporting and claim sheets.

To *show* fewer categories on one screen without taking them out of the money, for example an advance screen next to a reimbursement screen, use the screen's **category filter** instead; see [Filtering categories per screen](../integrations/forms-flow-and-experience-cloud.md#filtering-categories-per-screen).

**Every allocation counts.** There is no "included" flag. A claim that is cancelled or returned is cleared by your own Flow on the disbursement, minutes of admin work, and the sync follows.

## Locks and warnings

- The mapped **submitted** boolean on the disbursement renders its claim sheet read-only and the server refuses a save. Any boolean works, typically a formula over your own status field (the NPC demo uses `NOT(ISPICKVAL(Status, "Scheduled"))`). The package reads it, never writes it.
- Claiming past the remaining balance **warns, never blocks**: the cell shows the error tone and the Flow violation outputs light up; the save still commits. A hard stop is a validation rule on your allocation object.
- A user without create access on the allocation object sees the cells and gets the denial on save; the sync never runs because nothing was written.

## Switching modes

- **Direct to Allocation**: the next claim overwrites the typed actual of each value it touches; values without a claim keep their typed figure until one appears.
- **Allocation to Direct**: the derived actuals stay as typed figures and the allocations stop counting.
- **Direct with several disbursements on one period**: the package writes no disbursement amount. Direct expects one disbursement per period; advances and claims side by side belong in Allocation mode.
- A direct write to the actual field in Allocation mode (API, data loader, a form) is allowed; the next rollup overwrites it.

## Setting it up on NPC Grantmaking

The bundle in `unpackaged/config/npc` ships the mapping, the fields and the Flows. After the [client install](../getting-started/npc-client-install.md#post-install-configuration):

1. Set **Actuals Mode** to Allocation on the budget template so cloned budgets inherit it.
   Check **Claim Across Periods** there too if grantees should claim against the whole grant; see
   [Claiming across periods](#claiming-across-periods).
2. Create disbursements from your own Flow (for example one open claim per period) with **Budget Period** set; without it the disbursement cannot open the grid.
3. Give grantees **create and edit** on `BudgetAllocation`; the package writes the disbursement amount and the value actual for them.
4. Put the **Funding Disbursements** related list on the Budget Period layout so a period page lists its claims.

Flow screens can read the claim total: see the [Flow screen contract](../integrations/forms-flow-and-experience-cloud.md#flow-screen-contract).
