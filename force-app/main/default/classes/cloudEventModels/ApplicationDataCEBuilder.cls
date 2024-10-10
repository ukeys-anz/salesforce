/**
 * @author Deepro De
 * @since  24/05/2024
 * @description Builder class to build the GCP Event for the residential loan applications
 */

public with sharing class ApplicationDataCEBuilder {
  private static final String OBJECT_ACCOUNT = 'Account';
  private static final String OBJECT_RESIDENTIAL_LOAN_APP = 'ResidentialLoanApplication';
  private static final String FIELD_EXTERNAL_ID = 'External_Id__c';
  private static final String FIELD_ACCOUNT_ID = 'Account';
  private static final String FIELD_PARENT = 'Parent';
  private static final String FIELD_BROKER_NAME = 'Broker_Name__r';
  private static final String FIELD_LOAN_APP_ACCOUNTID = 'AccountId';

  /**
   * @description Create ResidentialLoanApplication Master Node for publishing cloud event
   * @author  Deepro De | Salesforce | 05-30-2024
   * @param record
   * @return BrokerCloudEventModel.MasterNode
   **/
  public static BrokerCloudEventModel.MasterNode buildResidentialLoanAppNode(
    ResidentialLoanApplication record
  ) {
    Map<String, String> dataLoanAppMap = new Map<String, String>{
      'sourceObjectName' => OBJECT_RESIDENTIAL_LOAN_APP,
      'sourceObjectExtId' => record.ApplicationExtIdentifier,
      'sourceObjectParentExtIdName' => FIELD_LOAN_APP_ACCOUNTID,
      'targetObjects_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_extObjectName' => OBJECT_RESIDENTIAL_LOAN_APP,
      'targetObjects_parent_objectName' => OBJECT_ACCOUNT,
      'targetObjects_parent_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_parent_referenceField' => FIELD_ACCOUNT_ID,
      'targetObjects_parent_extId' => record.ApplicationExtIdentifier,
      'sourceObjectParentExtId' => record.Account.External_Id__c
    };
    return BrokerCloudEventModel.buildMasterNode(dataLoanAppMap);
  }
}
