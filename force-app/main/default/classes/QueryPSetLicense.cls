/**
 * @author CMOS
 * @since AUG 2025
 * @description Holds cached PermissionSetLicense records
 */
public with sharing class QueryPSetLicense {
  @TestVisible
  private static Map<String, PermissionSetLicense> psetLicenseMap = new Map<String, PermissionSetLicense>();
  static {
    for (PermissionSetLicense colObj : [
      SELECT Id, DeveloperName
      FROM PermissionSetLicense
      WITH SYSTEM_MODE
    ]) {
      psetLicenseMap.put(colObj.DeveloperName, colObj);
    }
  }

  /**
   * @description Get PermissionSetLicense by  Name
   * @param passignName name of the PermissionSetLicense
   * @return PermissionSetLicense
   */
  public static PermissionSetLicense getByName(String passignName) {
    return psetLicenseMap.get(passignName);
  }
}
