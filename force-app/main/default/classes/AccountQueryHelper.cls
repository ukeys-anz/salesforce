/**
 * @author Lance Shi
 * @since  March 2021
 * @description This class is called as a wrapper for all the account queries
 */
public with sharing class AccountQueryHelper {
  /**
   * @description findAccountsByAccountId is to query accounts based on Id
   * @param accountId the id to be queried
   * @return List<Account> the queried account list
   */
  public List<Account> findAccountsByAccountId(Id accountId) {
    List<Account> accounts = [
      SELECT OCV_ID__c, PPID__c
      FROM Account
      WHERE Id = :accountId AND ANZx_Customer__c = TRUE
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

  /**
   * @description find accounts based on OCVId
   * @param ocvId list of ocvids to search account details
   * @return map of ocv id and Account
   */
  public static Map<String, Account> findAccountsByOCVId(List<String> ocvId) {
    PermissionUtils.canQuery('Account');
    Map<String, Account> mapOcvIdAccount = new Map<String, Account>();
    for (Account acc : [
      SELECT Name, FirstName, OCV_ID__c
      FROM Account
      WHERE
        OCV_ID__c = :ocvId
        AND RecordTypeId = :GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
        AND ANZx_Customer__c = TRUE
    ]) {
      mapOcvIdAccount.put(acc.OCV_ID__c, acc);
    }
    return mapOcvIdAccount;
  }
}
