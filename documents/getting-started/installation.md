# Installation

## Prerequisites

- The free **Flow Tool Kit** base package (the Universal Budget builds on its Form Builder and utilities).
- One of: NPC Grantmaking, Outbound Funds, or your own four-object budget model.

## Install the package

Install the current managed release from the [latest release page](https://github.com/common-unite/flowtoolkit_Budget_Public/releases/latest). Each release lists the sandbox and production install URLs.

For a scripted install (scratch orgs and demos), the public repo ships CumulusCI flows that install the base package, deploy an unpackaged data-model bundle (NPC or Outbound Funds), assign permission sets, and seed demo data. The unpackaged bundles are namespace-tokenized, so deploy them with namespace injection:

```
cci task run deploy -o path unpackaged/config/ofm -o namespace_inject FlowToolKit
```

## Permission sets

Two permission sets ship with the package:

| Permission set | Grants |
| --- | --- |
| **Form (Universal Budget User)** | See and use the grid, enter values, run the Clone Budget action. The baseline for staff and grantees. |
| **Form (Universal Budget Template Manager)** | Everything in User, plus the *Configure Budget Templates* custom permission that reveals structure editing — adding and editing categories and periods. |

The unpackaged data-model bundles add their own tiered permission sets for the objects they deploy (for example the Outbound Funds bundle ships User, Manager, and a guest-safe read-only set). See [Forms, Flow & Experience Cloud](../integrations/forms-flow-and-experience-cloud.md) for the guest scenario.

## Licensing

The Universal Budget is a **paid feature** of the Flow Tool Kit family. It runs fully open in **sandboxes, scratch orgs, and Developer Edition** orgs so you can evaluate it, and requires a purchased entitlement to run in **production**. In an unentitled production org the component shows a purchase-required message instead of the grid. Contact Common-Unite to license it.

## Verify

Open a budget record with the component placed on it. If you see the grid with categories and periods, you're set. If you see a "purchase required" message, the org is a production org without an entitlement (expected). If you see nothing, check that the viewing user has the **Form (Universal Budget User)** permission set and read access to your budget objects.
