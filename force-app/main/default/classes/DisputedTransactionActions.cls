/**
 * @author Karen Valeriano
 * @since August 2025
 * @description Actions for Disputes
 */
public with sharing class DisputedTransactionActions {
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final DisputedTransactionRepository REPO = (DisputedTransactionRepository) Lib_InstanceProvider.forType(
    DisputedTransactionRepository.class
  );

  /**
   * @description Sums up all the disputes' TotalRecoveryAmount and TotalTransactionAmount
   * and updates the associated Case with these values.
   * It updates the Fraud_Total_Scam_Value__c or Fraud_Total_Fraud_Value__c, and Fraud_Total_Recovered__c
   * depending on the Case RecordTypeId.
   * @param records list of Dispute records
   * @param oldMap map of old Dispute records
   */
  public static void processDisputesForRollup(
    List<Dispute> records,
    Map<Id, Dispute> oldMap
  ) {
    Set<SObjectField> fieldsToCheck = new Set<SObjectField>{
      Dispute.TotalRecoveryAmount__c,
      Dispute.TotalTransactionAmount__c
    };
    List<Dispute> filteredList = ListUtil.filter(records, oldMap)
      .anyChanged(fieldsToCheck)
      .toList();

    calculateDisputeTotalAmounts(filteredList);
  }

  /**
   * @description Creates a CaseComment for each Case associated to the parent's child DisputeItems.
   * @param records list of deleted Dispute records
   */
  public static void processCaseComments(List<Dispute> records) {
    Set<Id> disputeIds = ListUtil.getIds(records, Dispute.Id);
    List<DisputeItem> transactionsList = REPO.getDisputedTransactionItems(
      disputeIds
    );
    DisputedTransactionItemActions.processCaseComments(transactionsList);
  }

  /**
   * @description Process the TotalRecoveryAmount and TotalTransactionAmount
   * of all related Dispute records and updates the associated Case records.
   * @param records list of Dispute records
   */
  public static void calculateDisputeTotalAmounts(List<Dispute> records) {
    Set<Id> caseIds = ListUtil.getIds(records, Dispute.CaseId);
    List<Map<String, Object>> results = REPO.getRelatedAggregatedDisputes(
      caseIds
    );
    List<Case> casesToUpdate = getCasesForRollupUpdates(results);
    DML.doUpdate(casesToUpdate);
  }

  /**
   * @description Get the case records for rollup updates
   * @param results aggregated dispute results
   * @return list of Case records to update
   */
  @TestVisible
  private static List<Case> getCasesForRollupUpdates(
    List<Map<String, Object>> results
  ) {
    Map<ID, SObjectField> rtFieldMap = new Map<ID, SObjectField>{
      RTCase.scam => Case.Fraud_Total_Scam_Value__c,
      RTCase.fraud => Case.Fraud_Total_Fraud_Value__c,
      RTCase.recipientMule => Case.Fraud_Total_Fraud_Received__c
    };
    List<Case> casesToUpdate = new List<Case>();

    for (Map<String, Object> result : results) {
      Id caseId = (Id) result.get('CaseId');
      Id recordTypeId = (Id) result.get('RecordTypeId');
      Decimal totalRecoveryAmount = (Decimal) result.get(
        'TotalRecoveryAmount__c'
      );
      Decimal totalTransactionAmount = (Decimal) result.get(
        'TotalTransactionAmount__c'
      );
      Case caseRec = new Case(
        Id = caseId,
        Fraud_Total_Recovered__c = totalRecoveryAmount
      );
      if (rtFieldMap.containsKey(recordTypeId)) {
        caseRec.put(rtFieldMap.get(recordTypeId), totalTransactionAmount);
      }
      casesToUpdate.add(caseRec);
    }
    return casesToUpdate;
  }
}
