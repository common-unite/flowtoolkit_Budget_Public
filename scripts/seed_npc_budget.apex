// Idempotent NPC demo seed exercising all universalBudget features (line items, date windows, fixed cells, caps).
// Run: sf apex run --file scripts/seed_npc_budget.apex -o flowtoolkit_Budget__npc

String seedBudgetName = 'Riverside Community Garden - 3-Year Grant';
String seedOpportunityName = 'Riverside Community Garden Grants 2026';
String seedEmptyOpportunityName = 'Riverside Expansion Fund 2027';
Set<String> seedOpportunityNameSet = new Set<String>{ seedOpportunityName, seedEmptyOpportunityName };

// clone budgets share the template's name, so this cleanup also collects clones from demo runs
List<Budget> existingBudgets = [SELECT Id FROM Budget WHERE Name = :seedBudgetName];
delete [SELECT Id FROM IndividualApplication WHERE BudgetId IN :existingBudgets OR FundingOpportunity.Name IN :seedOpportunityNameSet];
delete [SELECT Id FROM FundingOpportunity WHERE Name IN :seedOpportunityNameSet];
if (!existingBudgets.isEmpty()) {
    // children first: BudgetCategoryValue blocks cascade deletes through its period lookup
    delete [SELECT Id FROM BudgetCategoryValue WHERE BudgetCategory.BudgetId IN :existingBudgets];
    delete [SELECT Id FROM BudgetPeriod WHERE BudgetId IN :existingBudgets];
    delete [SELECT Id FROM BudgetCategory WHERE BudgetId IN :existingBudgets];
    delete existingBudgets;
}

Budget budget = new Budget(
    Name = seedBudgetName,
    Amount = 250000,
    PeriodStartDate = Date.newInstance(2026, 1, 1),
    PeriodEndDate = Date.newInstance(2028, 12, 31),
    Description = 'Three-year grant to establish and sustain the Riverside community garden program.',
    FlowToolKit__Minimum_Amount__c = 50000,
    FlowToolKit__Maximum_Amount__c = 250000,
    FlowToolKit__Requested_Amount__c = 240000,
    FlowToolKit__Variance_Threshold__c = 10,
    FlowToolKit__Budget_FormQualifiedApiName__c = 'FlowToolKit__Budget_Edit',
    FlowToolKit__Category_FormQualifiedApiName__c = 'FlowToolKit__Category_Edit',
    FlowToolKit__Period_FormQualifiedApiName__c = 'FlowToolKit__Period_Edit',
    FlowToolKit__Value_FormQualifiedApiName__c = 'FlowToolKit__Value_Edit'
);
insert budget;

List<BudgetPeriod> budgetPeriods = new List<BudgetPeriod>{
    new BudgetPeriod(
        Name = 'Year 1', BudgetId = budget.Id, SequenceNumber = 1,
        PeriodStartDate = Date.newInstance(2026, 1, 1), PeriodEndDate = Date.newInstance(2026, 12, 31),
        FlowToolKit__Description__c = 'Startup: site preparation, hiring, initial equipment.',
        FlowToolKit__Maximum_Funding_Amount__c = 110000
    ),
    new BudgetPeriod(
        Name = 'Year 2', BudgetId = budget.Id, SequenceNumber = 2,
        PeriodStartDate = Date.newInstance(2027, 1, 1), PeriodEndDate = Date.newInstance(2027, 12, 31),
        FlowToolKit__Description__c = 'Full program operations.',
        FlowToolKit__Maximum_Funding_Amount__c = 90000,
        FlowToolKit__Minimum_Funding_Amount__c = 20000
    ),
    new BudgetPeriod(
        Name = 'Year 3', BudgetId = budget.Id, SequenceNumber = 3,
        PeriodStartDate = Date.newInstance(2028, 1, 1), PeriodEndDate = Date.newInstance(2028, 12, 31),
        FlowToolKit__Description__c = 'Sustainability transition to community ownership.',
        FlowToolKit__Maximum_Percentage__c = 25
    )
};
insert budgetPeriods;
BudgetPeriod year1 = budgetPeriods[0];
BudgetPeriod year2 = budgetPeriods[1];
BudgetPeriod year3 = budgetPeriods[2];

List<BudgetCategory> budgetCategories = new List<BudgetCategory>{
    new BudgetCategory(
        Name = 'Personnel', BudgetId = budget.Id, SequenceNumber = 1,
        Description = 'Program staff salaries and benefits.',
        FlowToolKit__Icon__c = 'utility:people',
        FlowToolKit__Line_Item_Mode__c = true,
        FlowToolKit__Maximum_Funding_Amount__c = 190000
    ),
    new BudgetCategory(
        Name = 'Equipment', BudgetId = budget.Id, SequenceNumber = 2,
        Description = 'Garden infrastructure: irrigation, tool shed, raised beds.',
        FlowToolKit__Icon__c = 'utility:desktop',
        FlowToolKit__Maximum_Percentage__c = 15
    ),
    new BudgetCategory(
        Name = 'Travel', BudgetId = budget.Id, SequenceNumber = 3,
        Description = 'Conference attendance and site visits (mid-Year 1 through Year 2 only).',
        FlowToolKit__Icon__c = 'utility:travel_and_places',
        FlowToolKit__Start_Date__c = Date.newInstance(2026, 7, 1),
        FlowToolKit__End_Date__c = Date.newInstance(2027, 12, 31)
    ),
    new BudgetCategory(
        Name = 'Supplies', BudgetId = budget.Id, SequenceNumber = 4,
        Description = 'Seeds, soil, consumable garden supplies.',
        FlowToolKit__Icon__c = 'utility:cart'
    ),
    new BudgetCategory(
        Name = 'Indirect Costs', BudgetId = budget.Id, SequenceNumber = 5,
        Description = 'Fixed indirect rate per grant agreement (locked).',
        FlowToolKit__Icon__c = 'utility:percent'
    ),
    new BudgetCategory(
        Name = 'Trees Planted', BudgetId = budget.Id, SequenceNumber = 6,
        Description = 'Total trees planted through the program (count goal).',
        FlowToolKit__Icon__c = 'utility:trail',
        FlowToolKit__Mode__c = 'Quantity',
        FlowToolKit__Line_Item_Mode__c = true,
        FlowToolKit__Minimum_Quantity__c = 300,
        FlowToolKit__Maximum_Quantity__c = 500
    ),
    new BudgetCategory(
        Name = 'Program Completion', BudgetId = budget.Id, SequenceNumber = 7,
        Description = 'Share of program milestones completed per year (rows cap at 100%).',
        FlowToolKit__Icon__c = 'utility:percent',
        FlowToolKit__Mode__c = 'Percent'
    )
};
insert budgetCategories;
BudgetCategory personnel = budgetCategories[0];
BudgetCategory equipment = budgetCategories[1];
BudgetCategory travel = budgetCategories[2];
BudgetCategory supplies = budgetCategories[3];
BudgetCategory indirectCosts = budgetCategories[4];
BudgetCategory treesPlanted = budgetCategories[5];
BudgetCategory programCompletion = budgetCategories[6];

List<BudgetCategoryValue> budgetCategoryValues = new List<BudgetCategoryValue>{
    // Personnel line item: Program Director (all three years)
    new BudgetCategoryValue(BudgetCategoryId = personnel.Id, BudgetDivisionId = year1.Id, Amount = 40000,
        ActualAmount = 43000, // Year 1 actuals seeded for reporting mode: an overspend to demo the red variance
        Comments = 'Program Director', FlowToolKit__Grouping_Identifier__c = 'seed-personnel-director'),
    new BudgetCategoryValue(BudgetCategoryId = personnel.Id, BudgetDivisionId = year2.Id, Amount = 41000,
        Comments = 'Program Director', FlowToolKit__Grouping_Identifier__c = 'seed-personnel-director'),
    new BudgetCategoryValue(BudgetCategoryId = personnel.Id, BudgetDivisionId = year3.Id, Amount = 42000,
        Comments = 'Program Director', FlowToolKit__Grouping_Identifier__c = 'seed-personnel-director'),
    // Personnel line item: Garden Coordinator (sparse - no Year 3)
    new BudgetCategoryValue(BudgetCategoryId = personnel.Id, BudgetDivisionId = year1.Id, Amount = 28000,
        ActualAmount = 26500,
        Comments = 'Garden Coordinator', FlowToolKit__Grouping_Identifier__c = 'seed-personnel-coordinator'),
    new BudgetCategoryValue(BudgetCategoryId = personnel.Id, BudgetDivisionId = year2.Id, Amount = 29000,
        Comments = 'Garden Coordinator', FlowToolKit__Grouping_Identifier__c = 'seed-personnel-coordinator'),
    // Equipment: Year 1 only (sparse)
    new BudgetCategoryValue(BudgetCategoryId = equipment.Id, BudgetDivisionId = year1.Id, Amount = 18000,
        Comments = 'Garden Infrastructure', FlowToolKit__Grouping_Identifier__c = 'seed-equipment-infrastructure'),
    // Travel: only within its date window (Year 3 is outside -> no cell)
    new BudgetCategoryValue(BudgetCategoryId = travel.Id, BudgetDivisionId = year1.Id, Amount = 3000,
        Comments = 'Conference Travel', FlowToolKit__Grouping_Identifier__c = 'seed-travel-conference'),
    new BudgetCategoryValue(BudgetCategoryId = travel.Id, BudgetDivisionId = year2.Id, Amount = 4000,
        Comments = 'Conference Travel', FlowToolKit__Grouping_Identifier__c = 'seed-travel-conference'),
    // Supplies: all three years
    new BudgetCategoryValue(BudgetCategoryId = supplies.Id, BudgetDivisionId = year1.Id, Amount = 5000,
        ActualAmount = 5000,
        Comments = 'Garden Supplies', FlowToolKit__Grouping_Identifier__c = 'seed-supplies-general'),
    new BudgetCategoryValue(BudgetCategoryId = supplies.Id, BudgetDivisionId = year2.Id, Amount = 5000,
        Comments = 'Garden Supplies', FlowToolKit__Grouping_Identifier__c = 'seed-supplies-general'),
    new BudgetCategoryValue(BudgetCategoryId = supplies.Id, BudgetDivisionId = year3.Id, Amount = 5000,
        Comments = 'Garden Supplies', FlowToolKit__Grouping_Identifier__c = 'seed-supplies-general'),
    // Indirect Costs: fixed/locked cells
    new BudgetCategoryValue(BudgetCategoryId = indirectCosts.Id, BudgetDivisionId = year1.Id, Amount = 8000,
        Comments = 'Indirect Rate', FlowToolKit__Grouping_Identifier__c = 'seed-indirect-rate',
        FlowToolKit__Fixed__c = true),
    new BudgetCategoryValue(BudgetCategoryId = indirectCosts.Id, BudgetDivisionId = year2.Id, Amount = 7500,
        Comments = 'Indirect Rate', FlowToolKit__Grouping_Identifier__c = 'seed-indirect-rate',
        FlowToolKit__Fixed__c = true),
    new BudgetCategoryValue(BudgetCategoryId = indirectCosts.Id, BudgetDivisionId = year3.Id, Amount = 4500,
        Comments = 'Indirect Rate', FlowToolKit__Grouping_Identifier__c = 'seed-indirect-rate',
        FlowToolKit__Fixed__c = true),
    // Trees Planted (Quantity mode): counts live on the Quantity field
    new BudgetCategoryValue(BudgetCategoryId = treesPlanted.Id, BudgetDivisionId = year1.Id, Quantity = 120,
        ActualQuantity = 110,
        Comments = 'Native Trees', FlowToolKit__Grouping_Identifier__c = 'seed-trees-native'),
    new BudgetCategoryValue(BudgetCategoryId = treesPlanted.Id, BudgetDivisionId = year2.Id, Quantity = 160,
        Comments = 'Native Trees', FlowToolKit__Grouping_Identifier__c = 'seed-trees-native'),
    new BudgetCategoryValue(BudgetCategoryId = treesPlanted.Id, BudgetDivisionId = year3.Id, Quantity = 150,
        Comments = 'Native Trees', FlowToolKit__Grouping_Identifier__c = 'seed-trees-native'),
    // Program Completion (Percent mode): 30 + 30 + 40 = 100 across the periods
    new BudgetCategoryValue(BudgetCategoryId = programCompletion.Id, BudgetDivisionId = year1.Id, FlowToolKit__Percent__c = 30,
        FlowToolKit__ActualPercent__c = 25,
        Comments = 'Milestones', FlowToolKit__Grouping_Identifier__c = 'seed-completion'),
    new BudgetCategoryValue(BudgetCategoryId = programCompletion.Id, BudgetDivisionId = year2.Id, FlowToolKit__Percent__c = 30,
        Comments = 'Milestones', FlowToolKit__Grouping_Identifier__c = 'seed-completion'),
    new BudgetCategoryValue(BudgetCategoryId = programCompletion.Id, BudgetDivisionId = year3.Id, FlowToolKit__Percent__c = 40,
        Comments = 'Milestones', FlowToolKit__Grouping_Identifier__c = 'seed-completion')
};
insert budgetCategoryValues;

// the budget doubles as a template: applications created for this opportunity clone it via the
// IndividualApplication (After Insert -> Clone Template Budget) flow
FundingOpportunity fundingOpportunity = new FundingOpportunity(
    Name = seedOpportunityName,
    BudgetTemplateId = budget.Id
);
// no template on purpose: demos the grid's Start New Budget affordance (#26)
FundingOpportunity emptyOpportunity = new FundingOpportunity(Name = seedEmptyOpportunityName);
insert new List<FundingOpportunity>{ fundingOpportunity, emptyOpportunity };

System.debug('Seeded Budget ' + budget.Id + ' with ' + budgetPeriods.size() + ' periods, '
    + budgetCategories.size() + ' categories, ' + budgetCategoryValues.size() + ' values, and Funding Opportunity ' + fundingOpportunity.Id + '.');
