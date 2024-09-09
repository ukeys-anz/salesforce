/**
 * @author Batya Aisman Sufrin
 * @since Aug 2024
 * @description Holds cached PermissionSet records
 */
public with sharing class QueryPS {
  private static Map<String, PermissionSet> permissionSets = new Map<String, PermissionSet>();
  static {
    for (PermissionSet ps : [
      SELECT Id, Name
      FROM PermissionSet
      WITH SYSTEM_MODE
    ]) {
      permissionSets.put(ps.Name, ps);
    }
  }

  /**
   * @description Get PermissionSet by PermissionSet Name
   * @param name name of the PermissionSet
   * @return PermissionSet
   */
  public static PermissionSet get(String name) {
    return permissionSets.get(name);
  }
}
