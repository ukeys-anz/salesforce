/**
 * @author Peter Charalambous
 * @since Tue Jun 03 2025
 * @description SettlementRepository is a repository class for settlement related queries
 */
public with sharing class SettlementRepository {
  /**
   * @description Retrieves a settlement record by its ID
   * @param recordId The ID of the settlement record to retrieve
   * @return `Settlement__c` The settlement record
   */
  public Settlement__c getSettlement(String recordId) {
    PermissionUtils.canQuery('Settlement__c');

    return [
      SELECT Id, Settlement_ID__c, Loan_Application_Number__r.Account.OCV_ID__c
      FROM Settlement__c
      WHERE Id = :recordId
    ];
  }
}
