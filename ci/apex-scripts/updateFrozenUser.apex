List<Id> userIds = new List<Id>();
List<UserLogin> userLoginsToUnfreeze = new List<UserLogin>();

// Get all frozen UserLogin records
List<UserLogin> frozenUserLogins = [
  SELECT Id, UserId
  FROM UserLogin
  WHERE IsFrozen = TRUE
  LIMIT 2000
];

// Extract User IDs from frozen UserLogins
for (UserLogin ul : frozenUserLogins) {
  userIds.add(ul.UserId);
}

// Find which of these users are active
List<User> activeUsers = [
  SELECT Id
  FROM User
  WHERE IsActive = TRUE AND Id IN :userIds
];

// Create a set of active user IDs for easy lookup
Set<Id> activeUserIds = new Set<Id>();
for (User u : activeUsers) {
  activeUserIds.add(u.Id);
}

System.debug('Total frozen users: ' + frozenUserLogins.size());
System.debug('Active users among frozen: ' + activeUsers.size());

// Unfreeze the UserLogins for active users only
for (UserLogin ul : frozenUserLogins) {
  if (activeUserIds.contains(ul.UserId)) {
    ul.IsFrozen = false;
    userLoginsToUnfreeze.add(ul);
  }
}

System.debug('UserLogins to unfreeze: ' + userLoginsToUnfreeze.size());

try {
  Database.update(userLoginsToUnfreeze, false);
} catch (Exception e) {
  System.debug('Error while updating UserLogins: ' + e.getMessage());
}

// Verify remaining frozen users
frozenUserLogins = [
  SELECT Id, UserId
  FROM UserLogin
  WHERE IsFrozen = TRUE
];

System.debug('Remaining frozen users after update: ' + frozenUserLogins.size());
System.debug(
  'Stop job Flag: ' +
  String.valueOf(userLoginsToUnfreeze.size() == frozenUserLogins.size())
);
