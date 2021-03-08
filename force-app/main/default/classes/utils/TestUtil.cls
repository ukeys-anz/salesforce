/**
 * @author Lance Shi
 * @since  March 2021
 * @description This class is to provide generic setups configs for unit tests.
 */
@isTest
public with sharing class TestUtil {
  /**
   * @description Add required PermissionSet
   */
  public static void addAccountsGoalsPs() {
    List<PermissionSet> ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'Accounts_Goals_Read_Only'
    ];
    PermissionSetAssignment psa = new PermissionSetAssignment(
      AssigneeId = UserInfo.getUserId(),
      PermissionSetId = ps[0].Id
    );
    insert psa;
  }
}
