/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached User Role records
 */
public with sharing class QueryRole {
  private static Map<String, UserRole> userRolesByDeveloperName = new Map<String, UserRole>();
  private static Map<Id, String> userRolesById = new Map<Id, String>();

  static {
    for (UserRole ur : [
      SELECT Id, DeveloperName
      FROM UserRole
      WITH SYSTEM_MODE
    ]) {
      userRolesByDeveloperName.put(ur.DeveloperName, ur);
      userRolesById.put(ur.Id, ur.DeveloperName);
    }
  }

  public static UserRole joinLead = get('Join_Lead');
  public static UserRole fraudXAgent = get('FraudX_Agent');
  public static UserRole mlFranchiseRole = get(
    'Mobile_Lending_Franchise_Users'
  );

  public static UserRole bohCoachRole = get('BOH_Coach');
  public static UserRole bohCoachLeadRole = get('BOH_Coach_Lead');
  public static UserRole creditAssessmentOfficerRole = get(
    'Credit_Assessment_Officer'
  );
  public static UserRole creditAssessorLeadRole = get('Credit_Assessor_Lead');
  public static UserRole residentialBrokerManager = get(
    'Residential_Broker_Manager'
  );
  public static UserRole enablementManager = get('Enablement_Manager');

  /**
   * @description Get UserRole by UserRole DeveloperName
   * @param developerName developer name of the UserRole
   * @return UserRole
   */
  public static UserRole get(String developerName) {
    return userRolesByDeveloperName.get(developerName);
  }

  /**
   * @description Get UserRole by User Role Id
   * @param roleId user role id
   * @return user role details
   */
  public static UserRole getById(Id roleId) {
    return userRolesByDeveloperName.get(userRolesById.get(roleId));
  }
}
