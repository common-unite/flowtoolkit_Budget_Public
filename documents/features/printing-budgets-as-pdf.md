# Printing Budgets As PDF

Universal Budget ships a **Budget Sheet** Visualforce component that prints a budget the way Spreadsheet mode shows it: one row per category with its subtotals, line items beneath, one column per period, a Total column, and a Total Request row. Totals that break a limit print red, and totals within 10% of a limit print amber, using the same rules as the grid.

The package ships the table, not the page. You drop the component into your own Visualforce page rendered as PDF, so the header, logo, cover text, signatures and orientation are yours.

## A starter page

Create a Visualforce page on your budget object (Budget in Nonprofit Cloud) and add the component:

```html
<apex:page standardController="Budget" renderAs="pdf" showHeader="false" sidebar="false"
           standardStylesheets="false" applyHtmlTag="false" applyBodyTag="false">
    <html>
    <head>
        <style>
            @page {
                size: letter landscape;
                margin: 0.6in 0.4in;
                @top-left { content: "{!JSENCODE(Budget.Name)}"; font-family: Helvetica, sans-serif; font-size: 9px; }
                @bottom-right { content: "Page " counter(page) " of " counter(pages); font-family: Helvetica, sans-serif; font-size: 9px; }
            }
        </style>
    </head>
    <body>
        <FlowToolKit:BudgetSheet recordId="{!Budget.Id}"/>
    </body>
    </html>
</apex:page>
```

Open it at `/apex/YourPageName?id=<budget Id>`, or add it to the budget page layout as a button.

## Ready-made pages

The Nonprofit Cloud bundle installs three pages already built this way, one per printable record:

| Page | Add it to | Prints |
| --- | --- | --- |
| **Budget Print** | Budget | The budget table, under the budget's name and description |
| **Budget Period Print** | Budget Period | The period's reporting sheet, under its title and submitted state |
| **Funding Disbursement Print** | Funding Disbursement | The disbursement's claim sheet, under its name and submitted state |

Use them as they are, or copy one into a page of your own and change it. Add a page to a record page in App Builder with the **Visualforce** component, or pass its name to the Flow Tool Kit **Generate PDF** action to save the sheet as a file on the record. Each page is deliberately plain, so the header, logo and page furniture are yours to add.

## Component attributes

| Attribute | Required | What it does |
| --- | --- | --- |
| `recordId` | Yes | The record to print: a **budget** prints the budget table, a **budget period** prints its reporting sheet, and a **disbursement** prints its claim sheet. Any object mapped in Budget Configuration works. |
| `categoryFilterField` | No | A picklist or text field on the category object that narrows the rows, the same filter as the grid's category filter. |
| `categoryFilterValues` | No | Semicolon-separated values of that field to keep. |
| `primaryColor` | No | Hex color, the same as the grid's Brand Color: category rows and the grand total. |
| `secondaryColor` | No | Hex color, the same as the grid's Complementary Color: the header row and the Total Request row. |
| `showDescriptions` | No | Print each category's description on a band above its rows. Defaults to `true`; set `false` when your descriptions are admin notes rather than text for the reader. |

Leave the colors blank and the sheet prints unthemed, in neutral greys. Brand color is opt-in: a PDF cannot read your org or Experience site brand color the way the grid does, so pass the same hex values you set on the grid when you want them to match. A neutral you pass deliberately stays neutral; a pale but colored brand still darkens to stay readable.

## Styling the table from your page

Apart from the colors and `showDescriptions`, every style (fonts, sizes, spacing, borders, alignment) is yours to override from your page. The table uses stable class names, and a rule in your page's own `<style>` block wins over the component's, so you can reuse the same selector the component uses:

```html
<style>
    .ftk-budget-sheet td { padding: 0.5em 0.8em; }
    .ftk-budget-sheet { font-size: 12px; }
</style>
```

The two colors are the exception. The component writes them as inline styles on the header row, the category rows and the Total Request row, so a stylesheet rule cannot reach them. Pass `primaryColor` and `secondaryColor` instead of fighting them from CSS.

| Class | Element |
| --- | --- |
| `ftk-budget-sheet` | The table |
| `ftk-budget-sheet__category` | A category row |
| `ftk-budget-sheet__line` | A line item row |
| `ftk-budget-sheet__total-request` | The Total Request row |
| `ftk-budget-sheet__label-col` | The first cell of each row |
| `ftk-budget-sheet__total-col` | The Total cell of each row |
| `ftk-budget-sheet__band` | The full-width band above a described category |
| `ftk-budget-sheet__description` | A category's description, beside its name in the band |
| `ftk-budget-sheet__category-figures` | A described category's figures: its Total row, or the row under its band |
| `ftk-budget-sheet_error`, `ftk-budget-sheet_warning` | A total over or near a limit |

With descriptions on, a category that has a description opens with a full-width band: its name and description on one line. If it has line items, they come next and a **Total** row closes the category. Otherwise its figures sit in the row under its band. A category without a description stays a single row, so one table can mix both. Turn descriptions off with `showDescriptions="false"` and every category is a single row:

```html
<FlowToolKit:BudgetSheet recordId="{!Budget.Id}" showDescriptions="false"/>
```

### Fonts and sizes

Every size in the table is relative to the table's own font size, so two rules on your page restyle the whole table:

```css
.ftk-budget-sheet {
    font-family: Times, serif;
    font-size: 12px;
}
```

Visualforce renders PDFs with four fonts only: Helvetica (`sans-serif`), Times (`serif`), Courier (`monospace`) and Arial Unicode MS. Brand or web fonts cannot be embedded. Arial Unicode MS is the one to use for languages outside the Latin alphabet, but it cannot print bold or italic. Plain `Arial` is not one of the four and loses its bold.

## Languages

The table's own text (Category, Total, Total Request, Line item, Amount) comes from Universal Budget's translated labels and prints in the language of the user rendering the page. When a Flow saves the PDF, that is the user the Flow runs as.

Category, period and line item names and descriptions print as the fields mapped in Budget Configuration return them. To print them translated, map a translated picklist (the grid reads picklists in the user's language) or a formula field that returns the text for the user's language.

## Reporting and claim sheets

Point the component at a **budget period** and it prints that period's reporting sheet: Line item, Budgeted, Actual and Variance, with a variance over the budget printed red and one past the budget's variance threshold amber. Point it at a **disbursement** and it prints that disbursement's claim sheet: Line item, Budgeted, Prior claimed, This claim and Remaining, with an over-claimed Remaining in red. On a budget that claims across periods, Budgeted, Prior claimed and Remaining print the claim's period on top and the grant total underneath, each Remaining line red on its own.

Both sheets read exactly like the component on screen:

- Categories marked **Not Fundable** stay off these sheets and out of their totals.
- A category opens with a band; a category with line items closes with a **Total** row.
- A line with nothing reported prints a dash, and a line the sheet cannot report against is shaded.
- The sheet total adds the fundable currency categories, including any the period's dates hide.
- A period with nothing budgeted, a disbursement with nothing to claim against, and a disbursement with no period each print the same short message the component shows.

```html
<apex:page standardController="BudgetPeriod" renderAs="pdf" showHeader="false" sidebar="false"
           standardStylesheets="false" applyHtmlTag="false" applyBodyTag="false">
    <html><body>
        <FlowToolKit:BudgetSheet recordId="{!BudgetPeriod.Id}"/>
    </body></html>
</apex:page>
```

The sheet title, the period dates, the disbursement name and the grant-to-date figures belong to your page, the same way the budget sheet's header does.

## Saving the PDF as a file

The Flow Tool Kit **Generate PDF** action renders any Visualforce page as a file. Pass your page name, the budget Id as the record Id, and a title, and it saves the PDF as a file you can share with the application or award.

## What prints

- Values print in each category's unit, formatted for the locale of the person reading the PDF, like the grid: `$68,000` in English (United States), `68 000 $` in French (Canada). The budget sheet prints whole currency; the reporting and claim sheets print cents, because a claim reconciles against receipts. The symbol's position was checked for most English locales, French, Swedish, Danish, Norwegian, Finnish, Polish, Czech, Slovak, Russian, Hungarian, Romanian, German (Germany, Belgium, Luxembourg), Spanish (Spain, Andorra, Mexico, United States), Italian (Italy) and Portuguese (Portugal). Other locales print the currency code before the digits, for example `BRL 68.000` in Portuguese (Brazil).
- The Total Request row adds Currency categories only, like the grid.
- A figure that has been entered always prints. A period outside the budget's dates is left out only while it holds nothing, like the grid.
- A budget with no periods prints a single Amount column.
- Nothing interactive prints: no icons, help text, editing column or add line item row.
