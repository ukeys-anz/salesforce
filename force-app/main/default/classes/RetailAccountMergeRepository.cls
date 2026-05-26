/**
 * @author Lance Shi
 * @since 04/2026
 * @description This class provides SOQL helper for class related to RetailBrokerAccountActions.
 */
public with sharing class RetailAccountMergeRepository {
  /**
   * @description Gets list of accounts by external Ids
   * @param survivorExternalIdList Account External Ids
   * @return List<Account> List of accounts
   */
  public List<Account> queryAccountRecordsByExternalIds(
    Set<String> survivorExternalIdList
  ) {
    if (survivorExternalIdList.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, External_Id__c, Survivor_Party_ID__c, Victim_External_ID__c
      FROM Account
      WHERE External_Id__c IN :survivorExternalIdList
      WITH USER_MODE
    ];
  }
}
