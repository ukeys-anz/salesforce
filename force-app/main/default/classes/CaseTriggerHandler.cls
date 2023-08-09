/**
 * @author Pavan Kumar Ananta
 * @since 02/2020
 * @description  CaseTriggerHandler is the handler class for Case Trigger which extends Lib_TriggerHandler the trigger framework used.
 * We are checking recursion in after update so that update doesnt get called repeatedly for the same transaction.
 * Recursion is checked based on https://help.salesforce.com/articleView?id=000332407&type=1&mode=1
 */

public with sharing class CaseTriggerHandler extends Lib_TriggerHandler {
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
    Logger.debug('On_Apply_Default started: ' + System.now());
    IDRCaseActions.applyDefaults((List<Case>) records);
    SICaseActions.applyDefaults((List<Case>) records);
    GetHelpCaseActions.applyDefaults((List<Case>) records);
    Logger.debug('On_Apply_Default finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    Logger.debug('On_Before_Insert started: ' + System.now());
    GetHelpCaseActions.validateAdditionalTypes(records, null);
    GetHelpCaseActions.handlePopulateCaseSubject(records, null);
    GetHelpCaseActions.setPriority(records);
    GetHelpCaseActions.updateEntitlement(records);
    GetHelpCaseActionsHelper.populateContactLookupForANZPlus(records);
    GetHelpCaseActions.checkOpenDisputeOnTransaction(records);
    GetHelpCaseActions.validateFinancialAccByAccId(records);
    GetHelpCaseActions.populateOCVOnComplaint(records);
    GetHelpCaseActions.validateDuplicateKYCQACasePerAccount(records);
    GetHelpCaseActions.populateKYCQACasesClosedNoDefectDefaults(records);
    GetHelpCaseActionsHelper.setFraudCustomerProfileCase(records);
    Logger.debug('On_Before_Insert finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onValidate() method is called before onAfterInsert to validate records or handle the records for which we need to update the values.
   */
  public override void onValidate() {
    Logger.debug('On_Validate_before_AfterInsert started: ' + System.now());
    IDRCaseActions.afterInsert(records);
    Logger.debug('On_Validate_before_AfterInsert finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    Logger.debug('On_After_Insert started: ' + System.now());
    IDRCaseActions.completeAfterActions();
    SICaseActions.afterInsert(records);
    GetHelpCaseActions.handleDisputesPEGAIntegration(records, null);
    CaseCEController.publishCloudEvents(records);
    Logger.debug('On_After_Insert finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_Before_Update started: ' + System.now());
    GetHelpCaseActions.beforeUpdateCaseToCMOS(records);
    IDRCaseActions.beforeUpdate(oldMap, records);
    GetHelpCaseActions.beforeUpdate(oldMap, records);
    GetHelpCaseActions.updateEntitlementOnConvertedCase(
      (Map<Id, Case>) oldMap,
      (List<Case>) records
    );
    GetHelpCaseActionsHelper.populateContactLookupForANZPlus(records);
    GetHelpCaseActionsHelper.setFraudCustomerProfileCase(records);
    SICaseActions.beforeUpdate((List<Case>) records, (Map<Id, Case>) oldMap);
    GetHelpCaseActions.handlePopulateCaseSubject(records, null);
    for (Case record : (List<Case>) records) {
      if (CheckCaseRecordType.isANZPlusCaseType(record)) {
        GetHelpCaseActions.maskTaxNumbers(record);
      }
      Case oldrecord = (Case) oldMap.get(record.Id);
      if (
        !oldRecord.IDR_Additional_Correspondence_reviewed__c &&
        record.IDR_Additional_Correspondence_reviewed__c
      ) {
        record.IDR_Correspondence_Reviewed_Date__c = Date.today();
      }
    }
    IDRCaseNotificationManager.manageNotification(
      records,
      (Map<Id, Case>) oldMap
    );
    //Check if the account on the case has updated, if so, update OCV ID
    if (
      GetHelpCaseActionsHelper.hasAccountUpdated(
        records,
        (Map<Id, Case>) oldMap
      )
    ) {
      GetHelpCaseActions.populateOCVOnComplaint(records);
    }
    GetHelpCaseActions.linkKYCQACasesToAccount(
      (List<Case>) records,
      (Map<Id, Case>) oldMap
    );
    Logger.debug('On_Before_Update finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onValidate(oldMap) is called before onAfterUpdate and all the required record updates are handled here
   * @param oldMap old trigger values
   */
  public override void onValidate(Map<Id, SObject> oldMap) {
    Logger.debug('On_Validate_before_AfterUpdate started: ' + System.now());
    IDRCaseActions.afterUpdate(oldMap, records);
    GetHelpCaseActions.afterUpdate(oldMap, records);
    Logger.debug('On_Validate_before_AfterUpdate finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    Logger.debug('On_After_Update started: ' + System.now());
    IDRCaseActions.completeAfterActions();
    GetHelpCaseActions.completeAfterActions();
    SICaseActions.afterUpdate(records, (Map<Id, Case>) oldMap);
    GetHelpCaseActions.handleSLANotifications(records, (Map<Id, Case>) oldMap);
    GetHelpCaseActions.handleDisputesPEGAIntegration(
      records,
      (Map<Id, Case>) oldMap
    );
    CaseCEController.publishCloudEvents(records, (Map<Id, Case>) oldMap);
    GetHelpCaseActions.createFraudCheckCase(
      (List<Case>) records,
      (Map<Id, Case>) oldMap
    );
    //Update ID Ops Case's status (parent) following the Fraud Check case's (child) status update. Using afterUpdate context as the child must be closed before the parent's status can be updated.
    GetHelpCaseActions.updateIdOpsCaseStatus(records, (Map<Id, Case>) oldMap);
    // craete task for dispute cases on case closure
    GetHelpCaseActions.createTaskOnDisputeCaseClosure(
      (List<Case>) records,
      (Map<Id, Case>) oldMap
    );
    Logger.debug('On_After_Update finished: ' + System.now());
    Logger.saveLog();
  }

  /**
   * @description onBeforeDelete
   */
  public override void onBeforeDelete() {
    Logger.debug('On_Before_Delete started: ' + System.now());
    IDRCaseActions.onBeforeDelete(records);
    if (!System.isFuture()) {
      Set<Id> bugIdSet = new Set<Id>();
      for (Case c : (List<Case>) records) {
        if (c.RecordTypeId == GetHelpConstants.GENERAL_INQUIRY_RT_ID) {
          bugIdSet.add(c.Related_Bug__c);
        }
      }
      GetHelpCaseActions.futureRollupRelatedBug(bugIdSet);
    }
    Logger.debug('On_Before_Delete finished: ' + System.now());
    Logger.saveLog();
  }
}
