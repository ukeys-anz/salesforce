/**
 * @author Zhiren Jason Guan
 * @since  20/02/2024
 * @description Test class for RetailBrokerContactTriggerHandler
 */
@IsTest
private class RetailBrokerContactTriggerHandlerTest {
  public static Lib_MockProvider retailBrokerRepo = Lib_MockProvider.forType(
    RetailBrokerRepository.class
  );
  private static final Id RECORD_TYPE_ID_BROKER = RTContact.broker;
  private static final Id RECORD_TYPE_ID_STAFF = RTContact.staff;
  static Lib_MockProvider brokerSettingsMock = Lib_MockProvider.forType(
    BrokerSettingsRepository.class
  );

  static List<Contact> createTestContactList(Id recordTypeId) {
    List<Contact> contacts = new List<Contact>();
    for (Integer counter = 0; counter < 10; counter++) {
      Contact brokerContact = new Contact();
      brokerContact.FirstName = 'TestFirst' + counter;
      brokerContact.LastName = 'TestLast' + counter;
      brokerContact.External_Id__c = 'broker-12345' + counter;
      brokerContact.RecordTypeId = recordTypeId;
      contacts.add(brokerContact);
    }
    return contacts;
  }

  static List<Contact> updateContactList(
    List<Contact> contactList,
    Decimal version
  ) {
    for (Integer counter = 0; counter < contactList.size(); counter++) {
      contactList[counter].OCV_Event_Version__c = version;
    }
    return contactList;
  }

  @IsTest
  static void testIsValidRecordPositive() {
    // Prepare broker contact
    Contact brokerContact = new Contact();
    brokerContact.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    brokerContact.RecordTypeId = RECORD_TYPE_ID_BROKER;
    brokerContact.Broker_Accreditation_Type__c = 'Retail';

    Test.startTest();
    RetailBrokerContactTriggerHandler handler = new RetailBrokerContactTriggerHandler();
    Boolean isBrokerContact = handler.isValidRecord(brokerContact);
    Test.stopTest();

    Assert.areEqual(
      true,
      isBrokerContact,
      'Should return true for broker contact'
    );
  }

  @IsTest
  static void testIsValidRecordNegative() {
    // Prepare staff contact
    Contact staffContact = new Contact();
    staffContact.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    staffContact.RecordTypeId = RECORD_TYPE_ID_STAFF;

    Test.startTest();
    RetailBrokerContactTriggerHandler handler = new RetailBrokerContactTriggerHandler();
    Boolean isBrokerContact = handler.isValidRecord(staffContact);
    Test.stopTest();

    Assert.areEqual(
      false,
      isBrokerContact,
      'Should return false for staff contact'
    );
  }

  @isTest
  static void testUpdateTriggerBypassOn() {
    List<Contact> testContacts = createTestContactList(RECORD_TYPE_ID_BROKER);
    testContacts[0].Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    testContacts[0].OCV_Event_Version__c = null;
    testContacts[0].Sync_Status__c = null;
    Contact oldContact = testContacts[0];

    testContacts[1].Id = oldContact.Id;
    testContacts[1].OCV_Event_Version__c = 1;
    testContacts[1].Sync_Status__c = 'Broker Org';
    testContacts[1].CommercialTPMISAO__c = 'CommTMPITest001';
    Contact contactNew = testContacts[1];
    Lib_MockProvider.forType(RetailBrokerRepository.class)
      .mock('getBrokerContactsByIds', new List<Contact>{ contactNew });
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerEvent__c = true;
    brokerSettingsMock.mock('get', mockSettings);

    RetailBrokerContactActions.publishBrokerEvents(
      new List<Contact>{ contactNew },
      new Map<Id, Contact>{ oldContact.Id => oldContact }
    );

    Integer cloudEventsAfter = CloudEventController.cloudEvents?.size() ?? 0;

    Assert.areEqual(0, cloudEventsAfter, 'No cloud events should be created.');
  }

  @IsTest
  static void testUpdateTriggerBypassOff() {
    List<Contact> testContacts = createTestContactList(RECORD_TYPE_ID_BROKER);
    testContacts[0].Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    testContacts[0].OCV_Event_Version__c = null;
    testContacts[0].Sync_Status__c = null;
    Contact oldContact = testContacts[0];

    testContacts[1].Id = oldContact.Id;
    testContacts[1].OCV_Event_Version__c = 1;
    testContacts[1].Sync_Status__c = 'Broker Org';
    testContacts[1].CommercialTPMISAO__c = 'CommTMPITest001';
    Contact contactNew = testContacts[1];
    Lib_MockProvider.forType(RetailBrokerRepository.class)
      .mock('getBrokerContactsByIds', new List<Contact>{ contactNew });
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerEvent__c = false;
    brokerSettingsMock.mock('get', mockSettings);

    RetailBrokerContactActions.publishBrokerEvents(
      new List<Contact>{ contactNew },
      new Map<Id, Contact>{ oldContact.Id => oldContact }
    );

    Integer cloudEventsAfter = CloudEventController.cloudEvents?.size() ?? 0;

    Assert.areEqual(1, cloudEventsAfter, 'Cloud event should be created.');
  }

  /**
   * @description test method with DMLs to cover contact trigger
   * @author  Saurabh Chauhan | Salesforce | 20-03-2025
   **/
  @IsTest
  static void testTriggers() {
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerEvent__c = true;
    brokerSettingsMock.mock('get', mockSettings);

    Account personAccount = TestDataFactory.createPersonAccount(
      'pa-123456',
      true
    );
    List<Contact> testContacts = createTestContactList(RECORD_TYPE_ID_BROKER);
    for (Contact contact : testContacts) {
      contact.Broker_Customer_Profile__c = personAccount.Id;
    }
    //DML Needed to cover trigger
    insert testContacts;

    Test.startTest();
    updateContactList(testContacts, 1);
    //DML Needed to cover trigger
    update testContacts;

    Assert.areEqual(
      1,
      testContacts[0].OCV_Event_Version__c,
      'Contact got updated'
    );
    Test.stopTest();
  }
}
