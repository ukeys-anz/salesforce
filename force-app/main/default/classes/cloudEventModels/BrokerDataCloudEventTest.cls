/**
 * @author Zhiren Jason Guan
 * @since  21/02/2024
 * @description Test class for BrokerDataCloudEvent related classes
 */

@IsTest
private class BrokerDataCloudEventTest {
  private static final String CONTACT_JSON = '{"Name":"TEST_NAME", "External_Id__c":"TEST_EXTERNAL_ID", "Broker_Customer_Profile__r":{"External_Id__c":"TEST_ACCOUNT_EXTERNAL_ID"}}';

  static Contact createTestContact() {
    return (Contact) JSON.deserialize(CONTACT_JSON, Contact.class);
  }

  static List<BrokerDataCloudEventModel.MasterNode> createTestMasterNodes() {
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
    BrokerDataCloudEventModel.MasterNode masterNode = BrokerDataCloudEventModel.buildMasterNode(
      dataContractMap
    );
    List<BrokerDataCloudEventModel.MasterNode> masterNodes = new List<BrokerDataCloudEventModel.MasterNode>();
    masterNodes.add(masterNode);
    return masterNodes;
  }

  @IsTest
  static void testBrokerDataCloudEventModel() {
    Contact testContact = createTestContact();
    List<BrokerDataCloudEventModel.MasterNode> masterNodes = createTestMasterNodes();
    Test.startTest();
    BrokerDataCloudEventModel model = new BrokerDataCloudEventModel(
      testContact,
      masterNodes,
      'TEST_EVENT'
    );
    BrokerDataCloudEventModel.BrokerCloudEventDataModel cloudEventData = (BrokerDataCloudEventModel.BrokerCloudEventDataModel) model.ce_data;
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
    List<BrokerDataCloudEventModel.MasterNode> masterNodes = createTestMasterNodes();
    BrokerDataCloudEventModel.MasterNode masterNode = masterNodes[0];
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
    Test.startTest();
    BrokerDataCloudEventModel.MasterNode contactNode = BrokerDataContactCEBuilder.buildContactNode(
      testContact
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
    BrokerDataCloudEventModel.MasterNode accountNode = BrokerDataContactCEBuilder.buildAccountNode(
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
    BrokerDataCloudEventModel.MasterNode brokerCodeNode = BrokerDataContactCEBuilder.buildBrokerCodeNode(
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
    BrokerDataCloudEventModel.MasterNode contactPointPhoneNode = BrokerDataContactCEBuilder.buildContactInfoNode(
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
    BrokerDataCloudEventModel.MasterNode contactPointAddressNode = BrokerDataContactCEBuilder.buildContactInfoNode(
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
    BrokerDataCloudEventModel.MasterNode contactPointEmailNode = BrokerDataContactCEBuilder.buildContactInfoNode(
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
}
