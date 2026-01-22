List<Id> usrLId = new List<Id>();

List<user> usrs = [
  SELECT Id, FederationIdentifier
  FROM User
  WHERE
    IsActive = TRUE
    AND (FederationIdentifier LIKE '%@anz.com'
    OR FederationIdentifier LIKE '%@ANZ.com'
    OR FederationIdentifier LIKE '%@ANZ.COM')
  LIMIT 2000
];

List<user> newUsers = new List<user>();

for (user u : usrs) {
  string fed = u.FederationIdentifier;
  if (fed.contains('@anz.com')) {
    u.FederationIdentifier = fed.replace('anz.com', 'anznp.com');
  } else if (fed.contains('@ANZ.com')) {
    u.FederationIdentifier = fed.replace('ANZ.com', 'anznp.com');
  } else if (fed.contains('@ANZ.COM')) {
    u.FederationIdentifier = fed.replace('ANZ.COM', 'anznp.com');
  }

  newUsers.add(u);
  usrLId.add(u.id);
}

List<UserLogin> usrL = [
  SELECT userId
  FROM UserLogin
  WHERE IsFrozen = TRUE AND userId IN :usrLId
];

List<UserLogin> usrLL = new List<UserLogin>();

for (UserLogin ull : usrL) {
  ull.IsFrozen = false;
  usrLL.add(ull);
}

system.debug(newUsers.size());
system.debug(usrLL.size());

try {
  Database.update(newUsers, false);
  system.debug('success on User');
} catch (Exception e) {
  system.debug(e.getMessage());
}

try {
  Database.update(usrLL, false);
  system.debug('success on UserLogin');
} catch (Exception e) {
  system.debug(e.getMessage());
}

usrs = [
  SELECT Id, FederationIdentifier
  FROM User
  WHERE
    IsActive = TRUE
    AND (FederationIdentifier LIKE '%@anz.com'
    OR FederationIdentifier LIKE '%@ANZ.com'
    OR FederationIdentifier LIKE '%@ANZ.COM')
];

system.debug('Remained: ' + String.valueOf(usrs.size()));
system.debug(
  'Stop job Flag: ' + String.valueOf(newUsers.size() == usrs.size())
);
