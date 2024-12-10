List<Id> usrLId = new List<Id>();

List<user> usrs = [
  SELECT Id, FederationIdentifier
  FROM User
  WHERE FederationIdentifier LIKE '%@anz.com' AND IsActive = TRUE
  LIMIT 2000
];

List<user> newUsers = new List<user>();

for (user u : usrs) {
  string fed = u.FederationIdentifier;
  u.FederationIdentifier = fed.replace('anz.com', 'anznp.com');
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
  update newUsers;
  system.debug('success on User');
} catch (Exception e) {
  system.debug(e.getMessage());
}

try {
  update usrLL;
  system.debug('success on UserLogin');
} catch (Exception e) {
  system.debug(e.getMessage());
}

usrs = [
  SELECT Id
  FROM User
  WHERE FederationIdentifier LIKE '%@anz.com' AND IsActive = TRUE
];
system.debug('Remained: ' + String.valueOf(usrs.size()));
system.debug(
  'Stop job Flag: ' + String.valueOf(newUsers.size() == usrs.size())
);
