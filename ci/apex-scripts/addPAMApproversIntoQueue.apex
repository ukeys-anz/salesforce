
//--- Add non-prod approvers to PAM Approvers Queue

// Find the sandbox name:
System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
String sandboxName = d.getSandboxName();

List<GroupMember> gms = new List<GroupMember>();
Group pamApproversQueue = [
  SELECT Id, Name
  FROM Group
  WHERE Name = 'PAM Approvers' AND type = 'Queue'
  LIMIT 1
];

// Add users to PAM approver Queue
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
  gms.add(
    new GroupMember(GroupId = pamApproversQueue.id, UserOrGroupId = u.id)
  );
}

insert gms;
System.debug(gms);
