/**
 * @author Karen Valeriano
 * @since August 2025
 * @description Repository class for DisputeItem object.
 */
public with sharing class DisputedTransactionItemRepository {
  /**
   * @description Gets the related DisputeItem records count.
   * @param disputeIds Set of Dispute Ids
   * @return Map of Dispute Ids to their related DisputeItem count
   */
  public List<Map<String, Object>> getRelatedDisputeItemsCount(
    Set<Id> disputeIds
  ) {
    List<Map<String, Object>> results = new List<Map<String, Object>>();
    if (disputeIds == null || disputeIds.isEmpty()) {
      return results;
    }
    for (AggregateResult ar : [
      SELECT DisputeId, COUNT(Id) DisputeItems
      FROM DisputeItem
      WHERE
        RecordTypeId = :RTDisputeItem.disputedTransaction
        AND DisputeId IN :disputeIds
      WITH USER_MODE
      GROUP BY DisputeId
    ]) {
      results.add(ar.getPopulatedFieldsAsMap());
    }
    return results;
  }
}
