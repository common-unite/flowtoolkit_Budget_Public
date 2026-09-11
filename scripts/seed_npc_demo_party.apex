// Demo-only party data for the grantmaking spine (#67): the grantee organisation, its staff, a household and
// the people in it, wired into the application, award and application-form records the budget seed creates.
// Mirrors how a configured client org models it (verified 2026-09-09): households are business accounts with
// a Household record type and people relate to them through AccountContactRelation. PartyRelationshipGroup
// and ContactContactRelation are not usable in this org shape, nor in the client org, so neither is used.
// Runs AFTER unpackaged/config/npc_demo deploys, which is what ships the Household record type.
// Run: sf apex run --file scripts/seed_npc_demo_party.apex -o <org>

String seedOrganizationName = 'Riverside Community Garden Collective';
String seedHouseholdName = 'Alvarez Household';
Set<String> seedAccountNameSet = new Set<String>{ seedOrganizationName, seedHouseholdName, 'Alvarez' };

Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
Id organizationRecordTypeId = accountRecordTypeMap.containsKey('Business_Account') ? accountRecordTypeMap.get('Business_Account').getRecordTypeId() : null;
Id householdRecordTypeId = accountRecordTypeMap.containsKey('Household') ? accountRecordTypeMap.get('Household').getRecordTypeId() : null;
Id personRecordTypeId = accountRecordTypeMap.containsKey('PersonAccount') ? accountRecordTypeMap.get('PersonAccount').getRecordTypeId() : null;
if (householdRecordTypeId == null) {
    System.debug('No Household record type - deploy unpackaged/config/npc_demo first. Nothing seeded.');
    return;
}

// Create-if-missing rather than delete-and-recreate: once portal users exist (#67, seed_npc_demo_portal_users)
// they reference these contacts, and Apex cannot delete a user, so a destructive re-run would fail outright.
Map<String, Account> existingAccountByName = new Map<String, Account>();
for (Account existingAccount : [SELECT Id, Name, PersonContactId, FirstName FROM Account WHERE Name IN :seedAccountNameSet]) existingAccountByName.put(existingAccount.Name, existingAccount);

Account grantee = existingAccountByName.get(seedOrganizationName);
Account household = existingAccountByName.get(seedHouseholdName);
List<Account> accountsToInsert = new List<Account>();
if (grantee == null) {
    grantee = new Account(Name = seedOrganizationName, RecordTypeId = organizationRecordTypeId,
        Description = 'Community garden network applying for a three-year operating grant.');
    accountsToInsert.add(grantee);
}
if (household == null) {
    household = new Account(Name = seedHouseholdName, RecordTypeId = householdRecordTypeId);
    accountsToInsert.add(household);
}
if (!accountsToInsert.isEmpty()) insert accountsToInsert;

// the people: two person accounts in the household, two staff contacts at the grantee organisation
Set<String> personEmailSet = new Set<String>{ 'maria.alvarez@example.org', 'daniel.alvarez@example.org' };
Set<String> staffEmailSet = new Set<String>{ 'sofia.ramirez@example.org', 'james.whitfield@example.org' };
Set<String> existingPersonEmailSet = new Set<String>();
for (Account existingPerson : [SELECT PersonEmail FROM Account WHERE PersonEmail IN :personEmailSet]) existingPersonEmailSet.add(existingPerson.PersonEmail);

List<Account> personAccountsToInsert = new List<Account>();
if (!existingPersonEmailSet.contains('maria.alvarez@example.org'))
    personAccountsToInsert.add(new Account(RecordTypeId = personRecordTypeId, FirstName = 'Maria', LastName = 'Alvarez', PersonEmail = 'maria.alvarez@example.org'));
if (!existingPersonEmailSet.contains('daniel.alvarez@example.org'))
    personAccountsToInsert.add(new Account(RecordTypeId = personRecordTypeId, FirstName = 'Daniel', LastName = 'Alvarez', PersonEmail = 'daniel.alvarez@example.org'));
if (!personAccountsToInsert.isEmpty()) insert personAccountsToInsert;

Map<String, Contact> existingStaffByEmail = new Map<String, Contact>();
for (Contact existingStaff : [SELECT Id, Email, FirstName FROM Contact WHERE Email IN :staffEmailSet]) existingStaffByEmail.put(existingStaff.Email, existingStaff);
List<Contact> staffToInsert = new List<Contact>();
if (!existingStaffByEmail.containsKey('sofia.ramirez@example.org'))
    staffToInsert.add(new Contact(AccountId = grantee.Id, FirstName = 'Sofia', LastName = 'Ramirez', Title = 'Executive Director', Email = 'sofia.ramirez@example.org'));
if (!existingStaffByEmail.containsKey('james.whitfield@example.org'))
    staffToInsert.add(new Contact(AccountId = grantee.Id, FirstName = 'James', LastName = 'Whitfield', Title = 'Finance Manager', Email = 'james.whitfield@example.org'));
if (!staffToInsert.isEmpty()) insert staffToInsert;
List<Contact> staffContacts = [SELECT Id, FirstName, Email FROM Contact WHERE Email IN :staffEmailSet ORDER BY FirstName DESC];

// household membership: each person's contact related to the household account, the primary member first
List<Account> insertedPersonAccounts = [SELECT Id, PersonContactId, FirstName FROM Account WHERE PersonEmail IN :personEmailSet ORDER BY FirstName];
Set<Id> relatedContactIdSet = new Set<Id>();
for (AccountContactRelation existingRelation : [SELECT ContactId FROM AccountContactRelation WHERE Account.Name IN :seedAccountNameSet]) relatedContactIdSet.add(existingRelation.ContactId);
List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
for (Account personAccount : insertedPersonAccounts) {
    if (relatedContactIdSet.contains(personAccount.PersonContactId)) continue;
    accountContactRelations.add(new AccountContactRelation(AccountId = household.Id, ContactId = personAccount.PersonContactId,
        IsActive = true, IsPrimaryMember = personAccount.FirstName == 'Maria', IsPrimaryGroup = true, IsIncludedInGroup = true));
}
// the staff contacts already carry a direct relation to the grantee through Contact.AccountId - inserting
// another is rejected as a duplicate, so only the indirect relationship below is created here.
// Maria applies on the organisation's behalf, which is why she also relates to the grantee
if (!relatedContactIdSet.contains(insertedPersonAccounts[1].PersonContactId))
    accountContactRelations.add(new AccountContactRelation(AccountId = grantee.Id, ContactId = insertedPersonAccounts[1].PersonContactId,
        IsActive = true, IsPrimaryMember = false, IsPrimaryGroup = false, IsIncludedInGroup = false));
if (!accountContactRelations.isEmpty()) insert accountContactRelations;

// wire the grantmaking spine the budget seed created
Id directorContactId = staffContacts[0].Id;
List<FundingAward> fundingAwards = [SELECT Id FROM FundingAward WHERE Name = 'Riverside Community Garden - Award'];
for (FundingAward fundingAward : fundingAwards) {
    fundingAward.AwardeeId = grantee.Id;
    fundingAward.ContactId = directorContactId;
}
update fundingAwards;

// IndividualApplication.AccountId is rejected unless it is a PERSON account - the platform models the
// applicant as a person, which is why a configured client org runs tens of thousands of person accounts.
// The organisation shows through the funding award's awardee instead.
Account applicant = insertedPersonAccounts[1];
List<IndividualApplication> individualApplications = [SELECT Id FROM IndividualApplication WHERE FundingOpportunity.Name = 'Riverside Community Garden Grants 2026'];
for (IndividualApplication individualApplication : individualApplications) {
    individualApplication.AccountId = applicant.Id;
    individualApplication.ContactId = applicant.PersonContactId;
}
update individualApplications;

// Application participants (#67). PublicApplicationParticipant is the only participant object in this org
// shape that links people to an application, and its ApplicationId accepts IndividualApplication only, never
// ApplicationForm. A licensed Nonprofit Cloud org carries a richer family instead - BudgetParticipant,
// FundingAwardParticipant, IndividualApplnParticipant, FundingOppParticipant - none of which exist here.
// ParticipantId is polymorphic, so the staff go on as contacts and the household people as person accounts.
if (!individualApplications.isEmpty()) {
    Id applicationId = individualApplications[0].Id;
    Set<Id> existingParticipantIdSet = new Set<Id>();
    for (PublicApplicationParticipant existingParticipant : [SELECT ParticipantId FROM PublicApplicationParticipant WHERE ApplicationId = :applicationId])
        existingParticipantIdSet.add(existingParticipant.ParticipantId);

    List<PublicApplicationParticipant> participants = new List<PublicApplicationParticipant>();
    for (Account personAccount : insertedPersonAccounts) {
        if (!existingParticipantIdSet.contains(personAccount.Id))
            participants.add(new PublicApplicationParticipant(ApplicationId = applicationId, ParticipantId = personAccount.Id));
    }
    for (Contact staffContact : staffContacts) {
        if (!existingParticipantIdSet.contains(staffContact.Id))
            participants.add(new PublicApplicationParticipant(ApplicationId = applicationId, ParticipantId = staffContact.Id));
    }
    if (!participants.isEmpty()) insert participants;
    System.debug('Application participants: ' + participants.size() + ' created, ' + existingParticipantIdSet.size() + ' already present.');
}

SObjectType applicationFormType = Schema.getGlobalDescribe().get('ApplicationForm');
if (applicationFormType != null) {
    List<SObject> applicationForms = Database.query('SELECT Id FROM ApplicationForm');
    for (SObject applicationForm : applicationForms) {
        applicationForm.put('AccountId', grantee.Id);
        applicationForm.put('SubmittedById', directorContactId);
    }
    update applicationForms;
}

System.debug('Seeded ' + seedOrganizationName + ' (' + grantee.Id + '), ' + seedHouseholdName + ' (' + household.Id + '), '
    + insertedPersonAccounts.size() + ' person accounts, ' + staffContacts.size() + ' staff contacts, '
    + accountContactRelations.size() + ' account-contact relations, and wired ' + fundingAwards.size() + ' award(s) and '
    + individualApplications.size() + ' application(s).');
