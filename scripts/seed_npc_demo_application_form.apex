// Demo-only seed for the newer grantmaking application object (#67). Runs AFTER unpackaged/config/npc_demo
// deploys, because the clone flow that gives the application form its budget ships in that bundle - seeding
// it from seed_npc_budget.apex would create the record before its flow exists.
// Run: sf apex run --file scripts/seed_npc_demo_application_form.apex -o <org>

SObjectType applicationFormType = Schema.getGlobalDescribe().get('ApplicationForm');
if (applicationFormType == null) {
    System.debug('ApplicationForm is not in this org (Public Sector features are off) - nothing seeded.');
    return;
}

String seedOpportunityName = 'Riverside Community Garden Grants 2026';
List<FundingOpportunity> fundingOpportunities = [SELECT Id FROM FundingOpportunity WHERE Name = :seedOpportunityName LIMIT 1];
if (fundingOpportunities.isEmpty()) {
    System.debug('Funding Opportunity "' + seedOpportunityName + '" not found - run seed_npc_budget.apex first.');
    return;
}

Id fundingOpportunityId = fundingOpportunities[0].Id;
delete Database.query('SELECT Id FROM ApplicationForm WHERE ReferenceRecordId = :fundingOpportunityId');

// The ask is deliberately unlike every number on the template (budgeted 270,000, requested 240,000, maximum
// 250,000): it rides onto the cloned budget as the MAXIMUM, so a demo can see the funder's ceiling arrive
// from the application rather than from the template. A matching number would prove nothing.
SObject applicationForm = applicationFormType.newSObject();
applicationForm.put('Title', 'Riverside Community Garden - 2026 Request');
applicationForm.put('ReferenceRecordId', fundingOpportunityId);
applicationForm.put('UsageType', 'Grantmaking');
applicationForm.put('RequestedAmount', 230000);
applicationForm.put('SubmissionDate', Date.today());
insert applicationForm;

Id applicationFormId = applicationForm.Id;  // dynamic SOQL binds cannot take dot notation
SObject seededForm = Database.query('SELECT Id, BudgetId FROM ApplicationForm WHERE Id = :applicationFormId');
System.debug('Seeded Application Form ' + seededForm.Id + ' with cloned budget ' + seededForm.get('BudgetId') + '.');
