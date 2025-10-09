/**
 * @author Batya Aisman Sufrin
 * @since Aug 2025
 *  @description Controller for managing fraud case transactions
 */
public with sharing class FraudCaseTransactionsController {
  private static final FraudCaseTransactionsRepository FRAUD_CASE_TRANSACTIONS_REPO = (FraudCaseTransactionsRepository) Lib_InstanceProvider.forType(
    FraudCaseTransactionsRepository.class
  );
  private static final DmlRepository DML_REPO = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final String MSG_ERROR_GENERIC = 'Error fetching ispute Items. Please contact your System Administrator.';
  private static final String MSG_SUCCESS_LINKED_TRANSACTIONS = 'Linked {0} Transaction(s) to the Case';

  /**
   * @description Fetches disputes and their items for a given case ID.
   * @param caseId The ID of the case for which to fetch disputes.
   * @return A list of dispute items associated with the case.
   */
  @AuraEnabled
  public static List<DisputeItem> getDisputeItemsByCaseId(Id caseId) {
    try {
      return FRAUD_CASE_TRANSACTIONS_REPO.getDisputeItemsByCaseId(caseId);
    } catch (Exception e) {
      throw CommonUtil.logAuraExceptionInfo(MSG_ERROR_GENERIC, caseId, e);
    }
  }

  /**
   * @description Saves a dispute and its associated items.
   * @param disputeAccount The dispute to save.
   * @param itemsToAdd The items associated with the dispute.
   * @param itemsToRemove The items to remove from the dispute.
   */
  @AuraEnabled
  public static void saveDisputeWithItems(
    Dispute disputeAccount,
    List<DisputeItem> itemsToAdd,
    List<DisputeItem> itemsToRemove
  ) {
    try {
      if (disputeAccount.Id == null) {
        disputeAccount.RecordTypeId = RTDispute.disputedTransaction;
        DML_REPO.doInsert(disputeAccount);
      }

      Map<SObjectField, Object> diValues = new Map<SObjectField, Object>{
        DisputeItem.DisputeId => disputeAccount.Id,
        DisputeItem.RecordTypeId => RTDisputeItem.disputedTransaction
      };

      ListUtil.setField(itemsToAdd, diValues);
      DML_REPO.doInsert(itemsToAdd);
      if (!itemsToAdd.isEmpty()) {
        CaseComment cComment = new CaseComment(
          ParentId = disputeAccount.CaseId,
          CommentBody = String.format(
            MSG_SUCCESS_LINKED_TRANSACTIONS,
            new List<Integer>{ itemsToAdd.size() }
          )
        );
        DML_REPO.doInsert(cComment);
      }

      DML_REPO.doDelete(itemsToRemove);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
