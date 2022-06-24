/**
 * @author Lance Shi
 * @since  March 2021
 * @description This class is called as a wrapper for all the account queries
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class AccountQueryHelper {
  /**
   * @description findAccountsByAccountId is to query accounts based on Id
   * @param accountId the id to be queried
   * @return List<Account> the queried account list
   */
  public List<Account> findAccountsByAccountId(String accountId) {
    List<Account> accounts = [
      SELECT OCV_ID__c, PPID__c
      FROM Account
      WHERE Id = :accountId
    ];
    return accounts;
  }

  /**
   * @description find accounts based on a set of Ids
   * @param accountIds Set of account ids to search
   * @return List<Account> the result of accounts
   */
  public List<Account> findAccountsByAccountIds(Set<Id> accountIds) {
    List<Account> accounts = new List<Account>();
    if (Account.SObjectType.getDescribe().isQueryable()) {
      accounts = [
        SELECT Id, Name, PersonContactId, FirstName, PersonEmail
        FROM Account
        WHERE Id IN :accountIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'AccountQueryHelper',
        'findAccountsByAccountIds',
        'Not enough permissions to query Accounts.'
      );
    }
    return accounts;
  }
}
