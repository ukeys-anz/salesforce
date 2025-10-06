/**
 * @author Karen Valeriano
 * @since August 2025
 * @description Actions for Disputed Transaction Items
 */
public with sharing class DisputedTransactionItemActions {
  @TestVisible
  private static final String CASE_COMMENT = 'Deleted {0} Transactions from the Case.';
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final DisputedTransactionItemRepository REPO = (DisputedTransactionItemRepository) Lib_InstanceProvider.forType(
    DisputedTransactionItemRepository.class
  );

  /**
   * @description Filters and processes the deleted DisputeItems.
   * It creates a CaseComment for each Case associated to the deleted DisputeItems.
   * The CaseComment lists the TransactionIdentifiers of the deleted DisputeItems
   * and posts it to the associated Case.
   * @param records list of DisputeItems records
   */
  public static void processCaseComments(List<DisputeItem> records) {
    Map<Id, List<DisputeItem>> disputeItemsByCase = (Map<Id, List<DisputeItem>>) ListUtil.groupBy(
      records,
      DisputeItem.Case__c
    );
    List<CaseComment> caseComments = generateCaseComments(disputeItemsByCase);
    DML.doInsert(caseComments);
  }

  /**
   * @description Creates CaseComments for the deleted DisputeItems.
   * @param disputeItemsByCase map of CaseId and DisputeItems
   * @return list of CaseComments to be posted
   */
  @TestVisible
  private static List<CaseComment> generateCaseComments(
    Map<Id, List<DisputeItem>> disputeItemsByCase
  ) {
    List<CaseComment> caseComments = new List<CaseComment>();

    for (Id caseId : disputeItemsByCase.keySet()) {
      Set<String> transactionIds = ListUtil.getStrings(
        disputeItemsByCase.get(caseId),
        DisputeItem.TransactionIdentifier
      );
      String caseComment = String.format(
        CASE_COMMENT,
        new List<String>{ String.join(transactionIds, ', ') }
      );
      caseComments.add(
        new CaseComment(ParentId = caseId, CommentBody = caseComment)
      );
    }
    return caseComments;
  }

  /**
   * @description Checks if there are no more DisputeItems linked to the Dispute
   * and deletes the Dispute if there are no more related DisputeItems.
   * @param records DisputeItem records from trigger
   */
  public static void processParentDisputeDeletion(List<DisputeItem> records) {
    Set<Id> disputeIds = ListUtil.getIds(records, DisputeItem.DisputeId);
    List<Map<String, Object>> results = REPO.getRelatedDisputeItemsCount(
      disputeIds
    );
    List<Dispute> disputesForDeletion = generateDisputesForDeletion(
      results,
      disputeIds
    );
    DML.doDelete(disputesForDeletion);
  }

  /**
   * @description Create list of Dispute records for deletion
   * by removing those that have remaining linked items from the set
   * @param results The result records of related DisputeItems
   * @param disputeIds Set of Dispute Ids to be deleted
   * @return List of Dispute records for deletion
   */
  @TestVisible
  private static List<Dispute> generateDisputesForDeletion(
    List<Map<String, Object>> results,
    Set<Id> disputeIds
  ) {
    Set<Id> idWithItems = new Set<Id>();
    for (Map<String, Object> result : results) {
      idWithItems.add((Id) result.get('DisputeId'));
    }
    disputeIds.removeAll(idWithItems);

    List<Dispute> disputesForDeletion = new List<Dispute>();
    for (Id disputeId : disputeIds) {
      disputesForDeletion.add(new Dispute(Id = disputeId));
    }
    return disputesForDeletion;
  }
}
