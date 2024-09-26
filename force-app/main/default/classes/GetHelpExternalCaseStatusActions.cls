/**
 * @author Arpit Pittie
 * @since 08/03/2024
 * @description To handle all the Get Help External Case Status Actions
 */
public with sharing class GetHelpExternalCaseStatusActions {
  private static final CaseDisputesRepository CASE_DISPUTES_REPOSITORY = (CaseDisputesRepository) Lib_InstanceProvider.forType(
    CaseDisputesRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  public static final String DEFAULT_NPP_INTERNAL_DESCRIPTION = 'Status Unknown - Refer to Pega PRS';
  public static final String DEFAULT_NPP_CASE_STATUS = 'On Hold';

  public static final List<Id> CARD_AND_ATM_DISPUTE_RT_IDS = new List<Id>{
    RTCase.atmDispute,
    RTCase.cardDispute
  };

  /**
   * @description update fields on external case status
   * @param records External_Case_Status__c records
   */
  public static void updateExternalCaseStatusFields(
    List<External_Case_Status__c> records
  ) {
    ExternalCaseStatusMappingQueryHelper externalCaseStatusQueryHelper = ExternalCaseStatusMappingQueryHelper.getInstance();
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadataMap = externalCaseStatusQueryHelper.getStatusToMetadataMap();
    Map<Id, Case> relatedCases = getRelatedCases(records);

    if (relatedCases.isEmpty()) {
      return;
    }

    populateExternalCaseStatusFields(
      records,
      statusToMetadataMap,
      relatedCases
    );
  }

  /**
   * @description update the related cases based on the mapping
   * @param records External_Case_Status__c records
   */
  public static void updateRelatedCases(List<External_Case_Status__c> records) {
    Map<Id, String> caseIdToExternalStatusMap = getCaseIdToExternalStatusMap(
      records
    );
    if (caseIdToExternalStatusMap.isEmpty()) {
      return;
    }

    List<Case> parentCaseList = CASE_DISPUTES_REPOSITORY.getOpenCases(
      new List<Id>(caseIdToExternalStatusMap.keySet())
    );
    if (parentCaseList.isEmpty()) {
      return;
    }
    ExternalCaseStatusMappingQueryHelper externalCaseStatusQueryHelper = ExternalCaseStatusMappingQueryHelper.getInstance();
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadatasMap = externalCaseStatusQueryHelper.getRecordTypeStatusToMetadataMap();
    List<Case> caseToUpdateList = updateCaseRecords(
      parentCaseList,
      caseIdToExternalStatusMap,
      statusToMetadatasMap
    );
    DML_REPOSITORY.updateRecords(
      caseToUpdateList,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.SYSTEM_MODE
    );
  }

  /**
   * @description To get related Cases
   * @param records list of all external cases ids
   * @return Map<Id,Case> returns Id's and cases of related NPP Cases
   */
  private static Map<Id, Case> getRelatedCases(
    List<External_Case_Status__c> records
  ) {
    Set<Id> relatedCasesIds = ListUtil.getIds(
      records,
      External_Case_Status__c.Case__c
    );

    Map<Id, Case> caseMap = new Map<Id, Case>(
      CASE_DISPUTES_REPOSITORY.getCases(relatedCasesIds)
    );
    return caseMap;
  }

  /**
   * @description populateExternalCaseStatusFields to updated fields on the external case status
   * @param records External_Case_Status__c records
   * @param statusToMetaDataMap map of external status to internal description
   * @param relatedCases map of cases
   */
  @TestVisible
  private static void populateExternalCaseStatusFields(
    List<External_Case_Status__c> records,
    Map<String, External_Case_Status_Mapping__mdt> statusToMetaDataMap,
    Map<Id, Case> relatedCases
  ) {
    for (External_Case_Status__c externalCaseStatus : records) {
      String resultMessage = '';
      if (
        !CARD_AND_ATM_DISPUTE_RT_IDS.contains(
          relatedCases.get(externalCaseStatus.Case__c).RecordTypeId
        )
      ) {
        resultMessage = externalCaseStatus.Result_Message__c;
      }
      String key = (String.join(
          new List<String>{
            relatedCases.get(externalCaseStatus.Case__c)
              .RecordType.DeveloperName,
            externalCaseStatus.External_Status__c,
            resultMessage
          },
          '_'
        ))
        .toLowerCase();

      if (statusToMetaDataMap.containsKey(key)) {
        External_Case_Status_Mapping__mdt metadata = statusToMetaDataMap.get(
          key
        );
        externalCaseStatus.Internal_Description__c = metadata.Internal_Description__c;
        externalCaseStatus.New_Customer_Message__c = metadata.Customer_Message__c;
        externalCaseStatus.Customer_Status__c = metadata.Customer_Status__c;
        continue;
      }

      if (
        CheckCaseRecordType.isNPPNonFraudDispute(
          relatedCases.get(externalCaseStatus.Case__c)
        )
      ) {
        externalCaseStatus.Internal_Description__c = DEFAULT_NPP_INTERNAL_DESCRIPTION;
      }
    }
  }

  /**
   * @description To get the Case Id to External Status Map
   * @param records External_Case_Status__c records
   * @return Map<Id, String> map of case id to external status
   */
  public static Map<Id, String> getCaseIdToExternalStatusMap(
    List<External_Case_Status__c> records
  ) {
    Map<Id, String> caseIdToExternalStatusMap = new Map<Id, String>();
    for (External_Case_Status__c externalCaseStatus : records) {
      caseIdToExternalStatusMap.put(
        externalCaseStatus.Case__c,
        externalCaseStatus.External_Status__c
      );
    }
    return caseIdToExternalStatusMap;
  }

  /**
   * @description to update the case status based on mapping
   * @param parentCaseList List of cases to be updated
   * @param caseIdToExternalStatus map of case id to external case status value
   * @param statusToMetadatasMap External status to case status map
   * @return `caseToUpdateList` List<Case> updated case list
   */
  public static List<Case> updateCaseRecords(
    List<Case> parentCaseList,
    Map<Id, String> caseIdToExternalStatus,
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadatasMap
  ) {
    List<Case> caseToUpdateList = new List<Case>();
    for (Case record : parentCaseList) {
      String key = (String.join(
          new List<String>{
            record.RecordType.DeveloperName,
            caseIdToExternalStatus.get(record.Id)
          },
          '_'
        ))
        .toLowerCase();

      if (
        statusToMetadatasMap.containsKey(key) &&
        String.isNotBlank(statusToMetadatasMap.get(key).Case_Status__c)
      ) {
        record.Status = statusToMetadatasMap.get(key).Case_Status__c;
        caseToUpdateList.add(record);
        continue;
      }
      if (CheckCaseRecordType.isNPPNonFraudDispute(record)) {
        record.Status = DEFAULT_NPP_CASE_STATUS;
        caseToUpdateList.add(record);
      }
    }
    return caseToUpdateList;
  }
}
