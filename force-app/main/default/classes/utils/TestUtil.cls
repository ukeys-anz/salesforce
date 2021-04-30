/**
 * @author Lance Shi
 * @since  March 2021
 * @description This class is to provide generic setups configs for unit tests.
 * @group Utils
 */
@isTest
public with sharing class TestUtil {
  /**
   * @param psNameList permission name list
   * @description Add required PermissionSet
   */
  public static void addPermissionSets(List<String> psNameList) {
    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :psNameList
    ];
    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = UserInfo.getUserId(),
        PermissionSetId = ps.Id
      );
      psaList.add(psa);
    }

    insert psaList;
  }
}
