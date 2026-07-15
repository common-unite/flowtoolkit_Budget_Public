# Flow Tool Kit: Universal Budget

A configurable budget grid for Salesforce, built on the [Flow Tool Kit](https://github.com/common-unite/Flow_Tool_Kit_Public)
form framework. One Lightning web component renders an editable budget matrix -
categories as rows, periods as columns, line items, live limit validation, and a
budget-vs-actuals reporting mode - against **any** data model an admin maps
through a `Budget_Configuration__mdt` record.

## What it does

- **Compact and spreadsheet views** of a multi-period budget, with per-category
  line items, a period window scroller, and inline editing
- **Three value modes** per category: currency, quantity, and percent (hard
  100% cap per row)
- **Live limit validation**: category/period/budget minimums, maximums, and
  percentage caps, surfaced as advisory chips and a requirements checklist -
  saving is never blocked
- **Reporting mode**: point the component at a budget *period* record and
  grantees enter actuals against budgeted amounts, with variance thresholds,
  cumulative grant-to-date totals, and submitted-period locking
- **Template cloning**: a global invocable action deep-clones a template budget
  (categories, periods, values) - wire it to record-triggered flows to stamp a
  fresh budget on every new application
- **Form-driven editing**: create/edit budgets, categories, periods, and line
  items through Flow Tool Kit forms, configurable per org and per budget
- **Experience Cloud ready**: works on record pages with a `{!recordId}`
  binding; fully translatable via ~190 Custom Labels

## Two proven data models

| | NPC Grantmaking | Outbound Funds |
|---|---|---|
| Budget | `Budget` (standard) | `Budget__c` (bundle) |
| Rows / columns / cells | `BudgetCategory` / `BudgetPeriod` / `BudgetCategoryValue` | `Budget_Category__c` / `Budget_Period__c` / `Budget_Value__c` (master-detail tree) |
| Application | `IndividualApplication.BudgetId` | `outfunds__Funding_Request__c.Budget__c` (bundle field) |
| Template source | `FundingOpportunity.BudgetTemplateId` | `outfunds__Funding_Program__c.Budget_Template__c` (bundle field) |
| Config bundle | `unpackaged/config/npc` | `unpackaged/config/ofm` |

Any other data model works the same way: map your objects and fields on a
`Budget_Configuration__mdt` record. The component never hardcodes an object.

## Install

1. **Managed package**: install the current release (**0.1.0.1**):
   - Sandbox & scratch orgs: <https://test.salesforce.com/packaging/installPackage.apexp?p0=04tRQ0000009vqHYAQ>
   - Production & Developer Edition: <https://login.salesforce.com/packaging/installPackage.apexp?p0=04tRQ0000009vqHYAQ>
   - Always current: [latest release](https://github.com/common-unite/flowtoolkit_Budget_Public/releases/latest)
2. **Demo/config bundle** (optional): deploy the bundle for your data model
   **with CumulusCI**, which resolves the namespace tokens for your org type:

   ```bash
   cci task run deploy --org <your-org> -o path unpackaged/config/npc -o namespace_inject FlowToolKit
   ```

   The bundles ship the configuration record, demo fields, edit forms,
   permission sets, and (OFM) the full custom budget tree with automation flows.

> The bundles are namespace-tokenized: local references use CumulusCI's
> `%%%NAMESPACED_ORG%%%` token, so identical files deploy with bare API names
> into subscriber orgs and prefixed names into namespaced dev orgs. A plain
> `sf project deploy` will NOT resolve the tokens - use the CumulusCI deploy
> task as shown, or a MetaDeploy plan.

## Permission sets

| Set | Grants |
|---|---|
| Form (Universal Budget User) | packaged - the grid's Apex controller + Clone Budget action |
| Form (Universal Budget Template Manager) | packaged - User plus category/period structure editing |
| Form (Universal Budget NPC User / Manager) | npc bundle - object + field access tiers for the standard Grantmaking model |
| Form (Universal Budget OFM User / Manager / Guest) | ofm bundle - tiers for the custom tree; Guest is read-only and guest-user-legal for public sites |

Record access always follows the org's own sharing model. The component never
writes submitted flags - locking budgets or periods belongs to each org's
workflows.

## Licensing notes

- Internal (funder staff) use needs no Experience Cloud license.
- Grantee self-service (applicants editing budgets / reporting actuals in a
  portal) requires authenticated Experience Cloud member licenses; NPC
  Grantmaking objects can never be shared to guest users.
- Public, read-only budget display is possible on the Outbound Funds model
  (custom objects + the Guest permission set + one guest sharing rule on Budget).

## This repository

The public companion to a private source repo: documentation, project
configuration, and the unpackaged config bundles are mirrored here on every
release, along with the release itself. Issues and feature requests are
welcome here.
