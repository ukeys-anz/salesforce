/**
 * @author Batya Aisman Sufrin
 * @since Aug 2025
 * @description Repository class for managing fraud case transactions
 */
public with sharing class FraudCaseTransactionsRepository {
  /**
   * @description Fetches all disputes associated with a given case ID
   * @param caseId The ID of the case to fetch disputes for
   * @return A list of disputes associated with the given case ID
   */
  public List<DisputeItem> getDisputeItemsByCaseId(Id caseId) {
    if (caseId == null) {
      return new List<DisputeItem>();
    }

    return [
      SELECT
        Id,
        Name,
        Case__c,
        DisputeId,
        AccountDetails__c,
        TransactionIdentifier
      FROM DisputeItem
      WHERE
        Case__c = :caseId
        AND RecordType.DeveloperName = 'Disputed_Transaction'
      WITH USER_MODE
    ];
  }
}
