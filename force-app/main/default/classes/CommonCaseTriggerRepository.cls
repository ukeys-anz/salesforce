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
