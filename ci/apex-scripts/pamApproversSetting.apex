//------ This is to update PAM_Global_Approver__c custom setting and add more users.

// Find the sandbox name

System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
String sandboxName = d.getSandboxName();

// Update the existing records
List<PAM_Global_Approver__c> pamApproversUpdated = new List<PAM_Global_Approver__c>();
List<PAM_Global_Approver__c> pamApprovers = [
  SELECT PAM_Approver_Username__c, SetupOwnerId
  FROM PAM_Global_Approver__c
];
for (PAM_Global_Approver__c pa : pamApprovers) {
  String pamApproverUserName = pa.PAM_Approver_Username__c;
  if (!pamApproverUserName.contains(sandboxName)) {
    pa.PAM_Approver_Username__c = pamApproverUserName + '.' + sandboxName;
    pamApproversUpdated.add(pa);
  }
}

// Add new approvers for non-prod sandboxes
List<String> npApproversUserNames = new List<String>{
  'victor.wang@anzx.com.' +
  sandboxName, // Qing Wang ( Victor )
  'mani.murugesan@anzx.com.' +
  sandboxName, // Manivasaga Vengatesh Murugesan
  'ngockieutrang.nguyen@anzx.com.' +
  sandboxName // Jasmine Nguyen
};
List<User> usrs = [
  SELECT Id, Username
  FROM User
  WHERE Username IN :npApproversUserNames
];

for (User u : usrs) {
  pamApproversUpdated.add(
    new PAM_Global_Approver__c(
      SetupOwnerId = u.Id,
      PAM_Approver_Username__c = u.Username
    )
  );
}

upsert pamApproversUpdated;
System.debug(pamApproversUpdated);
