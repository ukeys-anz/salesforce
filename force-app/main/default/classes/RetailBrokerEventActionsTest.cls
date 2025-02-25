/**
 * @author Zhiren Jason Guan
 * @since  04/03/2024
 * @description Test class for RetailBrokerEventActions
 */

@IsTest
private class RetailBrokerEventActionsTest {
  private static final Id RECORD_TYPE_ID_BROKER = SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Broker')
    .recordTypeId;

  public static Lib_MockProvider retailBrokerRepo = Lib_MockProvider.forType(
    RetailBrokerRepository.class
  );

  static List<Contact> createTestContactList(Id recordTypeId) {
    List<Contact> contacts = new List<Contact>();
    for (Integer counter = 0; counter < 10; counter++) {
      Contact brokerContact = new Contact();
      brokerContact.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
      brokerContact.FirstName = 'TestFirst';
      brokerContact.LastName = 'TestLast';
      brokerContact.External_Id__c = '123456';
      brokerContact.OCV_Event_Version__c = 1;
      brokerContact.RecordTypeId = recordTypeId;
      contacts.add(brokerContact);
    }
    return contacts;
  }

  @IsTest
  static void testPublishEvent() {
    List<Contact> newContacts = createTestContactList(RECORD_TYPE_ID_BROKER);
    Map<Id, String> brokerIdToEventTypeMap = new Map<Id, String>();
    for (Contact broker : newContacts) {
      brokerIdToEventTypeMap.put(
        broker.Id,
        RetailBrokerEventActions.BROKER_EVENT_ADD
      );
    }
    retailBrokerRepo.mock('getBrokerContactsByIds', newContacts);
    Test.startTest();
    List<SObject> successEvents = RetailBrokerEventActions.publishEventForBrokers(
      brokerIdToEventTypeMap
    );
    Test.stopTest();
    Assert.areEqual(
      newContacts.size(),
      successEvents.size(),
      'The size of success events should be the same as the input size'
    );
    Integer counter = 0;
    for (SObject event : successEvents) {
      Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
        (String) event.get('Data_1__c')
      );
      Assert.areEqual(
        'Broker/' + newContacts[counter].External_Id__c,
        result.get('ce_xtargets'),
        'The external id should be the same as the contact external id'
      );
      Assert.areEqual(
        newContacts[counter].OCV_Event_Version__c,
        result.get('ce_sequence'),
        'The sequence should be the same as the contact OCV event version'
      );
      counter++;
    }
  }

  @IsTest
  static void testPublishEventEventNegative() {
    createTestContactList(RECORD_TYPE_ID_BROKER);
    retailBrokerRepo.mock(
      'getBrokerContactsByIds',
      new List<FinServ__FinancialAccount__c>{}
    );
    Test.startTest();
    List<SObject> successEvents = RetailBrokerEventActions.publishEventForBrokers(
      null
    );
    Test.stopTest();
    Assert.isTrue(
      successEvents.isEmpty(),
      'The success events should be empty as no valid event map passed in'
    );
  }

  @IsTest
  static void testGenerateBrokerCEModel() {
    Contact newContact = createTestContactList(RECORD_TYPE_ID_BROKER)[0];
    Test.startTest();
    BrokerCloudEventModel addModel = RetailBrokerEventActions.generateBrokerCEModel(
      newContact,
      RetailBrokerEventActions.BROKER_EVENT_ADD
    );
    BrokerCloudEventModel updateModel = RetailBrokerEventActions.generateBrokerCEModel(
      newContact,
      RetailBrokerEventActions.BROKER_EVENT_UPDATE
    );
    Test.stopTest();
    Assert.areEqual(
      'Broker/' + newContact.External_Id__c,
      addModel.ce_xtargets,
      'The external id should be the same as the contact external id'
    );
    Assert.areEqual(
      newContact.OCV_Event_Version__c,
      addModel.ce_sequence,
      'The sequence should be the same as the contact OCV event version'
    );
    Assert.isTrue(
      addModel.ce_type.contains(RetailBrokerEventActions.BROKER_EVENT_ADD),
      'The ce_type should be add event'
    );
    Assert.areEqual(
      'Broker/' + newContact.External_Id__c,
      updateModel.ce_xtargets,
      'The external id should be the same as the contact external id'
    );
    Assert.areEqual(
      newContact.OCV_Event_Version__c,
      updateModel.ce_sequence,
      'The sequence should be the same as the contact OCV event version'
    );
    Assert.isTrue(
      updateModel.ce_type.contains(
        RetailBrokerEventActions.BROKER_EVENT_UPDATE
      ),
      'The ce_type should be update event'
    );
  }

  @IsTest
  static void testBuildAddContract() {
    Contact newContact = createTestContactList(RECORD_TYPE_ID_BROKER)[0];
    Test.startTest();
    List<BrokerCloudEventModel.MasterNode> results = RetailBrokerEventActions.buildAddContact(
      newContact
    );
    Test.stopTest();
    BrokerCloudEventModel.MasterNode contactNode = results[1];
    Assert.areEqual(
      6,
      results.size(),
      'The size of master nodes in the the contract should be 6'
    );
    Assert.areEqual(
      newContact.External_Id__c,
      contactNode.sourceObjectExtId,
      'The sourceObjectExtId should be the same as the contact external id'
    );
  }

  @IsTest
  static void testBuildUpdateContract() {
    Contact newContact = createTestContactList(RECORD_TYPE_ID_BROKER)[0];
    Test.startTest();
    List<BrokerCloudEventModel.MasterNode> results = RetailBrokerEventActions.buildUpdateContact(
      newContact
    );
    Test.stopTest();
    BrokerCloudEventModel.MasterNode contactNode = results[4];
    Assert.areEqual(
      6,
      results.size(),
      'The size of master nodes in the the contract should be 6'
    );
    Assert.areEqual(
      newContact.External_Id__c,
      contactNode.sourceObjectExtId,
      'The sourceObjectExtId should be the same as the contact external id'
    );
  }
}
