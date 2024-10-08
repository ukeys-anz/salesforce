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
    GetHelpCaseActions.handleBOHFraudCaseCreation(records);
    GetHelpCaseActions.populateFieldsOfPayToDispute(records);
    GetHelpCaseActions.handlePopulateCaseSubject(records, null);
    GetHelpCaseActions.setPriority(records);
    GetHelpCaseActions.updateEntitlement(records);
    GetHelpCaseActionsHelper.populateContactLookupForANZPlus(records, null);
    GetHelpCaseActions.checkOpenDisputeOnTransaction(records);
    GetHelpCaseActions.validateFinancialAccByAccId(records);
    GetHelpCaseActions.populateCustomerDetailsOnComplaint(records);
    GetHelpCaseActions.handleProvisionallyClosedDateTimeField(null, records);
    GetHelpCaseActions.setOwnerToIDOpsQueue(records);
    GetHelpCaseActionsHelper.setFraudCustomerProfileCase(
      (List<Case>) records,
      null
    );
    CustomerDisputeManagementService.restrictDisputeCreationIfLimitReached(
      records
    );

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
    SICaseActions.processMonitoringTasks(records, new Map<Id, Case>());
    GetHelpCaseActions.handleDisputesPEGAIntegration(records, null);
    CaseCEController.publishCloudEvents(records);
    GetHelpCaseActions.copyCreditReferralCaseNumbers(records);
    IDR_CaseReportingCalculations.calculateCaseOpenTime(
      (List<Case>) records,
      (new Map<ID, Case>())
    );
    System.enqueueJob(new QueueCaseMilestoneTargetDate(records));
    // Update or Insert CDM record based on number of active self service dispute cases associated to the customer on case insert
    CustomerDisputeManagementService.handleCustomerDisputeManagementActions(
      records,
      new Map<Id, Case>()
    );
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
    GetHelpCaseActions.handleProvisionallyClosedDateTimeField(oldMap, records);
    GetHelpCaseActions.updateEntitlementOnConvertedCase(
      (Map<Id, Case>) oldMap,
      (List<Case>) records
    );
    GetHelpCaseActionsHelper.populateContactLookupForANZPlus(
      records,
      (Map<Id, Case>) oldMap
    );
    GetHelpCaseActionsHelper.setFraudCustomerProfileCase(
      (List<Case>) records,
      (Map<Id, Case>) oldMap
    );
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
      GetHelpCaseActions.populateCustomerDetailsOnComplaint(records);
    }
    GetHelpCaseActions.validateCreditReferralOwnershipChange(
      records,
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
    IDR_CaseReportingCalculations.calculateCaseOpenTime(
      (List<Case>) records,
      (Map<ID, Case>) oldMap
    );
    SICaseActions.processMonitoringTasks(records, new Map<Id, Case>());
    GetHelpCaseActions.handleSLANotifications(records, (Map<Id, Case>) oldMap);
    GetHelpCaseActions.handleDisputesPEGAIntegration(
      records,
      (Map<Id, Case>) oldMap
    );
    CaseCEController.publishCloudEvents(records, (Map<Id, Case>) oldMap);
    GetHelpCaseActions.createTaskOnDisputeCaseClosure(
      (List<Case>) records,
      (Map<Id, Case>) oldMap
    );

    ToastAlertService.publishRecordMonitoringEvent(
      new Map<String, Object>(),
      ToastAlertService.checkCRAssessmentResults(
        records,
        (Map<Id, Case>) oldMap
      )
    );

    //Update or Insert CDM record based on number of active self service dispute cases associated to the customer on case update
    CustomerDisputeManagementService.handleCustomerDisputeManagementActions(
      records,
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
        if (c.RecordTypeId == RTCase.generalInquiry) {
          bugIdSet.add(c.Related_Bug__c);
        }
      }
      GetHelpCaseActions.futureRollupRelatedBug(bugIdSet);
    }
    Logger.debug('On_Before_Delete finished: ' + System.now());
    Logger.saveLog();
  }
}
