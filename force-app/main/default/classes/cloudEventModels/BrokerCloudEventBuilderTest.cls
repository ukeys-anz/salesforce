/**
 * @author Zhiren Jason Guan
 * @since  21/02/2024
 * @description Test class for BrokerDataCloudEvent related classes
 */

@IsTest
private class BrokerCloudEventBuilderTest {
  private static final String CONTACT_JSON = '{"Name":"TEST_NAME", "External_Id__c":"TEST_EXTERNAL_ID", "Broker_Customer_Profile__r":{"External_Id__c":"TEST_ACCOUNT_EXTERNAL_ID"}}';

  static Contact createTestContact() {
    return (Contact) JSON.deserialize(CONTACT_JSON, Contact.class);
  }

  static List<BrokerCloudEventModel.MasterNode> createTestMasterNodes() {
    Map<String, String> dataContractMap = new Map<String, String>{
      'sourceObjectName' => 'Broker_Customer_Profile__c',
      'sourceObjectParentExtId' => 'Broker_Name_External_Id__c',
      'sourceObjectParentExtIdName' => 'Broker_Name__c',
      'targetObjects_extIDField' => 'External_Id__c',
      'targetObjects_extObjectName' => 'Account',
      'targetObjects_parent_objectName' => 'Broker__c',
      'targetObjects_parent_extIDField' => 'External_Id__c',
      'targetObjects_parent_referenceField' => 'Broker__c',
      'targetObjects_parent_extID' => 'Broker_Name_External_Id__c'
    };
    BrokerCloudEventModel.MasterNode masterNode = BrokerCloudEventModel.buildMasterNode(
      dataContractMap
    );
    List<BrokerCloudEventModel.MasterNode> masterNodes = new List<BrokerCloudEventModel.MasterNode>();
    masterNodes.add(masterNode);
    return masterNodes;
  }

  @IsTest
  static void testBrokerCloudEventModel() {
    Contact testContact = createTestContact();
    List<BrokerCloudEventModel.MasterNode> masterNodes = createTestMasterNodes();
    Test.startTest();
    BrokerDataCloudEventModel model = new BrokerDataCloudEventModel(
      testContact,
      masterNodes,
      'TEST_EVENT'
    );
    BrokerCloudEventModel.BrokerCloudEventDataModel cloudEventData = (BrokerCloudEventModel.BrokerCloudEventDataModel) model.ce_data;
    Test.stopTest();
    Assert.areEqual(
      'Contact/TEST_NAME',
      model.ce_subject,
      'ce_subject should be Contact/TEST_NAME'
    );
    Assert.areEqual(
      true,
      model.ce_type.contains('TEST_EVENT'),
      'ce_type should contain TEST_EVENT'
    );
    Assert.areEqual(
      masterNodes,
      cloudEventData.data,
      'ce_data.data should be masterNodes'
    );
  }

  @IsTest
  static void testBuildMasterNode() {
    Test.startTest();
    List<BrokerCloudEventModel.MasterNode> masterNodes = createTestMasterNodes();
    BrokerCloudEventModel.MasterNode masterNode = masterNodes[0];
    Test.stopTest();
    Assert.isNotNull(masterNode, 'Master Node should be created successfully');
    Assert.isNotNull(
      masterNode.targetObjects,
      'targetObjects should be created successfully'
    );
    Assert.isNotNull(
      masterNode.targetObjects.parent,
      'targetObjects parent should be created successfully'
    );
    Assert.areEqual(
      'Broker_Customer_Profile__c',
      masterNode.sourceObjectName,
      'sourceObjectName should be Broker_Customer_Profile__c'
    );
  }

  @IsTest
  static void testBuildContactNode() {
    Contact testContact = createTestContact();
    List<Contact> oldContacts = new List<Contact>{ testContact }
      .deepClone(true);
    Test.startTest();
    BrokerCloudEventModel.MasterNode contactNode = BrokerCloudEventBuilder.buildContactNode(
      testContact,
      oldContacts[0]
    );
    Test.stopTest();
    Assert.areEqual(
      'Contact',
      contactNode.sourceObjectName,
      'sourceObjectName should be Contact'
    );
  }

  @IsTest
  static void testBuildAccountNode() {
    Contact testContact = createTestContact();
    Test.startTest();
    BrokerCloudEventModel.MasterNode accountNode = BrokerCloudEventBuilder.buildAccountNode(
      testContact
    );
    Test.stopTest();
    Assert.areEqual(
      'Contact',
      accountNode.sourceObjectName,
      'sourceObjectName should be Contact'
    );
  }

  @IsTest
  static void testBuildBrokerCodeNode() {
    Contact testContact = createTestContact();
    Test.startTest();
    BrokerCloudEventModel.MasterNode brokerCodeNode = BrokerCloudEventBuilder.buildBrokerCodeNode(
      testContact
    );
    Test.stopTest();
    Assert.areEqual(
      'Broker_Code__c',
      brokerCodeNode.sourceObjectName,
      'sourceObjectName should be Broker_Code__c'
    );
  }

  @IsTest
  static void testBuildContactPointPhoneNode() {
    Contact testContact = createTestContact();
    Test.startTest();
    BrokerCloudEventModel.MasterNode contactPointPhoneNode = BrokerCloudEventBuilder.buildContactInfoNode(
      testContact,
      'ContactPointPhone'
    );
    Test.stopTest();
    Assert.areEqual(
      'ContactPointPhone',
      contactPointPhoneNode.sourceObjectName,
      'sourceObjectName should be ContactPointPhone'
    );
  }

  @IsTest
  static void testBuildContactPointAddressNode() {
    Contact testContact = createTestContact();
    Test.startTest();
    BrokerCloudEventModel.MasterNode contactPointAddressNode = BrokerCloudEventBuilder.buildContactInfoNode(
      testContact,
      'ContactPointAddress'
    );
    Test.stopTest();
    Assert.areEqual(
      'ContactPointAddress',
      contactPointAddressNode.sourceObjectName,
      'sourceObjectName should be ContactPointAddress'
    );
  }

  @IsTest
  static void testBuildContactPointEmailNode() {
    Contact testContact = createTestContact();
    Test.startTest();
    BrokerCloudEventModel.MasterNode contactPointEmailNode = BrokerCloudEventBuilder.buildContactInfoNode(
      testContact,
      'ContactPointEmail'
    );
    Assert.areEqual(
      'ContactPointEmail',
      contactPointEmailNode.sourceObjectName,
      'sourceObjectName should be ContactPointEmail'
    );
    Test.stopTest();
  }

  /**
   * @description test function to test BrokerCloudEventBuilder.buildFinancialAccountNode
   * Assertion is made against the data populated in the returned data type
   */
  @IsTest
  static void testBuildFinancialAccountNode() {
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.Account_Key__c = 'AccKey20010101';
    Account accnt = new Account();
    accnt.External_Id__c = 'ExID20010101';
    Test.startTest();
    BrokerCloudEventModel.MasterNode brokerFinAccountMasterNode = BrokerCloudEventBuilder.buildFinancialAccountNode(
      financialAccount,
      accnt
    );
    Test.stopTest();
    Assert.areEqual(
      'FinServ__FinancialAccount__c',
      brokerFinAccountMasterNode.sourceObjectName,
      'sourceObjectName should be FinServ__FinancialAccount__c'
    );
    Assert.areEqual(
      'AccKey20010101',
      brokerFinAccountMasterNode.sourceObjectExtId,
      'sourceObjectExtId should be the Account Key of the Financial Account'
    );
    Assert.areEqual(
      'FinServ__PrimaryOwner__c',
      brokerFinAccountMasterNode.sourceObjectParentExtIdName,
      'sourceObjectParentExtIdName should be FinServ__PrimaryOwner__c'
    );
    Assert.areEqual(
      'ExID20010101',
      brokerFinAccountMasterNode.sourceObjectParentExtId,
      'sourceObjectParentExtId should be should be the External Id of the parent account'
    );
    BrokerCloudEventModel.TargetNode targetNode = brokerFinAccountMasterNode.targetObjects;
    Assert.areEqual(
      'FinServ__FinancialAccount__c',
      targetNode.extObjectName,
      'extObjectName should be FinServ__FinancialAccount__c'
    );
    Assert.areEqual(
      'AccKey20010101',
      targetNode.extIdField,
      'extIdField should be should be the Account Key of the Financial Account'
    );
    List<BrokerCloudEventModel.ParentNode> parent = targetNode.parent;
    Assert.areEqual(
      1,
      parent.size(),
      'parent node should have only one element'
    );
    Assert.areEqual(
      'FinServ__PrimaryOwner__c',
      parent[0].referenceField,
      'referenceField should be FinServ__PrimaryOwner__c'
    );
    Assert.areEqual(
      'Account',
      parent[0].objectName,
      'objectName should be Account'
    );
    Assert.areEqual(
      'External_Id__c',
      parent[0].extIdField,
      'extIdField should be External_Id__c'
    );
    Assert.areEqual(
      'ExID20010101',
      parent[0].extId,
      'extId should be the External Id of the parent account'
    );
  }
}
