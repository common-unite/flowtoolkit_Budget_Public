// Idempotent OFM demo seed (namespaced-org script). Requests are inserted WITHOUT budgets so the
// active After-Create flow clones each program's template; actuals and locks are layered on after.

Set<String> templateNames = new Set<String>{ 'Facility Expansion Budget Template', 'Youth Program Budget Template' };
Set<String> requestNames = new Set<String>{ 'Riverside Facility Expansion', 'Downtown Learning Center', 'Harbor Food Pantry Expansion', 'Storm Relief Kitchen' };
Set<String> programNames = new Set<String>{ 'Community Facilities Program', 'Youth Education Initiative', 'Rapid Response Microgrants' };

// cleanup, children first (cloned budgets share their template's name; disbursements cascade with requests)
delete [SELECT Id FROM %%%NAMESPACED_ORG%%%Budget_Value__c WHERE %%%NAMESPACED_ORG%%%Category__r.%%%NAMESPACED_ORG%%%Budget__r.Name IN :templateNames];
delete [SELECT Id FROM %%%NAMESPACED_ORG%%%Budget_Category__c WHERE %%%NAMESPACED_ORG%%%Budget__r.Name IN :templateNames];
delete [SELECT Id FROM %%%NAMESPACED_ORG%%%Budget_Period__c WHERE %%%NAMESPACED_ORG%%%Budget__r.Name IN :templateNames];
delete [SELECT Id FROM outfunds__Funding_Request__c WHERE Name IN :requestNames];
delete [SELECT Id FROM %%%NAMESPACED_ORG%%%Budget__c WHERE Name IN :templateNames];
delete [SELECT Id FROM outfunds__Funding_Program__c WHERE Name IN :programNames];

// ---- template A: facilities (currency line items + quantity + currency) ----
%%%NAMESPACED_ORG%%%Budget__c facilityTemplate = new %%%NAMESPACED_ORG%%%Budget__c(
    Name = 'Facility Expansion Budget Template',
    %%%NAMESPACED_ORG%%%Description__c = 'Two-year capital budget: construction, equipment, and staffing for a community facility expansion.',
    %%%NAMESPACED_ORG%%%Requested_Amount__c = 150000,
    %%%NAMESPACED_ORG%%%Minimum_Amount__c = 50000,
    %%%NAMESPACED_ORG%%%Maximum_Amount__c = 200000,
    %%%NAMESPACED_ORG%%%Variance_Threshold__c = 10,
    %%%NAMESPACED_ORG%%%Status__c = 'Planned',
    %%%NAMESPACED_ORG%%%Type__c = 'Program',
    %%%NAMESPACED_ORG%%%Start_Date__c = Date.newInstance(2026, 1, 1),
    %%%NAMESPACED_ORG%%%End_Date__c = Date.newInstance(2027, 12, 31));

// ---- template B: youth program (currency line items + quantity + percent, three quarters) ----
%%%NAMESPACED_ORG%%%Budget__c youthTemplate = new %%%NAMESPACED_ORG%%%Budget__c(
    Name = 'Youth Program Budget Template',
    %%%NAMESPACED_ORG%%%Description__c = 'Three-quarter program budget: instruction, learning materials, and outreach allocation.',
    %%%NAMESPACED_ORG%%%Requested_Amount__c = 90000,
    %%%NAMESPACED_ORG%%%Variance_Threshold__c = 15,
    %%%NAMESPACED_ORG%%%Status__c = 'Planned',
    %%%NAMESPACED_ORG%%%Type__c = 'Program',
    %%%NAMESPACED_ORG%%%Start_Date__c = Date.newInstance(2026, 1, 1),
    %%%NAMESPACED_ORG%%%End_Date__c = Date.newInstance(2026, 9, 30));
insert new List<%%%NAMESPACED_ORG%%%Budget__c>{ facilityTemplate, youthTemplate };

List<%%%NAMESPACED_ORG%%%Budget_Period__c> periods = new List<%%%NAMESPACED_ORG%%%Budget_Period__c>{
    new %%%NAMESPACED_ORG%%%Budget_Period__c(Name = 'Year 1', %%%NAMESPACED_ORG%%%Budget__c = facilityTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 1,
        %%%NAMESPACED_ORG%%%Start_Date__c = Date.newInstance(2026, 1, 1), %%%NAMESPACED_ORG%%%End_Date__c = Date.newInstance(2026, 12, 31),
        %%%NAMESPACED_ORG%%%Maximum_Funding_Amount__c = 100000, %%%NAMESPACED_ORG%%%Description__c = 'Construction year: site work and the building shell.'),
    new %%%NAMESPACED_ORG%%%Budget_Period__c(Name = 'Year 2', %%%NAMESPACED_ORG%%%Budget__c = facilityTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 2,
        %%%NAMESPACED_ORG%%%Start_Date__c = Date.newInstance(2027, 1, 1), %%%NAMESPACED_ORG%%%End_Date__c = Date.newInstance(2027, 12, 31),
        %%%NAMESPACED_ORG%%%Description__c = 'Fit-out year: equipment and program launch.'),
    new %%%NAMESPACED_ORG%%%Budget_Period__c(Name = 'Quarter 1', %%%NAMESPACED_ORG%%%Budget__c = youthTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 1,
        %%%NAMESPACED_ORG%%%Start_Date__c = Date.newInstance(2026, 1, 1), %%%NAMESPACED_ORG%%%End_Date__c = Date.newInstance(2026, 3, 31)),
    new %%%NAMESPACED_ORG%%%Budget_Period__c(Name = 'Quarter 2', %%%NAMESPACED_ORG%%%Budget__c = youthTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 2,
        %%%NAMESPACED_ORG%%%Start_Date__c = Date.newInstance(2026, 4, 1), %%%NAMESPACED_ORG%%%End_Date__c = Date.newInstance(2026, 6, 30)),
    new %%%NAMESPACED_ORG%%%Budget_Period__c(Name = 'Quarter 3', %%%NAMESPACED_ORG%%%Budget__c = youthTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 3,
        %%%NAMESPACED_ORG%%%Start_Date__c = Date.newInstance(2026, 7, 1), %%%NAMESPACED_ORG%%%End_Date__c = Date.newInstance(2026, 9, 30))
};
insert periods;

List<%%%NAMESPACED_ORG%%%Budget_Category__c> categories = new List<%%%NAMESPACED_ORG%%%Budget_Category__c>{
    new %%%NAMESPACED_ORG%%%Budget_Category__c(Name = 'Construction', %%%NAMESPACED_ORG%%%Budget__c = facilityTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 1,
        %%%NAMESPACED_ORG%%%Line_Item_Mode__c = true, %%%NAMESPACED_ORG%%%Maximum_Amount__c = 120000, %%%NAMESPACED_ORG%%%Icon__c = 'utility:home',
        %%%NAMESPACED_ORG%%%Description__c = 'Site preparation and construction of the new wing.'),
    new %%%NAMESPACED_ORG%%%Budget_Category__c(Name = 'Equipment', %%%NAMESPACED_ORG%%%Budget__c = facilityTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 2,
        %%%NAMESPACED_ORG%%%Mode__c = 'Quantity', %%%NAMESPACED_ORG%%%Maximum_Quantity__c = 50, %%%NAMESPACED_ORG%%%Icon__c = 'utility:desktop',
        %%%NAMESPACED_ORG%%%Description__c = 'Furniture and technology units for the new wing.'),
    new %%%NAMESPACED_ORG%%%Budget_Category__c(Name = 'Staffing', %%%NAMESPACED_ORG%%%Budget__c = facilityTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 3,
        %%%NAMESPACED_ORG%%%Icon__c = 'utility:people', %%%NAMESPACED_ORG%%%Description__c = 'Program staff for the expanded facility.'),
    new %%%NAMESPACED_ORG%%%Budget_Category__c(Name = 'Instruction', %%%NAMESPACED_ORG%%%Budget__c = youthTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 1,
        %%%NAMESPACED_ORG%%%Line_Item_Mode__c = true, %%%NAMESPACED_ORG%%%Minimum_Amount__c = 20000, %%%NAMESPACED_ORG%%%Icon__c = 'utility:knowledge_base',
        %%%NAMESPACED_ORG%%%Description__c = 'Lead instructor and teaching assistants.'),
    new %%%NAMESPACED_ORG%%%Budget_Category__c(Name = 'Learning Materials', %%%NAMESPACED_ORG%%%Budget__c = youthTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 2,
        %%%NAMESPACED_ORG%%%Mode__c = 'Quantity', %%%NAMESPACED_ORG%%%Maximum_Quantity__c = 500, %%%NAMESPACED_ORG%%%Icon__c = 'utility:education',
        %%%NAMESPACED_ORG%%%Description__c = 'Workbooks, kits, and supplies per student.'),
    new %%%NAMESPACED_ORG%%%Budget_Category__c(Name = 'Outreach Allocation', %%%NAMESPACED_ORG%%%Budget__c = youthTemplate.Id, %%%NAMESPACED_ORG%%%Sequence__c = 3,
        %%%NAMESPACED_ORG%%%Mode__c = 'Percent', %%%NAMESPACED_ORG%%%Icon__c = 'utility:broadcast',
        %%%NAMESPACED_ORG%%%Description__c = 'Share of staff time allocated to community outreach, per quarter.')
};
insert categories;
%%%NAMESPACED_ORG%%%Budget_Category__c construction = categories[0];
%%%NAMESPACED_ORG%%%Budget_Category__c equipment = categories[1];
%%%NAMESPACED_ORG%%%Budget_Category__c staffing = categories[2];
%%%NAMESPACED_ORG%%%Budget_Category__c instruction = categories[3];
%%%NAMESPACED_ORG%%%Budget_Category__c materials = categories[4];
%%%NAMESPACED_ORG%%%Budget_Category__c outreach = categories[5];
%%%NAMESPACED_ORG%%%Budget_Period__c year1 = periods[0];
%%%NAMESPACED_ORG%%%Budget_Period__c year2 = periods[1];
%%%NAMESPACED_ORG%%%Budget_Period__c quarter1 = periods[2];
%%%NAMESPACED_ORG%%%Budget_Period__c quarter2 = periods[3];
%%%NAMESPACED_ORG%%%Budget_Period__c quarter3 = periods[4];

List<%%%NAMESPACED_ORG%%%Budget_Value__c> budgetValues = new List<%%%NAMESPACED_ORG%%%Budget_Value__c>{
    // facilities template
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = construction.Id, %%%NAMESPACED_ORG%%%Period__c = year1.Id,
        %%%NAMESPACED_ORG%%%Amount__c = 40000, %%%NAMESPACED_ORG%%%Comments__c = 'Site preparation', %%%NAMESPACED_ORG%%%Grouping_Identifier__c = 'fac-con-1'),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = construction.Id, %%%NAMESPACED_ORG%%%Period__c = year1.Id,
        %%%NAMESPACED_ORG%%%Amount__c = 55000, %%%NAMESPACED_ORG%%%Comments__c = 'New wing build', %%%NAMESPACED_ORG%%%Grouping_Identifier__c = 'fac-con-2'),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = construction.Id, %%%NAMESPACED_ORG%%%Period__c = year2.Id,
        %%%NAMESPACED_ORG%%%Amount__c = 20000, %%%NAMESPACED_ORG%%%Comments__c = 'New wing build', %%%NAMESPACED_ORG%%%Grouping_Identifier__c = 'fac-con-2'),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = equipment.Id, %%%NAMESPACED_ORG%%%Period__c = year1.Id, %%%NAMESPACED_ORG%%%Quantity__c = 30),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = equipment.Id, %%%NAMESPACED_ORG%%%Period__c = year2.Id, %%%NAMESPACED_ORG%%%Quantity__c = 10),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = staffing.Id, %%%NAMESPACED_ORG%%%Period__c = year1.Id, %%%NAMESPACED_ORG%%%Amount__c = 25000),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = staffing.Id, %%%NAMESPACED_ORG%%%Period__c = year2.Id, %%%NAMESPACED_ORG%%%Amount__c = 25000),
    // youth template
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = instruction.Id, %%%NAMESPACED_ORG%%%Period__c = quarter1.Id,
        %%%NAMESPACED_ORG%%%Amount__c = 8000, %%%NAMESPACED_ORG%%%Comments__c = 'Lead instructor', %%%NAMESPACED_ORG%%%Grouping_Identifier__c = 'yth-ins-1'),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = instruction.Id, %%%NAMESPACED_ORG%%%Period__c = quarter2.Id,
        %%%NAMESPACED_ORG%%%Amount__c = 8000, %%%NAMESPACED_ORG%%%Comments__c = 'Lead instructor', %%%NAMESPACED_ORG%%%Grouping_Identifier__c = 'yth-ins-1'),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = instruction.Id, %%%NAMESPACED_ORG%%%Period__c = quarter3.Id,
        %%%NAMESPACED_ORG%%%Amount__c = 8000, %%%NAMESPACED_ORG%%%Comments__c = 'Lead instructor', %%%NAMESPACED_ORG%%%Grouping_Identifier__c = 'yth-ins-1'),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = instruction.Id, %%%NAMESPACED_ORG%%%Period__c = quarter1.Id,
        %%%NAMESPACED_ORG%%%Amount__c = 4000, %%%NAMESPACED_ORG%%%Comments__c = 'Teaching assistants', %%%NAMESPACED_ORG%%%Grouping_Identifier__c = 'yth-ins-2'),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = instruction.Id, %%%NAMESPACED_ORG%%%Period__c = quarter2.Id,
        %%%NAMESPACED_ORG%%%Amount__c = 4000, %%%NAMESPACED_ORG%%%Comments__c = 'Teaching assistants', %%%NAMESPACED_ORG%%%Grouping_Identifier__c = 'yth-ins-2'),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = instruction.Id, %%%NAMESPACED_ORG%%%Period__c = quarter3.Id,
        %%%NAMESPACED_ORG%%%Amount__c = 4000, %%%NAMESPACED_ORG%%%Comments__c = 'Teaching assistants', %%%NAMESPACED_ORG%%%Grouping_Identifier__c = 'yth-ins-2'),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = materials.Id, %%%NAMESPACED_ORG%%%Period__c = quarter1.Id, %%%NAMESPACED_ORG%%%Quantity__c = 150),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = materials.Id, %%%NAMESPACED_ORG%%%Period__c = quarter2.Id, %%%NAMESPACED_ORG%%%Quantity__c = 150),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = materials.Id, %%%NAMESPACED_ORG%%%Period__c = quarter3.Id, %%%NAMESPACED_ORG%%%Quantity__c = 100),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = outreach.Id, %%%NAMESPACED_ORG%%%Period__c = quarter1.Id, %%%NAMESPACED_ORG%%%Percent__c = 20),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = outreach.Id, %%%NAMESPACED_ORG%%%Period__c = quarter2.Id, %%%NAMESPACED_ORG%%%Percent__c = 30),
    new %%%NAMESPACED_ORG%%%Budget_Value__c(%%%NAMESPACED_ORG%%%Category__c = outreach.Id, %%%NAMESPACED_ORG%%%Period__c = quarter3.Id, %%%NAMESPACED_ORG%%%Percent__c = 25)
};
insert budgetValues;

// ---- programs (templates wired; Microgrants has none -> Start New Budget demo) ----
outfunds__Funding_Program__c facilitiesProgram = new outfunds__Funding_Program__c(
    Name = 'Community Facilities Program', outfunds__Status__c = 'In progress',
    outfunds__Start_Date__c = Date.newInstance(2026, 1, 1), outfunds__End_Date__c = Date.newInstance(2027, 12, 31),
    outfunds__Description__c = 'Capital grants for community facility construction and improvement.',
    %%%NAMESPACED_ORG%%%Budget_Template__c = facilityTemplate.Id);
outfunds__Funding_Program__c youthProgram = new outfunds__Funding_Program__c(
    Name = 'Youth Education Initiative', outfunds__Status__c = 'In progress',
    outfunds__Start_Date__c = Date.newInstance(2026, 1, 1), outfunds__End_Date__c = Date.newInstance(2026, 12, 31),
    outfunds__Description__c = 'Program grants for after-school and summer learning.',
    %%%NAMESPACED_ORG%%%Budget_Template__c = youthTemplate.Id);
outfunds__Funding_Program__c micrograntsProgram = new outfunds__Funding_Program__c(
    Name = 'Rapid Response Microgrants', outfunds__Status__c = 'In progress',
    outfunds__Start_Date__c = Date.newInstance(2026, 1, 1), outfunds__End_Date__c = Date.newInstance(2026, 12, 31),
    outfunds__Description__c = 'Small, fast-turnaround grants; budgets are built per request.');
insert new List<outfunds__Funding_Program__c>{ facilitiesProgram, youthProgram, micrograntsProgram };

// ---- requests (no budget set: the After-Create flow clones and stamps) ----
List<outfunds__Funding_Request__c> requests = new List<outfunds__Funding_Request__c>{
    new outfunds__Funding_Request__c(Name = 'Riverside Facility Expansion', outfunds__FundingProgram__c = facilitiesProgram.Id,
        outfunds__Status__c = 'In progress', outfunds__Requested_Amount__c = 150000,
        outfunds__Requested_For__c = 'Capital grant to expand the Riverside community facility and equip the new wing.',
        outfunds__Term_Start_Date__c = Date.newInstance(2026, 1, 1), outfunds__Term_End_Date__c = Date.newInstance(2027, 12, 31)),
    new outfunds__Funding_Request__c(Name = 'Downtown Learning Center', outfunds__FundingProgram__c = youthProgram.Id,
        outfunds__Status__c = 'Awarded', outfunds__Requested_Amount__c = 90000, outfunds__Awarded_Amount__c = 90000,
        outfunds__Awarded_Date__c = Date.newInstance(2025, 12, 15),
        outfunds__Requested_For__c = 'After-school tutoring and enrichment for 150 students downtown.',
        outfunds__Term_Start_Date__c = Date.newInstance(2026, 1, 1), outfunds__Term_End_Date__c = Date.newInstance(2026, 9, 30)),
    new outfunds__Funding_Request__c(Name = 'Harbor Food Pantry Expansion', outfunds__FundingProgram__c = facilitiesProgram.Id,
        outfunds__Status__c = 'Awarded', outfunds__Requested_Amount__c = 140000, outfunds__Awarded_Amount__c = 140000,
        outfunds__Awarded_Date__c = Date.newInstance(2025, 11, 1),
        outfunds__Requested_For__c = 'Cold storage and distribution space expansion for the Harbor food pantry.',
        outfunds__Term_Start_Date__c = Date.newInstance(2026, 1, 1), outfunds__Term_End_Date__c = Date.newInstance(2027, 6, 30)),
    new outfunds__Funding_Request__c(Name = 'Storm Relief Kitchen', outfunds__FundingProgram__c = micrograntsProgram.Id,
        outfunds__Status__c = 'In progress', outfunds__Requested_Amount__c = 7500,
        outfunds__Requested_For__c = 'Emergency community kitchen operations after the spring storms.')
};
insert requests;

// ---- layer demo state onto the cloned budgets ----
requests = [SELECT Id, Name, %%%NAMESPACED_ORG%%%Budget__c FROM outfunds__Funding_Request__c WHERE Name IN :requestNames];
Map<String, Id> budgetIdByRequest = new Map<String, Id>();
for (outfunds__Funding_Request__c request : requests) budgetIdByRequest.put(request.Name, request.%%%NAMESPACED_ORG%%%Budget__c);

Id riversideBudgetId = budgetIdByRequest.get('Riverside Facility Expansion');
Id downtownBudgetId = budgetIdByRequest.get('Downtown Learning Center');
Id harborBudgetId = budgetIdByRequest.get('Harbor Food Pantry Expansion');

// working budgets go Active; Harbor is fully submitted (whole grid read-only)
update new List<%%%NAMESPACED_ORG%%%Budget__c>{
    new %%%NAMESPACED_ORG%%%Budget__c(Id = riversideBudgetId, %%%NAMESPACED_ORG%%%Status__c = 'Active'),
    new %%%NAMESPACED_ORG%%%Budget__c(Id = downtownBudgetId, %%%NAMESPACED_ORG%%%Status__c = 'Active'),
    new %%%NAMESPACED_ORG%%%Budget__c(Id = harborBudgetId, %%%NAMESPACED_ORG%%%Status__c = 'Active', %%%NAMESPACED_ORG%%%Submitted__c = true, %%%NAMESPACED_ORG%%%Amount__c = 140000)
};

// Downtown Quarter 1 is a submitted reporting period (locked in reporting mode)
%%%NAMESPACED_ORG%%%Budget_Period__c downtownQ1 = [SELECT Id FROM %%%NAMESPACED_ORG%%%Budget_Period__c
    WHERE %%%NAMESPACED_ORG%%%Budget__c = :downtownBudgetId AND Name = 'Quarter 1' LIMIT 1];
downtownQ1.%%%NAMESPACED_ORG%%%Submitted__c = true;
update downtownQ1;

// actuals: Riverside Year 1 live reporting (site prep 15% over the 10% threshold -> flagged),
// Downtown Q1 submitted actuals (assistants 17.5% under the 15% threshold -> flagged) + partial Q2
List<%%%NAMESPACED_ORG%%%Budget_Value__c> actualUpdates = new List<%%%NAMESPACED_ORG%%%Budget_Value__c>();
for (%%%NAMESPACED_ORG%%%Budget_Value__c value : [SELECT Id, %%%NAMESPACED_ORG%%%Comments__c, %%%NAMESPACED_ORG%%%Category__r.Name, %%%NAMESPACED_ORG%%%Period__r.Name
        FROM %%%NAMESPACED_ORG%%%Budget_Value__c WHERE %%%NAMESPACED_ORG%%%Category__r.%%%NAMESPACED_ORG%%%Budget__c IN (:riversideBudgetId, :downtownBudgetId)]) {
    String key = value.%%%NAMESPACED_ORG%%%Category__r.Name + '|' + value.%%%NAMESPACED_ORG%%%Period__r.Name + '|' +
        (value.%%%NAMESPACED_ORG%%%Comments__c == null ? '' : value.%%%NAMESPACED_ORG%%%Comments__c);
    if (key == 'Construction|Year 1|Site preparation') actualUpdates.add(new %%%NAMESPACED_ORG%%%Budget_Value__c(Id = value.Id, %%%NAMESPACED_ORG%%%Actual_Amount__c = 46000));
    if (key == 'Construction|Year 1|New wing build') actualUpdates.add(new %%%NAMESPACED_ORG%%%Budget_Value__c(Id = value.Id, %%%NAMESPACED_ORG%%%Actual_Amount__c = 52000));
    if (key == 'Equipment|Year 1|') actualUpdates.add(new %%%NAMESPACED_ORG%%%Budget_Value__c(Id = value.Id, %%%NAMESPACED_ORG%%%Actual_Quantity__c = 28));
    if (key == 'Staffing|Year 1|') actualUpdates.add(new %%%NAMESPACED_ORG%%%Budget_Value__c(Id = value.Id, %%%NAMESPACED_ORG%%%Actual_Amount__c = 25000));
    if (key == 'Instruction|Quarter 1|Lead instructor') actualUpdates.add(new %%%NAMESPACED_ORG%%%Budget_Value__c(Id = value.Id, %%%NAMESPACED_ORG%%%Actual_Amount__c = 8200));
    if (key == 'Instruction|Quarter 1|Teaching assistants') actualUpdates.add(new %%%NAMESPACED_ORG%%%Budget_Value__c(Id = value.Id, %%%NAMESPACED_ORG%%%Actual_Amount__c = 3300));
    if (key == 'Learning Materials|Quarter 1|') actualUpdates.add(new %%%NAMESPACED_ORG%%%Budget_Value__c(Id = value.Id, %%%NAMESPACED_ORG%%%Actual_Quantity__c = 160));
    if (key == 'Outreach Allocation|Quarter 1|') actualUpdates.add(new %%%NAMESPACED_ORG%%%Budget_Value__c(Id = value.Id, %%%NAMESPACED_ORG%%%Actual_Percent__c = 25));
    if (key == 'Instruction|Quarter 2|Lead instructor') actualUpdates.add(new %%%NAMESPACED_ORG%%%Budget_Value__c(Id = value.Id, %%%NAMESPACED_ORG%%%Actual_Amount__c = 4000));
}
update actualUpdates;

// Harbor disbursements: OFM's own payment ledger alongside the submitted budget
Id harborRequestId;
for (outfunds__Funding_Request__c request : requests)
    if (request.Name == 'Harbor Food Pantry Expansion') harborRequestId = request.Id;
insert new List<outfunds__Disbursement__c>{
    new outfunds__Disbursement__c(outfunds__Funding_Request__c = harborRequestId,
        outfunds__Amount__c = 70000, outfunds__Type__c = 'Initial', outfunds__Status__c = 'Paid',
        outfunds__Scheduled_Date__c = Date.newInstance(2026, 1, 15), outfunds__Disbursement_Date__c = Date.newInstance(2026, 1, 15)),
    new outfunds__Disbursement__c(outfunds__Funding_Request__c = harborRequestId,
        outfunds__Amount__c = 70000, outfunds__Type__c = 'Final', outfunds__Status__c = 'Scheduled',
        outfunds__Scheduled_Date__c = Date.newInstance(2027, 1, 15))
};

System.debug('OFM demo seeded: ' + requests.size() + ' requests, budgets cloned by flow, actuals + locks layered.');
