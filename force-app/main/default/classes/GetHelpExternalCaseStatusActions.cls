/**
 * @author Arpit Pittie
 * @since 08/03/2024
 * @description To handle all the Get Help External Case Status Actions
 */
public with sharing class GetHelpExternalCaseStatusActions {
  /**
   * @description update internal description
   * @param records External_Case_Status__c records
   */
  public static void updateInternalDescription(
    List<External_Case_Status__c> records
  ) {
    List<Id> relatedCasesIds = new List<Id>();
    List<External_Case_Status__c> externalCaseStatusForNPP = new List<External_Case_Status__c>();
    ExternalCaseStatusMappingQueryHelper caseStatusQueryHelper = ExternalCaseStatusMappingQueryHelper.getInstance();
    Map<String, String> statusToInternalDescMap = caseStatusQueryHelper.getStatusToInternalDescriptionMap();
    for (External_Case_Status__c record : records) {
      relatedCasesIds.add(record.Case__c);
    }
    Set<Id> relatedNPPCasesId = GetHelpExternalCaseStatusActionHelper.getRelatedNppCasesIds(
      relatedCasesIds
    );

    if (relatedNPPCasesId.isEmpty()) {
      return;
    }

    for (External_Case_Status__c extCaseRecord : records) {
      if (relatedNPPCasesId.contains(extCaseRecord.Case__c)) {
        externalCaseStatusForNPP.add(extCaseRecord);
      }
    }

    GetHelpExternalCaseStatusActionHelper.getInternalDescription(
      externalCaseStatusForNPP,
      statusToInternalDescMap
    );
  }

  /**
   * @description update the related NPP Case record
   * @param records External_Case_Status__c records
   */
  public static void updateRelatedNPPCases(
    List<External_Case_Status__c> records
  ) {
    Map<Id, String> caseIdToExternalStatusMap = GetHelpExternalCaseStatusActionHelper.getCaseIdToExternalStatusMap(
      records
    );
    if (caseIdToExternalStatusMap.isEmpty()) {
      return;
    }

    List<Id> caseIdList = new List<Id>(caseIdToExternalStatusMap.keySet());
    List<Id> recordTypeIdList = new List<Id>{
      GetHelpConstants.NPP_DISPUTE_RT_ID
    };
    Map<String, Object> bindVariableMap = new Map<String, Object>{
      'idList' => caseIdList,
      'recordTypeList' => recordTypeIdList
    };
    List<Case> parentCaseList = CaseQueryHelper.getNppCases(bindVariableMap);
    if (parentCaseList.isEmpty()) {
      return;
    }

    ExternalCaseStatusMappingQueryHelper caseStatusQueryHelper = ExternalCaseStatusMappingQueryHelper.getInstance();
    Map<String, String> statusToCaseStatusMap = caseStatusQueryHelper.getStatusToCaseStatusMap();

    List<Case> caseToUpdateList = GetHelpExternalCaseStatusActionHelper.updateNPPCaseRecords(
      parentCaseList,
      caseIdToExternalStatusMap,
      statusToCaseStatusMap
    );
    DMLUtil.updateRecords(
      caseToUpdateList,
      DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
      DMLUtil.USER_MODE
    );
  }
}
