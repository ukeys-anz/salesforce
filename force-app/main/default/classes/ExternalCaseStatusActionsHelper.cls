/**
 * @author Qing Wang
 * @since 07/2022
 * @description ExternalCaseStatusActionsHelper class is to  provide helper function to ExternalCaseStatusActions class
 */

public with sharing class ExternalCaseStatusActionsHelper {
  /**
   * @description the map which stores the External Status to Case Status mapping
   */
  public static Map<String, String> externalStatusToCaseStatusMap {
    get {
      if (externalStatusToCaseStatusMap != null) {
        return externalStatusToCaseStatusMap;
      }
      externalStatusToCaseStatusMap = new Map<String, String>();
      List<PEGA_Smarts_Status_Mapping__mdt> pegaSmartsStatusesMapping = PEGA_Smarts_Status_Mapping__mdt.getAll()
        .values();
      for (
        PEGA_Smarts_Status_Mapping__mdt pegaSmartsStatusMapping : pegaSmartsStatusesMapping
      ) {
        externalStatusToCaseStatusMap.put(
          pegaSmartsStatusMapping.Label,
          pegaSmartsStatusMapping.Case_Status__c
        );
      }
      return externalStatusToCaseStatusMap;
    }
    set;
  }

  /**
   * @description return a list of valid External Case Status records that have external status id
   * @param records  List<External_Case_Status__c> records
   * @return List<External_Case_Status__c> a list of External Case Status records
   */
  public static List<External_Case_Status__c> getValidExternalStatuses(
    List<External_Case_Status__c> records
  ) {
    List<External_Case_Status__c> externalStatuses = new List<External_Case_Status__c>();

    if (PermissionUtils.canQuery('External_Case_Status__c')) {
      // only process External records with Status defined in static map
      // no data quality check requried, as long as External_Status__c value is present
      externalStatuses = [
        SELECT Id, Case__c, External_Status__c, CreatedDate
        FROM External_Case_Status__c
        WHERE
          Id IN :records
          AND External_Status__c != NULL
          AND External_Status__c IN :externalStatusToCaseStatusMap.keySet()
        ORDER BY CreatedDate ASC
      ];
    }

    return externalStatuses;
  }

  /**
   * @description return master Cases of given External Case Statuses
   * @param records  List<External_Case_Status__c> records
   * @return Map<String, Case> a map of CaseId and Case record
   */
  public static Map<String, Case> getRelatedCases(
    List<External_Case_Status__c> records
  ) {
    Map<String, Case> relatedCases = new Map<String, Case>();

    if (!records.isEmpty()) {
      relatedCases = new Map<String, Case>(
        [
          SELECT Id, Status
          FROM Case
          WHERE
            Id IN (
              SELECT Case__c
              FROM External_Case_Status__c
              WHERE Id IN :records
            )
        ]
      );
    }

    return relatedCases;
  }

  /**
   * @description return a map of case and it's latest External Case Status records
   * @param records  List<External_Case_Status__c> records
   * @return Map<String, External_Case_Status__c> a map of Case and latest External Case Status records
   */
  public static Map<String, External_Case_Status__c> getLatestExternalStatusByCaseIdMap(
    List<External_Case_Status__c> records
  ) {
    Map<String, External_Case_Status__c> caseIdLatestExternalStatusMap = new Map<String, External_Case_Status__c>();

    for (External_Case_Status__c record : records) {
      if (caseIdLatestExternalStatusMap.containsKey(record.Case__c)) {
        Datetime storedDatetime = caseIdLatestExternalStatusMap.get(
            record.Case__c
          )
          .CreatedDate;

        if (storedDatetime < record.CreatedDate) {
          caseIdLatestExternalStatusMap.put(record.Case__c, record);
        }
      } else {
        caseIdLatestExternalStatusMap.put(record.Case__c, record);
      }
    }

    return caseIdLatestExternalStatusMap;
  }

  /**
   * @description return a list Case with new Status to update
   * @param relatedCases Map<String, Case> related master case
   * @param latestExternalStatusByCaseIdMap  Map<String, External_Case_Status__c> case and it's latest External Case Status record
   * @return List<Case> a list of Case to update
   */
  public static List<Case> getCasesToUpdate(
    Map<String, Case> relatedCases,
    Map<String, External_Case_Status__c> latestExternalStatusByCaseIdMap
  ) {
    List<Case> casesToUpdate = new List<Case>();

    for (String caseId : latestExternalStatusByCaseIdMap.keySet()) {
      String currentStatus = relatedCases.get(caseId).Status;
      String statusToUpdate = externalStatusToCaseStatusMap.get(
        latestExternalStatusByCaseIdMap.get(caseId).External_Status__c
      );

      // only update Case has changed Status
      if (currentStatus != statusToUpdate) {
        casesToUpdate.add(new Case(Id = caseId, Status = statusToUpdate));
      }
    }

    return casesToUpdate;
  }
}
