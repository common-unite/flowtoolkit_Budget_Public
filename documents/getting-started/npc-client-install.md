# NPC Client Org Runbook

How to install the Universal Budget into a **real Nonprofit Cloud org** - a client sandbox or
production org, not a scratch org.

The difference matters. The `install_npc` flow is a **development** flow: it source-deploys
`force-app` (this package's own code) and seeds demo budget data. Neither belongs in a client org.
Use `install_npc_client`, which installs the released managed package and skips the seed.

## Prerequisites

| Requirement | Notes |
| --- | --- |
| **Grantmaking enabled** | Setup → Grantmaking. The bundle extends the standard `Budget`, `BudgetCategory`, `BudgetPeriod`, and `BudgetCategoryValue` objects - they must exist first. |
| **Flow Tool Kit base package** | Installed automatically as a dependency. |
| **Production entitlement** | The Universal Budget runs open in sandboxes, scratch orgs, and Developer Edition. A **production** org needs a purchased entitlement or the component shows a purchase-required message instead of the grid. |
| **CumulusCI** | `cci org connect <alias>` against the target org. |

## Install

```
cci flow run install_npc_client --org <alias>
```

What it does, in order:

1. **`install_prod_no_config`** - resolves dependencies (Flow Tool Kit base) and installs the
   latest **production** release of Flow Tool Kit: Universal Budget. This installs the managed
   `04t` package; it does not deploy source.
2. **Grantmaking permission set license** for the installing admin (`ignore_failure` - a client
   org usually has this already).
3. **Deploys `unpackaged/config/npc`** - the Budget Configuration record, the grantmaking cap and
   form-name fields, the four Edit forms, the automation and clone flows, the two permission sets,
   and the `budgetFormSectionNPC` wrapper.
4. **Activates the four flows.** Production-grade orgs deploy flows as Draft, so this step is
   required - it is a no-op in a scratch org.
5. **Assigns the four permission sets** to the installing user so you can verify immediately.

### Why `unmanaged: False` matters

Step 3 passes `unmanaged: False`. That single flag decides how the form-section wrapper addresses
the managed grid component:

| Target | Flag | `budgetFormSectionNPC.html` renders |
| --- | --- | --- |
| Namespaced dev/scratch org | `unmanaged: True` | `<c-universal-budget>` |
| **Client (subscriber) org** | `unmanaged: False` | `<FlowToolKit-universal-budget>` |

A subscriber org needs the namespaced tag, because the wrapper deploys into the default namespace
while the component it nests lives in `FlowToolKit`. Getting this backwards produces a wrapper that
renders nothing. The flag does **not** affect `%%%NAMESPACED_ORG%%%`, which keys off a separate
`namespaced_org` flag and correctly resolves to bare field names in a client org.

If you deploy the bundle by hand instead of through the flow, you must pass it explicitly:

```
cci task run deploy --org <alias> \
  -o path unpackaged/config/npc \
  -o namespace_inject FlowToolKit \
  -o unmanaged False
```

A plain `sf project deploy start` will **not** work - it deploys the `%%%…%%%` tokens literally.

## Known constraint: package version vs. bundle

The bundle's clone flow (`IndividualApplication_After_Create_Clone_Template_Budget`) passes a
`budgetTemplate` SObject to `BudgetClone_Invocable` so a cloned budget can be renamed and have
fields overridden before insert.

That parameter must exist in the **installed** package version. If the flow deploy fails with an
invalid-parameter error on `budgetTemplate`, the org is on a release that predates it - install a
newer release, or remove the `T__budgetTemplate` data type mapping from the flow and forgo
template-driven overrides.

## Post-install configuration

1. **Point the budget at its forms.** The grid's add/edit actions are gated on four fields on the
   `Budget` record: `Budget_FormQualifiedApiName__c`, `Category_FormQualifiedApiName__c`,
   `Period_FormQualifiedApiName__c`, `Value_FormQualifiedApiName__c`. The bundle ships defaults, so
   budgets created *after* install pick them up automatically. Budgets that already existed, and
   any created through a path that bypasses defaults, will have them blank - and the add/edit
   buttons stay hidden until they are set.
2. **Place the component.** Add **Universal Budget** to the Budget record page in Lightning App
   Builder.
3. **Assign permission sets to real users.** Step 5 only covers the installing admin.

| Permission set | Who |
| --- | --- |
| Form (Universal Budget User) | Everyone who views a budget |
| Form (Universal Budget NPC User) | Grantees - read the structure, enter amounts and actuals |
| Form (Universal Budget NPC Manager) | Staff who build and maintain budget structure |
| Form (Universal Budget Template Manager) | Grants the *Configure Budget Templates* permission that reveals structure editing |

## Verify

- Open a Budget record with the component placed. The grid renders with categories and periods.
- A user with **NPC Manager** + **Template Manager** sees the footer actions (add category, add
  period).
- A user with **NPC User** can edit amounts and actuals but not structure.
- Create an Individual Application against a Funding Opportunity that has a Budget Template - the
  clone flow should produce a budget on the application.

If the grid is blank where you placed the form-section wrapper, check that the Form Submission's
`Budget_NPC__c` lookup is populated; that lookup is what the wrapper reads.
