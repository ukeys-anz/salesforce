/**
 * @description Provide methods for Databse operations on Account object
 * @author Nakul Kumar
 * @since 02/2025
 */
public with sharing class AccountRepository {
  /**
   * @description get account records
   * @param accountIds set of account ids
   * @return Map<Id, Account> map of account ids and account records
   */
  public Map<Id, Account> getAccountsWithExternalId(Set<Id> accountIds) {
    return new Map<Id, Account>(
      [
        SELECT External_Id__c
        FROM Account
        WHERE Id IN :accountIds
        WITH USER_MODE
      ]
    );
  }
}
