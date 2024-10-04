/**
 * @author Naman Garg
 * @since 09/2024
 * @description This class provide SOQL and DML helper for class related to CommercialContactActionsHelper.
 */

public with sharing class CommercialAccountRepository {
  /**
   * @description It will fetch the accounts related to contacts
   * @param accIds Set of accountIds
   * @return List<Account> return List of Accounts
   */
  public List<Account> fetchAccounts(Set<Id> accIds) {
    if (!PermissionUtils.canQuery('Account')) {
      return new List<Account>();
    }
    return [
      SELECT
        Id,
        Is_Prospect__c,
        isPersonAccount,
        RecordTypeId,
        FinServ__Status__c,
        Source_System_Name__c,
        ANZx_Customer__c
      FROM Account
      WHERE Id IN :accIds
    ];
  }
}
