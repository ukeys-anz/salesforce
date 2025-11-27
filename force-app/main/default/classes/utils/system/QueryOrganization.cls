/**
 * @author Prahlad Bhadani
 * @since Nov 2025
 * @description Holds cached organizartion detail
 */
public with sharing class QueryOrganization {
  private static Organization cachedOrg;
  static {
    cachedOrg = [
      SELECT
        Id,
        Name,
        InstanceName,
        IsSandbox,
        NamespacePrefix,
        OrganizationType,
        TrialExpirationDate
      FROM Organization
      WITH SYSTEM_MODE
      LIMIT 1
    ];
  }

  /**
   * @description Returns the current organization
   * @return Organization - The current organization
   */
  public static Organization getOrgDetails() {
    return cachedOrg;
  }

  /**
   * @description Returns if the current org is sandbox
   * @return Boolean
   */
  public static Boolean isSandbox() {
    return cachedOrg.IsSandbox;
  }
}
