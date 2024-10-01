/**
 * @description       : Builder class to build the GCP Event contracts for the Customer Account
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 08-05-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public with sharing class CustomerDataCEBuilder {
  private static final String OBJECT_ACCOUNT = 'Account';
  private static final String FIELD_EXTERNAL_ID = 'External_Id__c';

  /**
   * @description Create ResidentialLoanApplication Master Node for publishing cloud event
   * @author  Madhuri Edke | Salesforce | 07-17-2024
   * @param record
   * @return BrokerCloudEventModel.MasterNode
   **/
  public static BrokerCloudEventModel.MasterNode buildAccountNode(
    Account record
  ) {
    Map<String, String> dataCustomerMap = new Map<String, String>{
      'sourceObjectName' => OBJECT_ACCOUNT,
      'sourceObjectExtId' => record.External_Id__c,
      'targetObjects_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_extObjectName' => OBJECT_ACCOUNT
    };
    return BrokerCloudEventModel.buildMasterNode(dataCustomerMap);
  }
}
