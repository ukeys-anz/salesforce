/**
 * @author Karen Valeriano
 * @since August 2025
 * @description Repository class for Dispute object.
 */
public with sharing class DisputedTransactionRepository {
  /**
   * @description Gets the related Fraud Dispute records for the given Case Ids.
   * @param caseIds Set of Case Ids
   * @return Map of Case Ids to their related Dispute records
   */
  public List<Map<String, Object>> getRelatedAggregatedDisputes(
    Set<Id> caseIds
  ) {
    List<Map<String, Object>> results = new List<Map<String, Object>>();
    if (caseIds == null || caseIds.isEmpty()) {
      return results;
    }
    for (AggregateResult ar : [
      SELECT
        CaseId,
        Case.RecordTypeId,
        SUM(TotalRecoveryAmount__c) TotalRecoveryAmount__c,
        SUM(TotalTransactionAmount__c) TotalTransactionAmount__c
      FROM Dispute
      WHERE RecordTypeId = :RTDispute.disputedTransaction AND CaseId IN :caseIds
      WITH USER_MODE
      GROUP BY CaseId, Case.RecordTypeId
    ]) {
      results.add(ar.getPopulatedFieldsAsMap());
    }
    return results;
  }

  /**
   * @description Gets the related DisputeItem records.
   * @param disputeIds Set of Dispute Ids
   * @return List of DisputeItem records
   */
  public List<DisputeItem> getDisputedTransactionItems(Set<Id> disputeIds) {
    if (disputeIds == null || disputeIds.isEmpty()) {
      return new List<DisputeItem>();
    }
    return [
      SELECT Id, Case__c, TransactionIdentifier
      FROM DisputeItem
      WHERE
        RecordTypeId = :RTDisputeItem.disputedTransaction
        AND DisputeId IN :disputeIds
      WITH USER_MODE
    ];
  }
}
