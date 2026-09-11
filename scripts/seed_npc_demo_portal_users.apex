// Demo-only Experience Cloud users for the Grantmaking Portal (#67): two grantee staff and the two people
// in the household, so the portal can be tested from both sides. Customer Community Plus is role-based, so
// the account owner must hold a user role before any of these can be created - a scratch org's sample role
// hierarchy is rejected ("invalid cross reference id"), hence the role created here.
// Runs AFTER scripts/seed_npc_demo_party.apex and after the community exists.
// Run: sf apex run --file scripts/seed_npc_demo_portal_users.apex -o <org>

String portalProfileName = 'Customer Community Plus User';
String seedRoleDeveloperName = 'Demo_Grantmaking_Admin';
String demoPassword = 'Test1234!';

List<Profile> portalProfiles = [SELECT Id FROM Profile WHERE Name = :portalProfileName LIMIT 1];
if (portalProfiles.isEmpty()) {
    System.debug('Profile "' + portalProfileName + '" not found - nothing seeded.');
    return;
}

// the owner of the accounts these contacts hang off needs a role, or user creation is rejected
User runningUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
if (runningUser.UserRoleId == null) {
    List<UserRole> seedRoles = [SELECT Id FROM UserRole WHERE DeveloperName = :seedRoleDeveloperName LIMIT 1];
    UserRole seedRole = seedRoles.isEmpty() ? new UserRole(Name = 'Demo Grantmaking Admin', DeveloperName = seedRoleDeveloperName) : seedRoles[0];
    if (seedRoles.isEmpty()) insert seedRole;
    runningUser.UserRoleId = seedRole.Id;
    update runningUser;
    System.debug('Assigned role ' + seedRole.Id + ' to the running user. Re-run this script to create the portal users.');
    return;
}

// the four demo people: grantee staff by contact, household members through their person accounts
Set<String> seedEmailSet = new Set<String>{
    'sofia.ramirez@example.org', 'james.whitfield@example.org',
    'maria.alvarez@example.org', 'daniel.alvarez@example.org'
};
List<Contact> portalContacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email IN :seedEmailSet];
if (portalContacts.isEmpty()) {
    System.debug('No demo contacts found - run seed_npc_demo_party.apex first.');
    return;
}

Set<Id> portalContactIdSet = new Map<Id, Contact>(portalContacts).keySet();
Set<Id> existingUserContactIdSet = new Set<Id>();
for (User existingUser : [SELECT ContactId FROM User WHERE ContactId IN :portalContactIdSet]) existingUserContactIdSet.add(existingUser.ContactId);

String orgSuffix = UserInfo.getOrganizationId().substring(0, 8).toLowerCase();
List<User> portalUsers = new List<User>();
for (Contact portalContact : portalContacts) {
    if (existingUserContactIdSet.contains(portalContact.Id)) continue;
    String alias = (portalContact.FirstName.substring(0, 1) + portalContact.LastName).toLowerCase();
    portalUsers.add(new User(
        ContactId = portalContact.Id,
        ProfileId = portalProfiles[0].Id,
        FirstName = portalContact.FirstName,
        LastName = portalContact.LastName,
        Email = portalContact.Email,
        Username = portalContact.Email + '.' + orgSuffix,
        Alias = alias.length() > 8 ? alias.substring(0, 8) : alias,
        CommunityNickname = portalContact.FirstName.toLowerCase() + '.' + portalContact.LastName.toLowerCase() + '.' + orgSuffix,
        TimeZoneSidKey = 'America/Chicago',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        IsActive = true
    ));
}

if (!portalUsers.isEmpty()) {
    insert portalUsers;
    for (User portalUser : portalUsers) {
        try { System.setPassword(portalUser.Id, demoPassword); } catch (Exception e) { System.debug('Password not set for ' + portalUser.Username + ': ' + e.getMessage()); }
    }
}

System.debug('Portal users: ' + portalUsers.size() + ' created, ' + existingUserContactIdSet.size() + ' already existed. Password for all: ' + demoPassword);
for (User portalUser : [SELECT FirstName, LastName, Username FROM User WHERE ContactId IN :portalContactIdSet ORDER BY LastName, FirstName]) {
    System.debug('  ' + portalUser.FirstName + ' ' + portalUser.LastName + ' -> ' + portalUser.Username);
}
