/**
 * @author Arpit Pittie
 * @since 08/03/2024
 * @description To handle all the External Case Status Mapping Metadata queries
 */
public with sharing class ExternalCaseStatusMappingQueryHelper {
  private static ExternalCaseStatusMappingQueryHelper externalCaseStatusMappingQueryHelper;
  public List<External_Case_Status_Mapping__mdt> externalCaseStatusMappingList;

  /**
   * @description Constructor
   */
  private ExternalCaseStatusMappingQueryHelper() {
    externalCaseStatusMappingList = [
      SELECT
        PEGA_Dispute_Status__c,
        PEGA_Investigation_Outcome__c,
        Case_Status__c,
        Internal_Description__c,
        Id
      FROM External_Case_Status_Mapping__mdt
    ];
  }

  /**
   * @description gets the instance of this singleton
   * @return ExternalCaseStatusMappingQueryHelper gets an instance of this class.
   */
  public static ExternalCaseStatusMappingQueryHelper getInstance() {
    if (externalCaseStatusMappingQueryHelper == null) {
      externalCaseStatusMappingQueryHelper = new ExternalCaseStatusMappingQueryHelper();
    }
    return externalCaseStatusMappingQueryHelper;
  }

  /**
   * @description getStatusToInternalDescriptionMap is called to get external status to intenal description map
   * @return `getStatusToInternalDescriptionMap` Map<String, String>
   */
  public Map<String, String> getStatusToInternalDescriptionMap() {
    Map<String, String> statusToInternalDescriptionMap = new Map<String, String>();
    for (
      External_Case_Status_Mapping__mdt mapping : this.externalCaseStatusMappingList
    ) {
      String investigationOutcome = String.isNotBlank(
          mapping.PEGA_Investigation_Outcome__c
        )
        ? mapping.PEGA_Investigation_Outcome__c.toLowerCase()
        : '';
      String key =
        mapping.PEGA_Dispute_Status__c.toLowerCase() +
        '_' +
        investigationOutcome;
      statusToInternalDescriptionMap.put(key, mapping.Internal_Description__c);
    }
    return statusToInternalDescriptionMap;
  }

  /**
   * @description getStatusToCaseStatusMap is called to get external status to case status map
   * @return `statusToCaseStatusMap` Map<String, String>
   */
  public Map<String, String> getStatusToCaseStatusMap() {
    Map<String, String> statusToCaseStatusMap = new Map<String, String>();
    for (
      External_Case_Status_Mapping__mdt mapping : this.externalCaseStatusMappingList
    ) {
      statusToCaseStatusMap.put(
        mapping.PEGA_Dispute_Status__c,
        mapping.Case_Status__c
      );
    }
    return statusToCaseStatusMap;
  }
}
