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
    IDRCaseActions.applyDefaults((List<Case>) records);
    SICaseActions.applyDefaults((List<Case>) records);
    GetHelpCaseActions.applyDefaults((List<Case>) records);
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    GetHelpCaseActions.validateAdditionalTypes(records, null);
    GetHelpCaseActions.handlePopulateCaseSubject(records, null);
    GetHelpCaseActions.setPriority(records);
    GetHelpCaseActions.updateEntitlement(records);
    GetHelpCaseActionsHelper.populateContactLookupForANZPlus(records);
    GetHelpCaseActions.checkOpenDisputeOnTransaction(records);
    GetHelpCaseActions.validateFinancialAccByAccId(records);
    GetHelpCaseActions.populateOCVOnComplaint(records);
    GetHelpCaseActions.populateKYCQACasesClosedNoDefectDefaults(records);
  }

  /**
   * @description onValidate() method is called before onAfterInsert to validate records or handle the records for which we need to update the values.
   */
  public override void onValidate() {
    IDRCaseActions.afterInsert(records);
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    IDRCaseActions.completeAfterActions();
    GetHelpCaseActions.rollupRelatedBug(records, new List<Case>());
    SICaseActions.afterInsert(records);
    GetHelpCaseActions.handleDisputesPEGAIntegration(records, null);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    IDRCaseActions.beforeUpdate(oldMap, records);
    GetHelpCaseActions.beforeUpdate(oldMap, records);
    SICaseActions.beforeUpdate((List<Case>) records, (Map<Id, Case>) oldMap);
    GetHelpCaseActions.handlePopulateCaseSubject(records, null);
    for (Case record : (List<Case>) records) {
      if (GetHelpCaseActionsHelper.isANZPlusCaseType(record)) {
        GetHelpCaseActions.maskTaxNumbers(record);
      }
    }
    IDRCaseNotificationManager.manageNotification(
      records,
      (Map<Id, Case>) oldMap
    );
    GetHelpCaseActions.beforeUpdateCaseToCMOS(records);
    //Check if the account on the case has updated, if so, update OCV ID
    if (
      GetHelpCaseActionsHelper.hasAccountUpdated(
        records,
        (Map<Id, Case>) oldMap
      )
    ) {
      GetHelpCaseActions.populateOCVOnComplaint(records);
    }
  }

  /**
   * @description onValidate(oldMap) is called before onAfterUpdate and all the required record updates are handled here
   * @param oldMap old trigger values
   */
  public override void onValidate(Map<Id, SObject> oldMap) {
    IDRCaseActions.afterUpdate(oldMap, records);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    IDRCaseActions.completeAfterActions();
    GetHelpCaseActions.rollupRelatedBug(records, (List<Case>) oldMap.values());
    SICaseActions.afterUpdate(records, (Map<Id, Case>) oldMap);
    GetHelpCaseActions.handleSLANotifications(records, (Map<Id, Case>) oldMap);
    GetHelpCaseActions.handleDisputesPEGAIntegration(
      records,
      (Map<Id, Case>) oldMap
    );
  }

  /**
   * @description onBeforeDelete
   */
  public override void onBeforeDelete() {
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
  }
}
