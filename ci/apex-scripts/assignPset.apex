//---- This is to assignPset to the currentUser

String currentUsername = Userinfo.getUserName();
Id currentUserId = UserInfo.getUserId();
List<String> psetToBeAssigned = new List<String>{
  'FinancialServicesCloudStandard',
  'Customer_Relationships_Read_Write'
};
String result = '';
List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
Set<Id> userPsetsAssignedId = new Set<Id>();

for (PermissionSetAssignment psa : [
  SELECT PermissionSetId
  FROM PermissionSetAssignment
  WHERE AssigneeId = :currentUserId
]) {
  userPsetsAssignedId.add(psa.PermissionSetId);
}

List<PermissionSet> ps = [
  SELECT Id
  FROM PermissionSet
  WHERE Name IN :psetToBeAssigned AND Id NOT IN :userPsetsAssignedId
];

for (PermissionSet p : ps) {
  PermissionSetAssignment assignment = new PermissionSetAssignment();
  assignment.AssigneeId = currentUserId;
  assignment.PermissionSetId = p.Id;
  assignments.add(assignment);
}

if (!assignments.isEmpty()) {
  try {
    insert assignments;
    result = 'Permission Set assigned successfully to users.';
  } catch (Exception e) {
    result = 'Error assigning Permission Set: ' + e.getMessage();
  }
} else {
  result = 'These psets has already assigned to the user.';
}

System.debug(result);
