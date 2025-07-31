/**
 * @author Zhiren Jason Guan
 * @since  19/02/2024
 * @description Builder class to build the GCP Event contracts for the broker contact
 * @runTests  BrokerCloudEventBuilderTest
 */

public with sharing class BrokerCloudEventBuilder {
  // Event Contract Variables
  private static final String OBJECT_ACCOUNT = 'Account';
  private static final String OBJECT_CONTACT = 'Contact';
  private static final String OBJECT_FINANCIAL_ACCOUNT = 'FinServ__FinancialAccount__c';
  private static final String OBJECT_RESIDENTIAL_LOAN_APP = 'ResidentialLoanApplication';
  private static final String OBJECT_BROKER_CODE = 'Broker_Code__c';
  private static final String FIELD_EXTERNAL_ID = 'External_Id__c';
  private static final String FIELD_ACCOUNT_ID = 'Account';
  private static final String FIELD_CUSTOMER_NAME_EXTERNAL_ID = 'Customer_Name__r.External_Id__c';
  private static final String FIELD_BROKER_NAME_EXTERNAL_ID = 'Broker_Name__r.External_Id__c';
  private static final String FIELD_PARENT = 'Parent';
  private static final String FIELD_BROKER_NAME = 'Broker_Name__r';
  private static final String FIELD_LOAN_APP_ACCOUNTID = 'AccountId';
  private static final String FIELD_FINANCIAL_ACCOUNT_PRIMARY_OWNER = 'FinServ__PrimaryOwner__c';

  /**
   * @description Build the account node for the cloud event
   * @param record the new contact record in trigger context
   * @return master object
   */
  public static BrokerCloudEventModel.MasterNode buildAccountNode(
    Contact record
  ) {
    Map<String, String> dataContractMap = new Map<String, String>{
      'sourceObjectName' => OBJECT_CONTACT,
      'sourceObjectExtId' => record.External_Id__c,
      'targetObjects_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_extObjectName' => OBJECT_ACCOUNT
    };
    return BrokerCloudEventModel.buildMasterNode(dataContractMap);
  }

  /**
   * @description Build the contact node for the cloud event
   * @param record the new contact record in trigger context
   * @return master object
   */
  public static BrokerCloudEventModel.MasterNode buildContactNode(
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

    // Only add serialized merge node if it's not null
    BrokerCloudEventModel.ContactMergeTargetNode mergeNode = buildMergeContactNode(
      record
    );
    if (mergeNode != null) {
      dataContractMap.put('merge_contact', JSON.serialize(mergeNode));
    }
    return BrokerCloudEventModel.buildMasterNode(dataContractMap);
  }

  /**
   * @description Build the contact node for the cloud event
   * @param record financialAccount Financial Account record
   * @param acc parent Account record
   * @return BrokerCloudEventModel.MasterNode MasterNode for cloud event
   */
  public static BrokerCloudEventModel.MasterNode buildFinancialAccountNode(
    FinServ__FinancialAccount__c record,
    Account acc
  ) {
    Map<String, String> dataContractMap = new Map<String, String>{
      'sourceObjectParentExtIdName' => FIELD_FINANCIAL_ACCOUNT_PRIMARY_OWNER,
      'sourceObjectParentExtId' => acc.External_Id__c,
      'sourceObjectName' => OBJECT_FINANCIAL_ACCOUNT,
      'sourceObjectExtId' => record.Account_Key__c,
      'targetObjects_extIdField' => record.Account_Key__c,
      'targetObjects_extObjectName' => OBJECT_FINANCIAL_ACCOUNT,
      'targetObjects_parent_objectName' => OBJECT_ACCOUNT,
      'targetObjects_parent_extIdField' => FIELD_EXTERNAL_ID,
      'targetObjects_parent_referenceField' => FIELD_FINANCIAL_ACCOUNT_PRIMARY_OWNER,
      'targetObjects_parent_extId' => acc.External_Id__c
    };
    return BrokerCloudEventModel.buildMasterNode(dataContractMap);
  }

  /**
   * @description Build the contact info node for the cloud event
   * @param record the new contact record in trigger context
   * @param contactInfoObjectName the contact info object name
   * @return master object
   */
  public static BrokerCloudEventModel.MasterNode buildContactInfoNode(
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
    return BrokerCloudEventModel.buildMasterNode(dataContractMap);
  }

  /**
   * @description Build the broker code node for the cloud event
   * @param record the new contact record in trigger context
   * @return master object
   */
  public static BrokerCloudEventModel.MasterNode buildBrokerCodeNode(
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
    return BrokerCloudEventModel.buildMasterNode(dataContractMap);
  }

  /**
   * @description method used for building the cloud event structure using the loan app details
   * @author Deepro De | 05-30-2024
   * @param record
   * @return BrokerCloudEventModel.MasterNode
   * @runTests  BrokerCloudEventBuilderTest.testBuildFinancialAccountNode
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

  /**
   * @description Builds a ContactMergeTargetNode used in broker cloud event payloads.
   *              Returns null if required fields are missing.
   * @author      Madhuri Edke
   * @param       record The Contact record used to populate the node.
   * @return      BrokerCloudEventModel.ContactMergeTargetNode or null if input is incomplete.
   */
  private static BrokerCloudEventModel.ContactMergeTargetNode buildMergeContactNode(
    Contact record
  ) {
    List<String> requiredFields = new List<String>{
      'Survivor_Party_Id__c',
      'Victim_Party_Id__c'
    };

    for (String fieldName : requiredFields) {
      if (record.get(fieldName) == null) {
        return null;
      }
    }

    BrokerCloudEventModel.ContactMergeTargetNode mergeContactNode = new BrokerCloudEventModel.ContactMergeTargetNode();
    mergeContactNode.survivorPartyId = record.Survivor_Party_Id__c;
    mergeContactNode.victimPartyId = record.Victim_Party_Id__c;
    return mergeContactNode;
  }
}
