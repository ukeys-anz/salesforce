//---- This is to assignPset to the currentUser

String currentUsername = Userinfo.getUserName();
List<String> psetToBeAssigned = new List<String>{
  'FinServ__FinancialServicesCloudStandard',
  'Customer_Relationships_Read_Write'
};
String result = '';
List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();

List<PermissionSet> ps = [
  SELECT Id
  FROM PermissionSet
  WHERE Name IN :psetToBeAssigned
];
User usr = [SELECT Id FROM User WHERE Username LIKE :currentUsername LIMIT 1];

for (PermissionSet p : ps) {
  PermissionSetAssignment assignment = new PermissionSetAssignment();
  assignment.AssigneeId = usr.Id;
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
}

System.debug(result);
