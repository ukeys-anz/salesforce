/**
 * @description Provide methods for Databse operations on Account object
 * @author ramvilas
 * @since 05/2025
 */
public with sharing class LendingAccountRepository {
  /**
   * @description get multiple account record details from ocvids
   * @return List<Account>
   * @param ocvIds List of Customers ocvIds
   */
  public List<Account> queryAccountsByOcvIds(List<String> ocvIds) {
    if (ocvIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, Name, OCV_ID__c
      FROM Account
      WHERE OCV_ID__c IN :ocvIds
      WITH USER_MODE
    ];
  }
}
