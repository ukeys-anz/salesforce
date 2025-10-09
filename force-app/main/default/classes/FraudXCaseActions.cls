/**
 * @author Batya Aisman Sufrin
 * @since 03/2025
 * @description FraudXCaseActions class is to handle all the Fraud Cases (Fraud, Identity, Recipient/Mule and Scam) Actions
 */
public with sharing class FraudXCaseActions {
  private static final FraudXCaseRepository REPO = (FraudXCaseRepository) Lib_InstanceProvider.forType(
    FraudXCaseRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  @TestVisible
  private static final String RECOVERY_STATUS_VALIDATION_ERROR = 'Case cannot be closed with Transaction Recovery Status as Blanks, Pending OFI Response, 7-Day Sent, Recovery Pledged.';
  @TestVisible
  private static final String CUSTOMER_CHANGE_VALIDATION_ERROR = 'Customer cannot be changed if Transactions are linked. Please remove linked transactions to change the Customer.';

  /**
   * @description This method populates subject on Fraud cases based on Record Type and Type
   * @param records Case record from trigger
   * @param oldMap old trigger values
   */
  public static void populateFraudXCaseSubject(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Set<SObjectField> fieldsToTrack = new Set<SObjectField>{
      Case.Type,
      Case.RecordTypeId
    };
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .anyChanged(fieldsToTrack)
      .isNotNull(Case.Type)
      .toList();

    if (filteredCases.isEmpty()) {
      return;
    }

    Map<String, String> caseTypeLabelByValue = CommonUtil.getPicklistLabelsByValues(
      Case.Type
    );
    for (Case record : filteredCases) {
      String rtName = RTCase.get(record.RecordTypeId).Name;
      String label = caseTypeLabelByValue.get(record.Type);
      record.Subject = rtName + ' - ' + label;
    }
  }

  /**
   * @description Gets all related Disputes for the given Case Ids and updates the OwnerId
   * @param records Case records from trigger
   * @param oldMap old trigger values
   */
  public static void changeRelatedDisputeOwner(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .notEquals(Case.RecordTypeId, RTCase.identity) // Exclude Identity cases
      .changed(Case.OwnerId)
      .toList();
    Set<Id> caseIds = ListUtil.getIds(filteredCases, Case.Id);
    List<Dispute> relatedDisputes = REPO.getRelatedDisputes(caseIds);
    List<Dispute> disputesForOwnerUpdates = getDisputesForOwnerUpdates(
      filteredCases,
      relatedDisputes
    );
    DML.doUpdate(disputesForOwnerUpdates);
  }

  /**
   * @description Updates the OwnerId of related Dispute records based on the Case OwnerId.
   * @param cases Case records from trigger
   * @param disputes dispute records to update
   * @return List of Dispute records with updated OwnerId
   */
  @TestVisible
  private static List<Dispute> getDisputesForOwnerUpdates(
    List<Case> cases,
    List<Dispute> disputes
  ) {
    Map<Id, Case> caseMap = new Map<Id, Case>(cases);
    for (Dispute d : disputes) {
      Id caseOwnerId = caseMap.get(d.CaseId).OwnerId;
      if (d.OwnerId != caseOwnerId) {
        d.OwnerId = caseOwnerId;
      }
    }
    return disputes;
  }

  /**
   * @description Checks if any of the linked Transactions have invalid Recovery Status
   * and prevents user from closing the case.
   * @param records Case records from trigger
   * @param oldMap old trigger values
   */
  public static void validateLinkedTxnRecoveryStatus(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .equals(Case.RecordTypeId, RTCase.recipientMule)
      .changedTo(Case.Status, 'Closed')
      .notEquals(Case.Type, 'Not a Recipient')
      .toList();
    Set<Id> caseIds = new Map<Id, Case>(filteredCases).keySet();
    List<DisputeItem> linkedTxnItems = REPO.getTxnItemsByRecoveryStatus(
      caseIds
    );
    Set<Id> linkedCaseIds = ListUtil.getIds(
      linkedTxnItems,
      DisputeItem.Case__c
    );
    List<Case> casesToFail = ListUtil.filter(filteredCases)
      .equals(Case.Id, linkedCaseIds)
      .toList();

    ListUtil.addError(casesToFail, RECOVERY_STATUS_VALIDATION_ERROR);
  }

  /**
   * @description Checks if there are already linked dispute transactions in the case
   * and prevents user from changing the associated customer.
   * @param records Case records from trigger
   * @param oldMap old trigger values
   */
  public static void validateCustomerChange(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .notEquals(Case.RecordTypeId, RTCase.identity)
      .changed(Case.AccountId)
      .toList();
    Set<Id> caseIds = new Map<Id, Case>(filteredCases).keySet();
    List<Dispute> relatedDisputes = REPO.getRelatedDisputes(caseIds);
    Set<Id> linkedCaseIds = ListUtil.getIds(relatedDisputes, Dispute.CaseId);
    List<Case> casesToFail = ListUtil.filter(filteredCases)
      .equals(Case.Id, linkedCaseIds)
      .toList();

    ListUtil.addError(casesToFail, CUSTOMER_CHANGE_VALIDATION_ERROR);
  }
}
