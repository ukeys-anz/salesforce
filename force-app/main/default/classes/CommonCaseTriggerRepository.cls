/**
 * @author Batya Aisman Sufrin
 * @since April 2025
 * @description Common actions for ANZPlus cases
 */
public with sharing class CommonCaseTriggerRepository {
  /**
   * @description Queries accounts based on Account Ids
   * @param accountIds Set of account Ids to search
   * @return A list of Account records
   */
  public List<Account> queryAccountsByIdSystemMode(Set<Id> accountIds) {
    return new SystemAction().queryAccountsById(accountIds);
  }

  /**
   * @description Queries cases by Ids that are missing the custom CaseNumber__c value.
   *  * SYSTEM_MODE for backward compatibility since this field need to be get/set org wide
   * @param caseIds Set of Case record Ids to search.
   * @return A list of Case records where CaseNumber__c is null.
   */
  public List<Case> queryCasesWithoutCaseNumber(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT Id, CaseNumber
      FROM Case
      WHERE Id IN :caseIds AND CaseNumber__c = NULL
      WITH SYSTEM_MODE
    ];
  }

  private without sharing class SystemAction {
    /**
     * @description Queries accounts based on Account Ids
     * @param accountIds Set of account Ids to search
     * @return A list of Account records
     */
    public List<Account> queryAccountsById(Set<Id> accountIds) {
      if (accountIds.isEmpty()) {
        return new List<Account>();
      }
      return [
        SELECT Id, IsPersonAccount, PersonContactId
        FROM Account
        WHERE Id IN :accountIds
        WITH SYSTEM_MODE
      ];
    }
  }
}
