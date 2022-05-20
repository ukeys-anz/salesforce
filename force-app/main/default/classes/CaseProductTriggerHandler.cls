/**
 * @author Olivier Saier
 * @since 11/2020
 * @description  CaseProductTriggerHandler is the handler class for Case_Product__c which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class CaseProductTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public CaseProductTriggerHandler() {
    super();
  }

  public override void onBeforeInsert() {
    checkDuplicates(records);
  }

  private static final String BULK_DUPLICATES_ERROR_MSG = 'Trying to relate the same product to the same case more than once.';
  private static final String INSUFFICIENT_PERMS_ERROR_MSG = 'Insufficient permissions';
  private static final String SAME_PRODUCT_TO_SAME_CASE_ERROR_MSG = 'Product has already been related to case.';

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Case_Product__c> recordsToCheck = new List<Case_Product__c>();
    for (Integer i = 0; i < records.size(); i++) {
      Case_Product__c rec = (Case_Product__c) records[i];
      Case_Product__c oldRec = (Case_Product__c) oldMap.get(records.get(i).Id);
      if (
        rec.Case__c != oldRec.Case__c ||
        rec.Product__c != oldRec.Product__c
      ) {
        recordsToCheck.add(rec);
      }
    }
    if (recordsToCheck.size() > 0) {
      checkDuplicates(recordsToCheck);
    }
  }

  /**
   * @description Prevents several identical junction records
   * @param records list of Case_Products to process
   */
  private void checkDuplicates(List<Case_Product__c> records) {
    errorIfBulkDuplicates(records);
    errorIfDuplicate(records);
  }

  /**
   * @description Prevents the same product from being related to the same case more than once
   * @param records list of Case_Products to process
   */
  private void errorIfBulkDuplicates(List<Case_Product__c> records) {
    if (records.size() > 1) {
      for (Integer i = 0; i < records.size() - 1; i++) {
        for (Integer j = i + 1; j < records.size(); j++) {
          if (
            records[i].Case__c == records[j].Case__c &&
            records[i].Product__c == records[j].Product__c
          ) {
            records[j].AddError(BULK_DUPLICATES_ERROR_MSG);
            return;
          }
        }
      }
    }
  }

  /**
   * @description Prevents the same product from being related to the same case if it has already been
   * @param records list of Case_Products to process
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  private void errorIfDuplicate(List<Case_Product__c> records) {
    Set<Id> caseIDs = new Set<Id>();
    Set<Id> productIDs = new Set<Id>();
    for (Case_Product__c cp : records) {
      caseIDs.add(cp.Case__c);
      productIDs.add(cp.Product__c);
    }
    Case_Product__c[] cps = new List<Case_Product__c>();
    try {
      cps = [
        SELECT Case__c, Product__c
        FROM Case_Product__c
        WHERE Case__c IN :caseIDs AND Product__c IN :productIDs
        WITH SECURITY_ENFORCED
      ];
    } catch (System.QueryException e) {
      lib_systemLog log = new lib_systemLog(
        CaseProductTriggerHandler.class.getName(),
        'errorIfDuplicate'
      );
      log.error('InsufficientAccessException', e.getMessage(), e.getTypeName());
      log.publishEvent();
      records[0].AddError(INSUFFICIENT_PERMS_ERROR_MSG);
      return;
    }
    if (!cps.isEmpty()) {
      for (Case_Product__c record : records) {
        for (Case_Product__c cp : cps) {
          if (
            record.Case__c == cp.Case__c &&
            record.Product__c == cp.Product__c
          ) {
            record.AddError(SAME_PRODUCT_TO_SAME_CASE_ERROR_MSG);
            return;
          }
        }
      }
    }
  }
}
