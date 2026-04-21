List<Id> userIds = new List<Id>();
List<UserLogin> userLoginsToUnfreeze = new List<UserLogin>();

// Get all frozen UserLogin records
List<UserLogin> frozenUserLogins = [
  SELECT Id, UserId
  FROM UserLogin
  WHERE IsFrozen = TRUE
  LIMIT 2000
];

System.debug('Total frozen users: ' + frozenUserLogins.size());

// Unfreeze the UserLogins for active users only
for (UserLogin ul : frozenUserLogins) {
    ul.IsFrozen = false;
    userLoginsToUnfreeze.add(ul);
}

System.debug('UserLogins to unfreeze: ' + userLoginsToUnfreeze.size());

try {
  Database.update(userLoginsToUnfreeze, false);
} catch (Exception e) {
  System.debug(e.getMessage());
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
