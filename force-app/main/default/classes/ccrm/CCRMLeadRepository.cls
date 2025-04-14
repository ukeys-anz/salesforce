/**
 * @author Naman Garg
 * @since 07/2024
 * @description This class provide SOQL and DML helper for class related to CCRMLeadActions.
 */

public with sharing class CCRMLeadRepository {
  /**
   * @description It will fetch the user Profile Id
   * @return Id Profile Id of the current user
   */
  public Id getUserProfileId() {
    return UserInfo.getProfileId();
  }

  /**
   * @description to query accounts
   * @name getRelatedAccounts
   * @param accountIds set of Account Ids
   * @return List<Account>
   */
  public List<Account> getRelatedAccounts(Set<String> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT
        Id,
        Source_System_ID__c,
        Source_System_Name__c,
        Name,
        FinServ__CustomerType__c,
        RecordTypeId
      FROM Account
      WHERE
        Source_System_Name__c = :System.Label.CCRM_Source_System_Name
        AND Source_System_ID__c IN :accountIds
      WITH USER_MODE
    ];
  }
}
