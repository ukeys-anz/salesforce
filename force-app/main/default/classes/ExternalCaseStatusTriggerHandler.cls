/**
 * @author Qing Wang
 * @since 07/2022
 * @description  ExternalCaseStatusTriggerHandler is the handler class for ExternalCaseStatus Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class ExternalCaseStatusTriggerHandler extends Lib_TriggerHandler {
  private Map<String, String> mapDisputeStatusVsInternalDesc;
  private Map<String, String> mapExternalStatusToCaseStatus;

  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ExternalCaseStatusTriggerHandler() {
    super();
  }

  /**
   * @description getExternalCaseStatusMapping to get external case status metadata mapping
   */
  public void getExternalCaseStatusMapping() {
    this.mapDisputeStatusVsInternalDesc = new Map<String, String>();
    this.mapExternalStatusToCaseStatus = new Map<String, String>();
    for (External_Case_Status_Mapping__mdt mapping : [
      SELECT
        PEGA_Dispute_Status__c,
        PEGA_Investigation_Outcome__c,
        Case_Status__c,
        Internal_Description__c,
        Id
      FROM External_Case_Status_Mapping__mdt
    ]) {
      this.mapDisputeStatusVsInternalDesc.put(
        mapping.PEGA_Dispute_Status__c +
          '_' +
          mapping.PEGA_Investigation_Outcome__c,
        mapping.Internal_Description__c
      );
      this.mapExternalStatusToCaseStatus.put(
        mapping.PEGA_Dispute_Status__c,
        mapping.Case_Status__c
      );
    }
  }

  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    getExternalCaseStatusMapping();
    updateRelatedCase(records);
    updateRelatedNPPCases(records);
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
        SELECT Id, Status, RecordTypeId
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

  /**
   * @description onBeforeInsert to update internal description.
   */
  public override void onBeforeInsert() {
    getExternalCaseStatusMapping();
    updateInternalDescription(records);
  }

  /**
   * @description update internal description
   * @param externalCaseStatuses External_Case_Status__c records
   */
  private void updateInternalDescription(
    List<External_Case_Status__c> externalCaseStatuses
  ) {
    for (External_Case_Status__c externalCaseStatus : externalCaseStatuses) {
      if (
        this.mapDisputeStatusVsInternalDesc.containsKey(
          externalCaseStatus.External_Status__c +
            '_' +
            externalCaseStatus.Result_Message__c
        )
      ) {
        externalCaseStatus.Internal_Description__c = this.mapDisputeStatusVsInternalDesc.get(
          externalCaseStatus.External_Status__c +
            '_' +
            externalCaseStatus.Result_Message__c
        );
      }
    }
  }

  /**
   * @description update the related NPP Case record
   * @param externalCaseStatuses External_Case_Status__c records
   */
  private void updateRelatedNPPCases(
    List<External_Case_Status__c> externalCaseStatuses
  ) {
    List<Case> theCases = new List<Case>();
    Map<Id, String> caseIdToExternalStatus = getCaseIds(externalCaseStatuses);
    if (caseIdToExternalStatus.isEmpty()) {
      return;
    }
    for (
      Case record : getParentCases(
        new List<Id>(caseIdToExternalStatus.keySet())
      )
    ) {
      if (
        this.mapExternalStatusToCaseStatus.containsKey(
          caseIdToExternalStatus.get(record.Id)
        ) && record.RecordTypeId == GetHelpConstants.NPP_DISPUTE_RT_ID
      ) {
        record.Status = this.mapExternalStatusToCaseStatus.get(
          caseIdToExternalStatus.get(record.Id)
        );
        theCases.add(record);
      }
    }
    DMLUtil.updateRecords(theCases, false, false);
  }

  /**
   * @description get the related Cases Ids
   * @param externalCaseStatuses External_Case_Status__c records
   * @return List<Id> Case IDs present in External_Case_Status__c records
   */
  private static Map<Id, String> getCaseIds(
    List<External_Case_Status__c> externalCaseStatuses
  ) {
    Map<Id, String> mapCaseIdToExternalStatus = new Map<Id, String>();
    for (External_Case_Status__c externalCaseStatus : externalCaseStatuses) {
      mapCaseIdToExternalStatus.put(
        externalCaseStatus.Case__c,
        externalCaseStatus.External_Status__c
      );
    }
    return mapCaseIdToExternalStatus;
  }
}
