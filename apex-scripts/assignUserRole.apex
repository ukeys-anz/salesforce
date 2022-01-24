List<User> users = [SELECT Id, Alias FROM User WHERE UserRoleId = ''];
List<UserRole> roles = [SELECT Id, Name FROM UserRole];
List<User> updateUser = new List<User>();
Map<String, Id> roleNameToId = new Map<String, Id>();
if (!users.isEmpty() && !roles.isEmpty()) {
  for (UserRole role : roles) {
    roleNameToId.put(role.Name, role.Id);
  }
  for (User u : users) {
    if (u.Alias == 'Coach') {
      updateUser.add(
        new User(Id = u.Id, UserRoleId = roleNameToId.get('Coach'))
      );
    } else if (u.Alias == 'ContAuth') {
      updateUser.add(
        new User(Id = u.Id, UserRoleId = roleNameToId.get('Content Writer'))
      );
    } else if (u.Alias.contains('IDR')) {
      updateUser.add(
        new User(Id = u.Id, UserRoleId = roleNameToId.get('Banker'))
      );
    } else if (u.Alias.contains('UUser')) {
      updateUser.add(
        new User(Id = u.Id, UserRoleId = roleNameToId.get('Coach'))
      );
    }
  }
  Database.update(updateUser);
}
