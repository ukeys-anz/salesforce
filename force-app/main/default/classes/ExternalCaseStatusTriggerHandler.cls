/**
 * @author Qing Wang
 * @since 07/2022
 * @description  ExternalCaseStatusTriggerHandler is the handler class for ExternalCaseStatus Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class ExternalCaseStatusTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ExternalCaseStatusTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    updateRelatedCase(records);
    ExternalCaseStatusCEController.publishCloudEvents(records);
  }

  /**
   * @description update the related Case record
   * @param externalCaseStatuses External_Case_Status__c records
   */
  private static void updateRelatedCase(
    List<External_Case_Status__c> externalCaseStatuses
  ) {
    List<Id> caseIds = getParentCaseIDs(externalCaseStatuses);
    if (caseIds.isEmpty()) {
      return;
    }
    List<Case> theCases = getParentCases(caseIds);
    if (theCases.isEmpty()) {
      return;
    }
    theCases = modifyCaseFields(theCases);
    updateCases(theCases);
  }

  /**
   * @description update the related Case record
   * @param externalCaseStatuses External_Case_Status__c records
   * @return List<Id> Case IDs present in External_Case_Status__c records
   */
  private static List<Id> getParentCaseIDs(
    List<External_Case_Status__c> externalCaseStatuses
  ) {
    List<Id> caseIds = new List<Id>();
    for (External_Case_Status__c externalCaseStatus : externalCaseStatuses) {
      if (externalCaseStatus.External_Status__c.startsWith('Resolved')) {
        caseIds.add(externalCaseStatus.Case__c);
      }
    }
    return caseIds;
  }

  /**
   * @description update the related Case record
   * @param caseIds Case IDs present in External_Case_Status__c records
   * @return List<Case> Cases which are not in Closed status
   */
  private static List<Case> getParentCases(List<Id> caseIds) {
    List<Case> theCases;
    if (Schema.sObjectType.Case.isQueryable()) {
      theCases = [
        SELECT Id, Status
        FROM Case
        WHERE Id IN :caseIds AND Status != 'Closed'
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'ExternalCaseStatusTriggerHandler',
        'getParentCases',
        'Not enough permissions to query Case.'
      );
    }
    return theCases;
  }

  /**
   * @description update the related Case record
   * @param theCases Cases which are not in Closed status
   * @return List<Case> Cases updated with status as Closed
   */
  private static List<Case> modifyCaseFields(List<Case> theCases) {
    for (Case theCase : theCases) {
      theCase.Status = 'Closed';
    }
    return theCases;
  }

  /**
   * @description update the related Case record
   * @param theCases Cases which are not in Closed status
   */
  private static void updateCases(List<Case> theCases) {
    SystemModeActions actions = new SystemModeActions(
      'ExternalCaseStatusTriggerHandler',
      'onAfterInsert'
    );
    actions.updateRecords(theCases, 'Case');
  }
}
