String ORG_NAME = 'scratch'; // E.g. systest, staging
Boolean RUNNING_ON_SCRATCH_ORG = true;
Integer USER_COUNT_PER_ROLE = 1;
Integer SF_USER_LICENCE_LIMIT_BATCH_SIZE = 3; // scratch orgs currently have 3 spare 'Salesforce' licences
Id anzxProfile = CommonUtil.getProfileByName('ANZx Standard User').Id;
Id callCenter = [
  SELECT Id
  FROM CallCenter
  WHERE Name = 'Twilo Flex Call Center Adapter Open CTI'
  LIMIT 1
]
.Id;

Map<Integer, String> alphaMap = new Map<Integer, String>();
alphaMap.put(0, 'a');
alphaMap.put(1, 'b');
alphaMap.put(2, 'c');
alphaMap.put(3, 'd');
alphaMap.put(4, 'e');
alphaMap.put(5, 'f');
alphaMap.put(6, 'g');
alphaMap.put(7, 'h');
alphaMap.put(8, 'i');
alphaMap.put(9, 'g');
alphaMap.put(10, 'h');

List<String> roles = new List<String>{
  'Coach',
  'Content Writer',
  'Fraud Agent',
  'Quality Analyst',
  'Support Coach'
};

List<User> testUsers = new List<User>();

for (String role : roles) {
  for (Integer i = 0; i < USER_COUNT_PER_ROLE; i++) {
    User u = new User(
      TimeZoneSidKey = 'Australia/Sydney',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US'
    );

    String randStrGen = '';

    for (Integer j = 0; j < 10; j++) {
      Integer randInt = Integer.valueOf(Math.random() * 10);
      randStrGen += alphaMap.get(randInt);
    }

    u.Username =
      '_' +
      role.deleteWhitespace() +
      'Test' +
      randStrGen +
      i +
      '@anzx.com.' +
      ORG_NAME;
    u.Email = UserInfo.getUserEmail();
    u.FirstName = 'Test';
    u.LastName = role.deleteWhitespace() + i;
    u.Alias = role.left(6).deleteWhitespace() + i;
    u.ProfileId = anzxProfile;
    u.Business_Function__c = 'ANZx';
    u.Business_Role__c = role;
    u.FederationIdentifier = role.deleteWhitespace() + i;
    u.UserPermissionsMarketingUser = true;
    // doesn't have required licences in scratch org environments
    if (!RUNNING_ON_SCRATCH_ORG) {
      u.UserPermissionsOfflineUser = true;
    }
    u.UserPermissionsCallCenterAutoLogin = true;
    u.UserPermissionsSupportUser = true;
    u.UserPermissionsKnowledgeUser = true;
    u.UserPermissionsInteractionUser = true;
    u.IsActive = true;
    //all roles bar content writer should be added to the twilio call center
    if (role != 'Content Writer') {
      u.CallCenterId = callCenter;
    }
    testUsers.add(u);

    if (
      RUNNING_ON_SCRATCH_ORG &&
      testUsers.size() == SF_USER_LICENCE_LIMIT_BATCH_SIZE
    ) {
      // compromising the Golden Rule of no DMLs inside for loops :(
      insert testUsers;
      deactivateUsers(testUsers);
      testUsers = new List<User>();
    }
  }
}

if (!testUsers.isEmpty()) {
  insert testUsers;

  if (RUNNING_ON_SCRATCH_ORG) {
    deactivateUsers(testUsers);
  }
}

/**
 * @description Deactivating users to workaround licence limitations in scratch orgs
 */
void deactivateUsers(List<User> testUsers) {
  List<User> usersToDeactivate = new List<User>();
  for (User user : [SELECT IsActive FROM User WHERE Id IN :testUsers]) {
    user.IsActive = false;
    usersToDeactivate.add(user);
  }
  update usersToDeactivate;
}
