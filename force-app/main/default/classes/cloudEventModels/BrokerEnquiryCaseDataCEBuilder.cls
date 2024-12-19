/**
 * @description       : Builder class to build the GCP Event case for the Case Data
 * @author            : Smruti Khobragade | Salesforce
 * @group             :
 * @last modified on  : 11-29-2024
 * @last modified by  : Smruti Khobragade |  Salesforce
 **/

public with sharing class BrokerEnquiryCaseDataCEBuilder {
  /**
   * @description Create Case Master Node for publishing cloud event
   * @author  Smruti Khobragade | Salesforce | 11-2024
   * @param record  Case Record
   * @return BrokerCloudEventModel.MasterNode
   **/

  public static BrokerCloudEventModel.MasterNode buildCaseNode(Case record) {
    Map<String, String> caseDataMap = new Map<String, String>{
      'sourceObjectName' => 'Case',
      'sourceObjectExtId' => record.External_Case_ID__c,
      'targetObjects_extIdField' => 'External_Case_ID__c',
      'targetObjects_extObjectName' => 'Case',
      'targetObjects_status' => record.Status
    };
    return BrokerCloudEventModel.buildMasterNode(caseDataMap);
  }
}
