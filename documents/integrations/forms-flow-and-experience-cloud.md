# Forms, Flow & Experience Cloud

The grid is one surface; these are the ways it connects to the rest of your org — the forms that edit structure, the Flow screen contract, and Experience Cloud for grantees.

## Form-driven structure editing

Every **Edit budget**, **Edit category**, **Edit period**, and per-cell edit opens a Flow Tool Kit **Form Builder** form, not a hard-coded dialog. You build those forms against your budget objects, so you decide exactly which fields an admin edits and how they're laid out.

The forms below are the **defaults** that ship with the NPC and Outbound Funds bundles. They're ordinary Form Builder forms, so you can add, remove, or rearrange any fields — including your own custom fields — per object and per budget.

![The default Add Category form](../screenshots/33-category-edit-form.png)

![The default Add Period form](../screenshots/33-period-edit-form.png)

Because the forms are configured, not coded:

- A budget form can expose overall minimum, maximum, start date, and end date.
- A category form can expose name, description, icon, mode, limits, and date range.
- **Different budgets can use different forms.** The configuration maps a default form per object, and a field on the budget can override it — so a capital budget and a program budget can each offer a tailored edit experience. See [Mapping Your Data Model](../configuration/mapping-your-data-model.md#edit-forms).

Structure editing (adding and editing categories and periods) is gated by the **Configure Budget Templates** custom permission, which comes with the *Form (Universal Budget Template Manager)* permission set. Users without it still enter values — they just don't see the structure controls. **Edit budget is not gated**, by design: it opens your budget form, so whoever works the budget can complete its own fields (notes, narrative, contacts) while the structure stays fixed. Control that by choosing which fields the budget form exposes.

## Flow screen contract

Drop the component onto a **Flow screen** and it participates in the flow:

- **Record Id** (input) — the budget, a period record to open reporting mode, or a disbursement record to open the sheet for its period (the claim sheet on an Allocation-mode budget). Bind a record variable's Id.
- **Has Violations** (output) — true while any limit is exceeded.
- **Violation Count** (output) — how many limits are exceeded.
- **Claim Total** (output) — the grand *This claim* total of an open claim sheet, fundable currency lines only, blank outside a claim sheet. It is a **text** value because Flow screen outputs have no decimal type; convert it in a formula: `IF(ISBLANK({!Budget.claimTotal}), 0, VALUE({!Budget.claimTotal}))`.

Use the outputs to gate navigation — for example, keep a grantee on the budget screen until **Has Violations** is false, so an application can't be submitted over budget — or show the running claim total on the submit screen of a claim Flow.

<!-- image pending: 33-flow-screen-props.png — The Flow screen component with recordId input and violation outputs -->

You can also set **brand** and **complementary** colors on the component to match your flow or site.

### Filtering categories per screen

Two more inputs, **Category Filter Field** and **Category Filter Values**, hide categories on one screen without changing what the package counts. Pick a picklist or text field on your category object (a *Payment Type* with *Advance* and *Reimbursable*, say) and choose the values to keep, and the screen shows only those categories. A multi-select picklist keeps a category when any of its selected values is among the chosen ones; a text field matches exactly. This is how one budget can offer an advance screen and a reimbursement screen.

In Flow Builder the component's property editor does the picking for you: the field list comes from the category object your Budget Configuration maps, and the values are that field's active values, shown as checkboxes once a picklist is chosen. Choose a text field and the values input becomes a text box instead: type the values separated by semicolons. Bind the values to a Flow variable instead (the disbursement's own type, for example) and one screen serves both payment types. On a record page the same two properties are typed as text: the field API name, and the values separated by semicolons. On an Experience Cloud page the same property editor opens from the component's **Configure Budget Properties** setting, minus the Flow-variable bindings.

What the filter never does:

- **It never changes the money.** Value actuals, disbursement amounts, *Prior claimed* and *Remaining* are derived on the server from every record, so an advance sheet and a reimbursement sheet on the same period still share one *Remaining*. To take a category out of the totals, use **Not Fundable** instead.
- **Blank means everything.** No field, or a field with nothing ticked, shows every category exactly as before.
- **Violations follow the rows on screen.** The **Has Violations** and **Violation Count** outputs and the grant-to-date strip reflect the visible categories only. A submit Flow that needs the whole budget's state runs an unfiltered screen or reads the stamped violation fields.

## Experience Cloud

The component runs in Experience Cloud sites, so grantees can view and work their budget in a portal.

- On a record page, it binds `{!recordId}` from the page automatically. On a standalone page, set the Record Id to a specific budget.
- **Grantees** (portal members) see a focused grid: no **Add category**, **Add period**, **Edit category** or **Edit period** controls, because those are gated by the manage permission. They can still enter amounts and add detail to line items, and **Edit budget** stays available to them on purpose, so a grantee can fill in the budget's own fields, notes and narrative through your budget form without touching the structure. Put only the fields you want a grantee to edit on that form.
- **Configure Budget Properties** opens the same property editor Flow Builder uses: pick the category filter field and values, and set the brand and complementary colors. Leave the colors blank to inherit the site's brand.
- On an Allocation-mode budget, portal grantees work their **claim sheet** from a disbursement page or a Flow: give them create and edit on the allocation object, nothing more. The package writes the disbursement amount and the value actual for them.

### Guest interactive preview

On a **public (guest) page**, the grid becomes an interactive **preview**. A guest can change values and add, rename, clone, or delete line items, and the grid responds live — but nothing is written to the database. Salesforce never lets guest users update records, so rather than a dead read-only grid, a public visitor gets the real editing feel; edits simply reset on refresh.

<!-- image pending: 33-guest-preview-demo.gif — The guest interactive preview on a public site -->

Reporting and claim sheets follow the same rule for guests: the figures render, typed edits stay local, nothing is written.

> **Try it yourself:** [Facility Expansion Budget Template](https://common-unite.my.site.com/s/budget/a0tRQ00000YpZ3PYAV/facility-expansion-budget-template) — change values and add line items as a guest; your edits reset on refresh.

Enabling a guest to *view* budgets also requires giving the site's guest user read access and Apex class access via the guest permission set, plus a guest sharing rule on the budget object. The bundled Outbound Funds guest permission set includes the class access; the sharing rule is org-specific.
