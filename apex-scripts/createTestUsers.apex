List<User> testUsers = new List<User>();
Integer user_count = 4;
Id anzxProfile = [
  SELECT Id
  FROM Profile
  WHERE Name = 'ANZx Standard User'
  LIMIT 1
]
.Id;
Id callCenter = [
  SELECT Id
  FROM CallCenter
  WHERE Name = 'Twilo Flex Call Center Adapter Open CTI'
  LIMIT 1
]
.Id;
List<String> roles = new List<String>{
  'Coach',
  'Content Writer',
  'Fraud Agent',
  'Quality Analyst',
  'Super Support Admin',
  'Support Coach',
  'Support Staff ARC'
};
for (String role : roles) {
  for (Integer i = 1; i < user_count; i++) {
    User u = new User(
      TimeZoneSidKey = 'Australia/Sydney',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US'
    );
    u.Username =
      '_' +
      role.deleteWhitespace() +
      'Test' +
      i +
      '@anzx.com.systest';
    u.Email = 'email goes here';
    u.FirstName = 'Test';
    u.LastName = role.deleteWhitespace() + i;
    u.Alias = role.left(6).deleteWhitespace() + i;
    u.ProfileId = anzxProfile;
    u.Business_Function__c = 'ANZx';
    u.Business_Role__c = role;
    //for trigger to assign perms automatically, fed id must not be null
    u.FederationIdentifier = role.deleteWhitespace() + i;
    u.UserPermissionsMarketingUser = true;
    u.UserPermissionsOfflineUser = true;
    u.UserPermissionsCallCenterAutoLogin = true;
    u.UserPermissionsSupportUser = true;
    u.UserPermissionsKnowledgeUser = true;
    u.UserPermissionsInteractionUser = true;
    //all roles bar content writer should be added to the twilio call center
    if (role != 'Content Writer') {
      u.CallCenterId = callCenter;
    }
    testUsers.add(u);
  }
}
insert testUsers;
