// Demo-only action plan templates for the grant application lifecycle (#67). A grantmaking org runs its
// process on these: a configured client org carries 31 templates, 113 template items and 130 live action
// plans, while a fresh scratch org has none, so the demo showed the budget with no process around it.
// Every template targets a real stage of the lifecycle, and the budget checkpoints are deliberate: the
// point of the product is that money is reviewed alongside the application, not after it.
// Run: sf apex run --file scripts/seed_npc_demo_action_plans.apex -o <org>

String seedPrefix = 'FTK Demo';
List<ActionPlanTemplate> existingTemplates = [SELECT Id FROM ActionPlanTemplate WHERE Name LIKE 'FTK Demo%'];
if (!existingTemplates.isEmpty()) {
    System.debug('Action plan templates already seeded (' + existingTemplates.size() + ') - nothing to do.');
    return;
}

// name -> target entity, then the items each one carries in order
Map<String, String> targetByTemplateName = new Map<String, String>{
    'FTK Demo: Grant Application Intake' => 'IndividualApplication',
    'FTK Demo: Application Review' => 'ApplicationReview',
    'FTK Demo: Budget Review' => 'Budget',
    'FTK Demo: Award Setup and Disbursement' => 'FundingAward',
    'FTK Demo: Grantee Reporting and Close Out' => 'FundingAwardRequirement'
};
Map<String, List<String>> itemsByTemplateName = new Map<String, List<String>>{
    'FTK Demo: Grant Application Intake' => new List<String>{
        'Confirm the applicant is eligible for this opportunity',
        'Collect organisation registration and financial documents',
        'Check the budget is complete and every category is costed',
        'Confirm the requested amount is within the opportunity ceiling',
        'Confirm the authorised signatory'
    },
    'FTK Demo: Application Review' => new List<String>{
        'Programme officer assessment',
        'Review the budget against the funding cap and flag any violations',
        'Reference and due diligence checks',
        'Score the application against the published criteria',
        'Panel recommendation'
    },
    'FTK Demo: Budget Review' => new List<String>{
        'Check every category has at least one costed line item',
        'Confirm indirect costs are within the funder rate',
        'Review categories that require an estimate or a receipt',
        'Resolve outstanding budget violations before award'
    },
    'FTK Demo: Award Setup and Disbursement' => new List<String>{
        'Issue the award letter',
        'Collect the countersigned grant agreement',
        'Confirm the grantee banking details',
        'Schedule disbursements against the budget periods',
        'Set the reporting calendar'
    },
    'FTK Demo: Grantee Reporting and Close Out' => new List<String>{
        'Interim narrative report received',
        'Interim financial report reconciled against the budget',
        'Review claimed amounts against budgeted amounts and explain variances',
        'Final report received',
        'Close out the award and archive the file'
    }
};

List<ActionPlanTemplate> templates = new List<ActionPlanTemplate>();
for (String templateName : targetByTemplateName.keySet()) {
    templates.add(new ActionPlanTemplate(
        Name = templateName,
        UniqueName = templateName.replace('FTK Demo: ', 'FTK_Demo_').replace(' ', '_'),
        ActionPlanType = 'Industries',
        TargetEntityType = targetByTemplateName.get(templateName),
        IsAdHocItemCreationEnabled = true
    ));
}
insert templates;

// inserting a template creates its version - a second one is rejected, so the auto-created version is used
Map<Id, String> templateNameById = new Map<Id, String>();
for (ActionPlanTemplate template : templates) templateNameById.put(template.Id, template.Name);
List<ActionPlanTemplateVersion> versions = [SELECT Id, Name, ActionPlanTemplateId, Status FROM ActionPlanTemplateVersion WHERE ActionPlanTemplateId IN :templateNameById.keySet()];

List<ActionPlanTemplateItem> items = new List<ActionPlanTemplateItem>();
for (ActionPlanTemplateVersion version : versions) {
    String templateName = templateNameById.get(version.ActionPlanTemplateId);
    Integer sequence = 1;
    for (String itemName : itemsByTemplateName.get(templateName)) {
        items.add(new ActionPlanTemplateItem(
            Name = itemName,
            UniqueName = templateName.replace('FTK Demo: ', 'FTK_Demo_').replace(' ', '_') + '_' + sequence,
            ActionPlanTemplateVersionId = version.Id,
            ItemEntityType = 'Task',
            IsRequired = sequence <= 2,
            IsActive = true
        ));
        sequence++;
    }
}
insert items;

// the version must leave Draft before the template can be applied to a record
for (ActionPlanTemplateVersion version : versions) version.Status = 'Final';
update versions;

System.debug('Seeded ' + templates.size() + ' action plan templates, ' + versions.size() + ' versions and ' + items.size() + ' items.');
for (ActionPlanTemplate template : [SELECT Name, TargetEntityType FROM ActionPlanTemplate WHERE Name LIKE 'FTK Demo%' ORDER BY Name])
    System.debug('  ' + template.Name + ' -> ' + template.TargetEntityType);
