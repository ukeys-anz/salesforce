/**
 * @author Zhiren Jason Guan
 * @since  19/02/2024
 * @description Builder class to build the GCP Event contracts for the broker contact
 * @runTests  BrokerDataCloudEventTest
 */

public with sharing class BrokerDataContactCEBuilder {
  // Event Contract Variables
  private static final String OBJECT_ACCOUNT = 'Account';
  private static final String OBJECT_CONTACT = 'Contact';
  private static final String OBJECT_BROKER_CODE = 'Broker_Code__c';
  private static final String FIELD_EXTERNAL_ID = 'External_Id__c';
  private static final String FIELD_ACCOUNT_ID = 'Account';
  private static final String FIELD_CUSTOMER_NAME_EXTERNAL_ID = 'Customer_Name__r.External_Id__c';
  private static final String FIELD_BROKER_NAME_EXTERNAL_ID = 'Broker_Name__r.External_Id__c';
  private static final String FIELD_PARENT = 'Parent';
  private static final String FIELD_BROKER_NAME = 'Broker_Name__r';

  /**
   * @description Build the account node for the cloud event
   * @param record the new contact record in trigger context
   * @return master object
   */
  public static BrokerDataCloudEventModel.MasterNode buildAccountNode(
    Contact record
  ) {
    Map<String, String> dataContractMap = new Map<String, String>{
      'sourceObjectName' => OBJECT_CONTACT,
      'sourceObjectExtId' => record.External_Id__c,
      'targetObjects_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_extObjectName' => OBJECT_ACCOUNT
    };
    return BrokerDataCloudEventModel.buildMasterNode(dataContractMap);
  }

  /**
   * @description Build the contact node for the cloud event
   * @param record the new contact record in trigger context
   * @return master object
   */
  public static BrokerDataCloudEventModel.MasterNode buildContactNode(
    Contact record
  ) {
    Map<String, String> dataContractMap = new Map<String, String>{
      'sourceObjectName' => OBJECT_CONTACT,
      'sourceObjectExtId' => record.External_Id__c,
      'targetObjects_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_extObjectName' => OBJECT_CONTACT,
      'targetObjects_parent_objectName' => OBJECT_ACCOUNT,
      'targetObjects_parent_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_parent_referenceField' => FIELD_ACCOUNT_ID,
      'targetObjects_parent_extId' => record.External_Id__c
    };
    return BrokerDataCloudEventModel.buildMasterNode(dataContractMap);
  }

  /**
   * @description Build the contact info node for the cloud event
   * @param record the new contact record in trigger context
   * @param contactInfoObjectName the contact info object name
   * @return master object
   */
  public static BrokerDataCloudEventModel.MasterNode buildContactInfoNode(
    Contact record,
    String contactInfoObjectName
  ) {
    Map<String, String> dataContractMap = new Map<String, String>{
      'sourceObjectName' => contactInfoObjectName,
      'sourceObjectParentExtId' => record.Broker_Customer_Profile__r
        ?.External_Id__c,
      'sourceObjectParentExtIdName' => FIELD_CUSTOMER_NAME_EXTERNAL_ID,
      'targetObjects_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_extObjectName' => contactInfoObjectName,
      'targetObjects_parent_objectName' => OBJECT_ACCOUNT,
      'targetObjects_parent_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_parent_referenceField' => FIELD_PARENT,
      'targetObjects_parent_extId' => record.External_Id__c
    };
    return BrokerDataCloudEventModel.buildMasterNode(dataContractMap);
  }

  /**
   * @description Build the broker code node for the cloud event
   * @param record the new contact record in trigger context
   * @return master object
   */
  public static BrokerDataCloudEventModel.MasterNode buildBrokerCodeNode(
    Contact record
  ) {
    Map<String, String> dataContractMap = new Map<String, String>{
      'sourceObjectName' => OBJECT_BROKER_CODE,
      'sourceObjectParentExtId' => record.External_Id__c,
      'sourceObjectParentExtIdName' => FIELD_BROKER_NAME_EXTERNAL_ID,
      'targetObjects_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_extObjectName' => OBJECT_BROKER_CODE,
      'targetObjects_parent_objectName' => OBJECT_ACCOUNT,
      'targetObjects_parent_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_parent_referenceField' => FIELD_BROKER_NAME,
      'targetObjects_parent_extId' => record.External_Id__c
    };
    return BrokerDataCloudEventModel.buildMasterNode(dataContractMap);
  }
}
