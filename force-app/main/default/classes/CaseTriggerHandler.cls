/**
 * @author Pavan Kumar Ananta
 * @since 02/2020
 * @description  CaseTriggerHandler is the handler class for Case Trigger which extends Lib_TriggerHandler the trigger framework used.
 * We are checking recursion in after update so that update doesnt get called repeatedly for the same transaction.
 * Recursion is checked based on https://help.salesforce.com/articleView?id=000332407&type=1&mode=1
 */

public with sharing class CaseTriggerHandler extends Lib_TriggerHandler {
  private List<Case> updateCaseList = new List<Case>();

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public CaseTriggerHandler() {
    super();
  }

  /**
   * @description onApplyDefaults method is called before onBeforeInsert to set the default values for the records.
   */
  public override void onApplyDefaults() {
    IDRCaseActions.applyDefaults((List<Case>) records);
  }

  /**
   * @description onValidate() method is called before onAfterInsert to validate records or handle the records for which we need to update the values.
   */
  public override void onValidate() {
    for (Case record : (List<Case>) records) {
      Case caseToBeUpdated = new Case(ID = record.ID);
      updateCaseList.add(caseToBeUpdated);
    }
    IDRCaseActions.afterInsert(records);
    CaseCommonActions.copyCaseNumber(records, updateCaseList);
  }

  /**
   * @description onValidate(oldMap) is called before onAfterUpdate and all the required record updates are handled here
   * @param oldMap old trigger values
   */
  public override void onValidate(Map<Id, SObject> oldMap) {
    for (Case record : (List<Case>) records) {
      if (!CheckRecursive.SetOfIDs.contains(record.Id)) {
        Case caseToBeUpdated = new Case(ID = record.ID);
        updateCaseList.add(caseToBeUpdated);
        CheckRecursive.setOfIDs.add(record.ID);
      }
    }
    IDRCaseActions.afterUpdate(oldMap, records, updateCaseList);
    CaseCommonActions.copyCaseNumber(records, updateCaseList);
  }

  /**
   * @description onBeforeDelete
   */
  public override void onBeforeDelete() {
    IDRCaseActions.onBeforeDelete(records);
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    if (
      Case.sObjectType.getDescribe().isUpdateable() && !updateCaseList.isEmpty()
    ) {
      update updateCaseList;
    }
    CaseCommonActions.generateCaseDurationList((List<Case>) Trigger.New);
    IDRCaseActions.completeAfterActions();
    CaseCommonActions.completeAfterInsertActions(updateCaseList);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    if (
      Case.sObjectType.getDescribe().isUpdateable() && !updateCaseList.isEmpty()
    ) {
      update updateCaseList;
    }

    CaseCommonActions.handleCaseDurationGeneration(
      Trigger.new,
      Trigger.newMap,
      oldMap
    );

    IDRCaseActions.completeAfterActions();
    CaseCommonActions.completeAfterUpdateActions(updateCaseList);
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Id> caseIds = new List<Id>();
    List<Case> validateCaseList = new List<Case>();
    List<Case> caseListRecords = new List<Case>();
    for (Case record : (List<Case>) records) {
      Case oldRecord = (Case) oldMap.get(record.id);
      if (
        String.isNotBlank(record.ParentId) &&
        record.RecordTypeId == GetHelpCaseActions.GENERAL_INQUIRY_RT_ID &&
        record.ParentId != oldRecord.ParentId
      ) {
        caseIds.add(record.id);
        validateCaseList.add(record);
      }

      if (
        record.id == oldRecord.id &&
        record.RecordTypeId == GetHelpCaseActions.GENERAL_INQUIRY_RT_ID &&
        (record.Type != oldRecord.Type ||
        record.Additional_Type__c != oldRecord.Additional_Type__c)
      ) {
        caseListRecords.add(record);
      }
    }

    if (!caseIds.isEmpty()) {
      GetHelpCaseActions.validateParentCase(caseIds, validateCaseList);
    }

    if (!caseListRecords.isEmpty()) {
      GetHelpCaseActions.validateAdditionalTypes(records);
    }
  }

  public override void onBeforeInsert() {
    List<Case> records = new List<Case>();
    GetHelpCaseActions.validateAdditionalTypes(records);
  }
}
