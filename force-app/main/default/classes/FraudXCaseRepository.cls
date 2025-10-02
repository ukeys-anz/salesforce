/**
 * @author Karen Valeriano
 * @since August 2025
 * @description Actions for FraudX Case
 */
public with sharing class FraudXCaseRepository {
  /**
   * @description Get the associated Dispute records for the given Case Ids.
   * @param caseIds Set of Case Ids
   * @return List of Dispute records
   */
  public List<Dispute> getRelatedDisputes(Set<Id> caseIds) {
    if (caseIds == null || caseIds.isEmpty()) {
      return new List<Dispute>();
    }
    return [
      SELECT Id, CaseId, OwnerId
      FROM Dispute
      WHERE RecordTypeId = :RTDispute.disputedTransaction AND CaseId IN :caseIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Get the associated Dispute Item records for the given Case Ids.
   * @param caseIds Set of Case Ids
   * @return List of Dispute Item records
   */
  public List<DisputeItem> getTxnItemsByRecoveryStatus(Set<Id> caseIds) {
    if (caseIds == null || caseIds.isEmpty()) {
      return new List<DisputeItem>();
    }

    Set<String> recoveryStatusSet = new Set<String>{
      'Pending OFI Response',
      '7-Day Sent',
      'Recovery Pledged'
    };
    return [
      SELECT Id, Case__c, RecoveryStatus__c
      FROM DisputeItem
      WHERE
        RecordTypeId = :RTDisputeItem.disputedTransaction
        AND Case__c IN :caseIds
        AND (RecoveryStatus__c IN :recoveryStatusSet
        OR RecoveryStatus__c = NULL)
      WITH USER_MODE
    ];
  }
}
