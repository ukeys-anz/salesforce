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
        Case_Record_Type__c,
        Customer_Message__c,
        Customer_Status__c,
        PEGA_Dispute_Status__c,
        PEGA_Investigation_Outcome__c,
        Case_Status__c,
        Internal_Description__c,
        Is_Created_In_SF__c,
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
   * @description getstatusToMetadataMap is called to get external status to metadata map
   * @return `getstatusToMetadataMap` Map<String, String>
   */
  public Map<String, External_Case_Status_Mapping__mdt> getStatusToMetadataMap() {
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadataMap = new Map<String, External_Case_Status_Mapping__mdt>();
    for (
      External_Case_Status_Mapping__mdt mapping : this.externalCaseStatusMappingList
    ) {
      if (mapping.Is_Created_In_SF__c) {
        continue;
      }
      String key = (String.join(
          new List<String>{
            mapping.Case_Record_Type__c,
            mapping.PEGA_Dispute_Status__c,
            mapping.PEGA_Investigation_Outcome__c
          },
          '_'
        ))
        .toLowerCase();
      statusToMetadataMap.put(key, mapping);
    }
    return statusToMetadataMap;
  }

  /**
   * @description getSalesforceStatusToMetadataMap is called to get salesforce status to metadata map
   * @return `getSalesforceStatusToMetadataMap` Map<String, String>
   */
  public Map<String, External_Case_Status_Mapping__mdt> getSalesforceStatusToMetadataMap() {
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadataMap = new Map<String, External_Case_Status_Mapping__mdt>();
    for (
      External_Case_Status_Mapping__mdt mapping : this.externalCaseStatusMappingList
    ) {
      if (!mapping.Is_Created_In_SF__c) {
        continue;
      }
      String key = (String.join(
          new List<String>{
            mapping.Case_Record_Type__c,
            mapping.Case_Status__c
          },
          '_'
        ))
        .toLowerCase();
      statusToMetadataMap.put(key, mapping);
    }
    return statusToMetadataMap;
  }

  /**
   * @description getrecordTypeStatusToCaseStatusMap is called to get external status to case status map
   * @return `recordTypeStatusToCaseStatusMap` Map<String, String>
   */
  public Map<String, External_Case_Status_Mapping__mdt> getRecordTypeStatusToMetadataMap() {
    Map<String, External_Case_Status_Mapping__mdt> recordTypeStatusToCaseStatusMap = new Map<String, External_Case_Status_Mapping__mdt>();
    for (
      External_Case_Status_Mapping__mdt mapping : this.externalCaseStatusMappingList
    ) {
      if (mapping.Is_Created_In_SF__c) {
        continue;
      }

      String key = (String.join(
          new List<String>{
            mapping.Case_Record_Type__c,
            mapping.PEGA_Dispute_Status__c
          },
          '_'
        ))
        .toLowerCase();

      recordTypeStatusToCaseStatusMap.put(key, mapping);
    }
    return recordTypeStatusToCaseStatusMap;
  }
}
