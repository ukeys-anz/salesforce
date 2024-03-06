/**
 * @author Qing Wang
 * @since 07/2022
 * @description  ExternalCaseStatusTriggerHandler is the handler class for ExternalCaseStatus Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class ExternalCaseStatusTriggerHandler extends Lib_TriggerHandler {
  private Map<String, String> mapDisputeStatusVsInternalDesc;
  private Map<String, String> mapExternalStatusToCaseStatus;
  public static final String DEFAULT_NPP_INTERNAL_DESCRIPTION = 'Status Unknown - Refer to Pega PRS';
  public static final String DEFAULT_NPP_CASE_STATUS = 'On Hold';

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
    List<External_Case_Status_Mapping__mdt> mappingList = [
      SELECT
        PEGA_Dispute_Status__c,
        PEGA_Investigation_Outcome__c,
        Case_Status__c,
        Internal_Description__c,
        Id
      FROM External_Case_Status_Mapping__mdt
    ];
    for (External_Case_Status_Mapping__mdt mapping : mappingList) {
      this.mapDisputeStatusVsInternalDesc.put(
        mapping.PEGA_Dispute_Status__c.toLowerCase() +
          '_' +
          mapping.PEGA_Investigation_Outcome__c?.toLowerCase(),
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
      String combinedKey =
        externalCaseStatus.External_Status__c.toLowerCase() +
        '_' +
        externalCaseStatus.Result_Message__c?.toLowerCase();
      if (this.mapDisputeStatusVsInternalDesc.containsKey(combinedKey)) {
        externalCaseStatus.Internal_Description__c = this.mapDisputeStatusVsInternalDesc.get(
          combinedKey
        );
        continue;
      }

      String statusKey =
        externalCaseStatus.External_Status__c.toLowerCase() + '_';
      if (this.mapDisputeStatusVsInternalDesc.containsKey(statusKey)) {
        externalCaseStatus.Internal_Description__c = this.mapDisputeStatusVsInternalDesc.get(
          statusKey
        );
        continue;
      }
      externalCaseStatus.Internal_Description__c = DEFAULT_NPP_INTERNAL_DESCRIPTION;
    }
  }

  /**
   * @description update the related NPP Case record
   * @param externalCaseStatuses External_Case_Status__c records
   */
  private void updateRelatedNPPCases(
    List<External_Case_Status__c> externalCaseStatuses
  ) {
    Map<Id, String> caseIdToExternalStatus = getCaseIds(externalCaseStatuses);
    if (caseIdToExternalStatus.isEmpty()) {
      return;
    }

    List<Id> caseIdList = new List<Id>(caseIdToExternalStatus.keySet());
    List<Id> recordTypeIdList = new List<Id>{
      GetHelpConstants.NPP_DISPUTE_RT_ID
    };
    List<Case> parentCaseList = getRecordTypeFilteredCase(
      caseIdList,
      recordTypeIdList
    );
    if (parentCaseList.isEmpty()) {
      return;
    }
    List<Case> caseToUpdateList = updateNPPCaseRecords(
      parentCaseList,
      caseIdToExternalStatus
    );
    DMLUtil.updateRecords(caseToUpdateList, false, false);
  }

  /**
   * @description get Case details based on Ids and Record Type Ids
   * @param recordIdList list of case ids
   * @param recordTypeIdList list of recordtype ids
   * @return List<Case> all the cases based on the filter
   */
  public static List<Case> getRecordTypeFilteredCase(
    List<Id> recordIdList,
    List<Id> recordTypeIdList
  ) {
    List<Case> caseList = [
      SELECT Id, Status, RecordTypeId
      FROM Case
      WHERE Id IN :recordIdList AND RecordTypeId IN :recordTypeIdList
    ];
    return caseList;
  }

  /**
   * @description to update the case status based on mapping
   * @param parentCaseList List of cases to be updated
   * @param caseIdToExternalStatus map of case id to external case status value
   * @return List<Case> updated case list
   */
  public List<Case> updateNPPCaseRecords(
    List<Case> parentCaseList,
    Map<Id, String> caseIdToExternalStatus
  ) {
    List<Case> caseToUpdateList = new List<Case>();
    for (Case record : parentCaseList) {
      String key = caseIdToExternalStatus.get(record.Id);
      if (this.mapExternalStatusToCaseStatus.containsKey(key)) {
        record.Status = this.mapExternalStatusToCaseStatus.get(key);
      } else {
        record.Status = DEFAULT_NPP_CASE_STATUS;
      }
      caseToUpdateList.add(record);
    }
    return caseToUpdateList;
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
