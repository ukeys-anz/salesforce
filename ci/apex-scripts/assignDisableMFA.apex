// Script to assign Disable_MFA permission set based on environment
// Both Prod and Non-Prod: Assign to non-engineers whose profile doesn't have BypassMFAForUiLogins
// Non-Prod only: Add Disable_MFA to Engineer Permission Set Group

// Determine if this is a production environment
Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
if (isSandbox) {
  System.debug('Running in NON-PRODUCTION environment');
} else {
  System.debug('Running in PRODUCTION environment');
}

// Query target users (same for both prod and non-prod)
// Salesforce-licensed users without BypassMFAForUiLogins, excluding Engineers
// Process up to 500 users per run to stay well within DML limits
Integer batchLimit = 500;
List<User> targetUsers = [
  SELECT
    Id,
    Username,
    Profile.Name,
    Profile.UserLicense.Name,
    ProfileId,
    UserRoleId,
    UserRole.Name
  FROM User
  WHERE
    IsActive = TRUE
    AND Profile.UserLicense.Name = 'Salesforce'
    AND Profile.PermissionsBypassMFAForUiLogins != TRUE
    AND (UserRole.Name != 'Engineer'
    OR UserRoleId = NULL)
  LIMIT :batchLimit
];
System.debug('Excluding users with Engineer role');

System.debug('Found ' + targetUsers.size() + ' users matching criteria');

if (targetUsers.isEmpty()) {
  System.debug('No users found matching criteria');
  return;
}

// Get the Disable_MFA permission set
PermissionSet disableMFAPermSet;
try {
  disableMFAPermSet = [
    SELECT Id, Name
    FROM PermissionSet
    WHERE Name = 'Disable_MFA'
    LIMIT 1
  ];
  System.debug('Found Disable_MFA permission set: ' + disableMFAPermSet.Id);
} catch (Exception e) {
  System.debug(
    'ERROR: Disable_MFA permission set not found: ' + e.getMessage()
  );
  throw e;
}

// Get existing permission set assignments to avoid duplicates
Set<Id> userIds = new Set<Id>();
for (User u : targetUsers) {
  userIds.add(u.Id);
}

Set<Id> usersWithPermSet = new Set<Id>();
for (PermissionSetAssignment psa : [
  SELECT AssigneeId
  FROM PermissionSetAssignment
  WHERE PermissionSetId = :disableMFAPermSet.Id AND AssigneeId IN :userIds
]) {
  usersWithPermSet.add(psa.AssigneeId);
}

System.debug(
  usersWithPermSet.size() + ' users already have the permission set'
);

// Create permission set assignments for users who don't have it
List<PermissionSetAssignment> assignmentsToInsert = new List<PermissionSetAssignment>();
for (User u : targetUsers) {
  if (!usersWithPermSet.contains(u.Id)) {
    assignmentsToInsert.add(
      new PermissionSetAssignment(
        PermissionSetId = disableMFAPermSet.Id,
        AssigneeId = u.Id
      )
    );
    String roleInfo = u.UserRole != null ? u.UserRole.Name : 'No Role';
    System.debug(
      'Will assign to: ' +
        u.Username +
        ' (Profile: ' +
        u.Profile.Name +
        ', License: ' +
        u.Profile.UserLicense.Name +
        ', Role: ' +
        roleInfo +
        ')'
    );
  }
}

if (!assignmentsToInsert.isEmpty()) {
  try {
    insert assignmentsToInsert;
    System.debug(
      'SUCCESS: Assigned Disable_MFA permission set to ' +
        assignmentsToInsert.size() +
        ' users'
    );
  } catch (DmlException e) {
    System.debug('ERROR: Failed to assign permission sets');
    for (Integer i = 0; i < e.getNumDml(); i++) {
      System.debug('Failed record ' + i + ': ' + e.getDmlMessage(i));
    }
    throw e;
  }
} else {
  System.debug(
    'All users in this batch already have the Disable_MFA permission set'
  );
}

// Check if there are more users to process
List<User> remainingUsers = [
  SELECT Id
  FROM User
  WHERE
    IsActive = TRUE
    AND Profile.UserLicense.Name = 'Salesforce'
    AND Profile.PermissionsBypassMFAForUiLogins != TRUE
    AND (UserRole.Name != 'Engineer'
    OR UserRoleId = NULL)
    AND Id NOT IN (
      SELECT AssigneeId
      FROM PermissionSetAssignment
      WHERE PermissionSetId = :disableMFAPermSet.Id
    )
];

System.debug('===== SUMMARY =====');
System.debug('Processed: ' + targetUsers.size() + ' users');
System.debug('Remaining users to process: ' + remainingUsers.size());

// Dynamic flag based on remaining users
Boolean stopJob = remainingUsers.isEmpty();
System.debug('Stop job Flag: ' + stopJob);

if (!stopJob) {
  System.debug(
    '⚠️  WARNING: More users remain! Please run this script again to process the next batch.'
  );
} else {
  System.debug('✅ All users have been processed successfully!');
}
