/**
 * @description       : Builder class to build the GCP Event case for the Case Data
 * @author            : Smruti Khobragade | Salesforce
 * @group             :
 * @last modified on  : 11-29-2024
 * @last modified by  : Smruti Khobragade |  Salesforce
 **/

public with sharing class BrokerRequestHelpCaseDataCEBuilder {
  private static final String OBJECT_CASE = 'Case';
  private static final String FIELD_EXTERNAL_ID = 'External_Case_ID__c';

  /**
   * @description Create Case Master Node for publishing cloud event
   * @author  Smruti Khobragade | Salesforce | 11-2024
   * @param record  Case Record
   * @return BrokerRequestHelpCaseCloudEventModel.MasterNode
   **/

  public static BrokerRequestHelpCaseCloudEventModel.MasterNode buildCaseNode(
    Case record
  ) {
    Map<String, String> dataCaseMap = new Map<String, String>{
      'sourceObjectName' => OBJECT_CASE,
      'sourceObjectExtId' => record.External_Case_ID__c,
      'targetObjects_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_extObjectName' => OBJECT_CASE,
      'targetObjects_status' => record.Status
    };
    return BrokerRequestHelpCaseCloudEventModel.buildMasterNode(dataCaseMap);
  }
}
