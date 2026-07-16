# Mapping Your Data Model

The component knows nothing about your objects until a **`Budget_Configuration__mdt`** record tells it which objects and fields are your budget, categories, periods, and values. That one record is what lets the same grid run on NPC Grantmaking, Outbound Funds, or objects you built yourself.

You don't write this from scratch — the bundled **NPC** and **Outbound Funds** configuration records are complete, working examples. Clone one and repoint the fields, or read it to see how a real mapping looks.

![A Budget Configuration record with its field mappings](../screenshots/33-config-record.png)

## The four objects

A budget is four objects in a hierarchy: a **budget** owns **categories** (rows) and **periods** (columns), and each **value** (cell) belongs to a category and, usually, a period.

| Field | Points at |
| --- | --- |
| `Budget_Source_Object__c` | The budget object (the record the grid loads). |
| `Category_Object__c` | The category (row) object. |
| `Period_Object__c` | The period (column) object. |
| `Value_Object__c` | The value (cell) object. |

### Relationships

| Field | The lookup that connects... |
| --- | --- |
| `Category_Budget_Lookup__c` | Category → its budget. |
| `Period_Budget_Lookup__c` | Period → its budget. |
| `Value_Category_Lookup__c` | Value → its category. |
| `Value_Period_Lookup__c` | Value → its period (leave a value periodless for categories-only budgets). |

## Budget fields

| Field | Maps to the budget's... |
| --- | --- |
| `Budget_Name_Field__c` | Name shown in the header. |
| `Budget_Description_Field__c` | Description/subtitle. |
| `Budget_Amount_Field__c` | Total budgeted amount. |
| `Budget_Requested_Amount_Field__c` | Requested amount (usually the grant/request total). |
| `Budget_Min_Field__c` / `Budget_Max_Field__c` | Overall minimum and maximum limits. |
| `Budget_Read_Only_Field__c` | A field (often a formula) that, when true, makes the whole grid read-only. |
| `Budget_Variance_Threshold_Field__c` | Variance threshold percent used in reporting mode. |

## Category fields

| Field | Maps to the category's... |
| --- | --- |
| `Category_Name_Field__c` / `Category_Description_Field__c` | Name and description. |
| `Category_Icon_Field__c` | SLDS icon name. |
| `Category_Sort_Field__c` | Display order (sequence). |
| `Category_Mode_Field__c` | Value mode (currency / quantity / percent). |
| `Category_Line_Item_Mode_Field__c` | Whether the category holds line items. |
| `Category_Min_Field__c` / `Category_Max_Field__c` | Amount limits. |
| `Category_Percentage_Field__c` | Maximum percentage of the total budget. |
| `Category_Min_Quantity_Field__c` / `Category_Max_Quantity_Field__c` | Quantity limits. |
| `Category_Start_Date_Field__c` / `Category_End_Date_Field__c` | Dates that scope which periods the category applies to. |

## Period fields

| Field | Maps to the period's... |
| --- | --- |
| `Period_Name_Field__c` / `Period_Description_Field__c` | Name and description. |
| `Period_Sort_Field__c` | Display order (sequence). |
| `Period_Min_Field__c` / `Period_Max_Field__c` | Funding limits for the period. |
| `Period_Percentage_Field__c` | Maximum percentage for the period. |
| `Period_Start_Date_Field__c` / `Period_End_Date_Field__c` | Period date range. |
| `Period_Submitted_Field__c` | The flag that locks the period in reporting mode (the component reads it, never writes it). |

## Value fields

| Field | Maps to the value's... |
| --- | --- |
| `Value_Amount_Field__c` / `Value_Quantity_Field__c` / `Value_Percent_Field__c` | The planned figure, one per mode. |
| `Value_Actual_Amount_Field__c` / `Value_Actual_Quantity_Field__c` / `Value_Actual_Percent_Field__c` | The actual figure entered in reporting mode. |
| `Value_Name_Field__c` | Line item name. |
| `Value_Grouping_Identifier_Field__c` | Groups the cells of one line item across periods. |
| `Value_Fixed_Field__c` | Marks a cell fixed so split-evenly and fills skip it. |

## Edit forms

Structure editing happens through Flow Tool Kit **forms**, so you control exactly which fields an admin or grantee edits per object — and even per budget.

| Field | Purpose |
| --- | --- |
| `Default_Budget_Form__c` / `Default_Category_Form__c` / `Default_Period_Form__c` / `Default_Value_Form__c` | The org-default edit form for each object. |
| `Edit_Budget_Form_Field__c` / `Edit_Category_Form_Field__c` / `Edit_Period_Form_Field__c` / `Edit_Value_Form_Field__c` | The field *on the budget* that names a form to use instead of the default — so different budgets can offer different edit forms. |

See [Forms, Flow & Experience Cloud](../integrations/forms-flow-and-experience-cloud.md) for building those forms.

## Tips

- Start from a bundled config and change the object and field names rather than building blank.
- A field you leave blank is simply a capability the grid won't show — no maximum field means no maximum limit, no icon field means no category icons.
- `Value_Period_Lookup__c` is the one relationship you can leave off, for categories-only ("periodless") budgets.
