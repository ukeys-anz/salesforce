/**
 * @author Arpit Pittie
 * @since 08/03/2024
 * @description To handle all the Get Help External Case Status Actions methods
 */
public with sharing class GetHelpExternalCaseStatusActionHelper {
  public static final String DEFAULT_NPP_INTERNAL_DESCRIPTION = 'Status Unknown - Refer to Pega PRS';
  public static final String DEFAULT_NPP_CASE_STATUS = 'On Hold';

  /**
   * @description getInternalDescription To get internal descrition updated on the external case status
   * @param records External_Case_Status__c records
   * @param statusToInternalDescMap map of external status to internal description
   */
  public static void getInternalDescription(
    List<External_Case_Status__c> records,
    Map<String, String> statusToInternalDescMap
  ) {
    for (External_Case_Status__c externalCaseStatus : records) {
      String key =
        externalCaseStatus.External_Status__c.toLowerCase() +
        '_' +
        externalCaseStatus.Result_Message__c?.toLowerCase();
      if (statusToInternalDescMap.containsKey(key)) {
        externalCaseStatus.Internal_Description__c = statusToInternalDescMap.get(
          key
        );
        continue;
      }

      key = externalCaseStatus.External_Status__c.toLowerCase() + '_';
      if (statusToInternalDescMap.containsKey(key)) {
        externalCaseStatus.Internal_Description__c = statusToInternalDescMap.get(
          key
        );
        continue;
      }

      externalCaseStatus.Internal_Description__c = DEFAULT_NPP_INTERNAL_DESCRIPTION;
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
   * @description To get related NPP Cases
   * @param relatedCasesIds list of all cases ids
   * @return List<Id> returns Id's of related NPP Cases
   */
  public static Set<Id> getRelatedNppCasesIds(List<Id> relatedCasesIds) {
    List<Id> nppCasesIds = new List<Id>();

    Map<String, Object> bindVariableMap = new Map<String, Object>{
      'idList' => relatedCasesIds,
      'recordTypeList' => new List<Id>{ GetHelpConstants.NPP_DISPUTE_RT_ID }
    };
    Map<Id, Case> nppCaseMap = new Map<Id, Case>(
      CaseQueryHelper.getNppCases(bindVariableMap)
    );

    return nppCaseMap.keySet();
  }

  /**
   * @description to update the case status based on mapping
   * @param parentCaseList List of cases to be updated
   * @param caseIdToExternalStatus map of case id to external case status value
   * @param statusToCaseStatusMap External status to case status map
   * @return `caseToUpdateList` List<Case> updated case list
   */
  public static List<Case> updateNPPCaseRecords(
    List<Case> parentCaseList,
    Map<Id, String> caseIdToExternalStatus,
    Map<String, String> statusToCaseStatusMap
  ) {
    List<Case> caseToUpdateList = new List<Case>();

    for (Case record : parentCaseList) {
      String key = caseIdToExternalStatus.get(record.Id);
      if (statusToCaseStatusMap.containsKey(key)) {
        record.Status = statusToCaseStatusMap.get(key);
      } else {
        record.Status = DEFAULT_NPP_CASE_STATUS;
      }
      caseToUpdateList.add(record);
    }

    return caseToUpdateList;
  }
}
