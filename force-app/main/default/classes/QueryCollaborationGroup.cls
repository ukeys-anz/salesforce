/**
 * @author CMOS
 * @since AUG 2025
 * @description Holds cached Collaboration Group records
 */
public with sharing class QueryCollaborationGroup {
  @TestVisible
  private static Map<String, CollaborationGroup> collGroups = new Map<String, CollaborationGroup>();
  static {
    for (CollaborationGroup colObj : [
      SELECT Id, name
      FROM CollaborationGroup
      WITH SYSTEM_MODE
    ]) {
      collGroups.put(colObj.Name, colObj);
    }
  }

  /**
   * @description Get Collaboration Group by Group Name
   * @param groupName name of the Collboration Group
   * @return CollaborationGroup
   */
  public static CollaborationGroup getByName(String groupName) {
    return collGroups.get(groupName);
  }
}
