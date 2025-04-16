/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached User Role records
 */
public with sharing class QueryRole {
  private static Map<String, UserRole> userRoles = new Map<String, UserRole>();
  private static Map<Id, String> mapOfRoleIdAndRoleDeveloperName = new Map<Id, String>();

  static {
    for (UserRole ur : [
      SELECT Id, DeveloperName
      FROM UserRole
      WITH SYSTEM_MODE
    ]) {
      userRoles.put(ur.DeveloperName, ur);
      mapOfRoleIdAndRoleDeveloperName.put(ur.Id, ur.DeveloperName);
    }
  }

  public static UserRole joinLead = get('Join_Lead');
  public static UserRole fraudXAgent = get('FraudX_Agent');

  /**
   * @description Get UserRole by UserRole DeveloperName
   * @param developerName developer name of the UserRole
   * @return UserRole
   */
  public static UserRole get(String developerName) {
    return userRoles.get(developerName);
  }

  /**
   * @description Get UserRole by User Role Id
   * @param roleId user role id
   * @return user role details
   */
  public static UserRole get(Id roleId) {
    return userRoles.get(mapOfRoleIdAndRoleDeveloperName.get(roleId));
  }
}
