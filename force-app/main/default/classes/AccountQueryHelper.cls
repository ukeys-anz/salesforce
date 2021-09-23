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
}
