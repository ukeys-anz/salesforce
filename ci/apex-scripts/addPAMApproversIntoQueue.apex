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
  'nagendra.singh@anzx.com.' +
  sandboxName, // Nagendra Singh
  'yogesh.jamgaonkar@anzx.com.' +
  sandboxName, // Yogesh Jamgaonkar
  'vaibhav.joshi@anzx.com.' +
  sandboxName // Vaibhav Joshi
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
