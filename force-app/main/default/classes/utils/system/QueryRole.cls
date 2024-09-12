/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached User Role records
 */
public with sharing class QueryRole {
  private static Map<String, UserRole> userRoles = new Map<String, UserRole>();
  static {
    for (UserRole ur : [
      SELECT Id, DeveloperName
      FROM UserRole
      WITH SYSTEM_MODE
    ]) {
      userRoles.put(ur.DeveloperName, ur);
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
}
