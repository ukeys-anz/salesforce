/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached PermissionSetGroup records
 */
public with sharing class QueryPSG {
  private static Map<String, PermissionSetGroup> permissionSetGroups = new Map<String, PermissionSetGroup>();
  static {
    for (PermissionSetGroup psg : [
      SELECT Id, DeveloperName
      FROM PermissionSetGroup
      WITH SYSTEM_MODE
    ]) {
      permissionSetGroups.put(psg.DeveloperName, psg);
    }
  }

  /**
   * @description Get PermissionSet by PermissionSetGroup Name
   * @param name name of the PermissionSetGroup
   * @return PermissionSetGroup
   */
  public static PermissionSetGroup get(String name) {
    return permissionSetGroups.get(name);
  }
}
