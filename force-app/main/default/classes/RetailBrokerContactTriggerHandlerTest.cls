/**
 * @author Zhiren Jason Guan
 * @since  20/02/2024
 * @description Test class for RetailBrokerContactTriggerHandler
 */
@IsTest
private class RetailBrokerContactTriggerHandlerTest {
  private static final Id RECORD_TYPE_ID_BROKER = SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Broker')
    .recordTypeId;
  private static final Id RECORD_TYPE_ID_STAFF = SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Staff')
    .recordTypeId;
  static Lib_MockProvider brokerSettingsMock = Lib_MockProvider.forType(
    CustomSettingsRepository.class
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
  static void testFilterRetailBrokerContactPositive() {
    // Prepare broker contact
    Contact brokerContact = new Contact();
    brokerContact.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    brokerContact.RecordTypeId = RECORD_TYPE_ID_BROKER;

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
  static void testFilterRetailBrokerContactNegative() {
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
    Account personAccount = TestDataFactory.createPersonAccount(
      'pa-123456',
      true
    );
    List<Contact> testContacts = createTestContactList(RECORD_TYPE_ID_BROKER);
    for (Contact contact : testContacts) {
      contact.Broker_Customer_Profile__c = personAccount.Id;
    }
    insert testContacts;
    Map<Id, Contact> testContactMap = new Map<Id, Contact>(testContacts);
    Set<Id> testContactIds = testContactMap.keySet();
    Test.startTest();
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerEvent__c = true;
    brokerSettingsMock.mock('brokerSettings', mockSettings);
    updateContactList(testContacts, 1);
    update testContacts;
    List<Contact> resultContacts = [
      SELECT Id, Sync_Status__c
      FROM Contact
      WHERE Id IN :testContactIds
    ];
    Test.stopTest();
    Assert.areEqual(
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG,
      resultContacts[0].Sync_Status__c,
      'Sync status should be set to Broker Org'
    );
  }

  @IsTest
  static void testUpdateTriggerBypassOff() {
    Account personAccount = TestDataFactory.createPersonAccount(
      'pa-123456',
      true
    );
    List<Contact> testContacts = createTestContactList(RECORD_TYPE_ID_BROKER);
    for (Contact contact : testContacts) {
      contact.Broker_Customer_Profile__c = personAccount.Id;
    }
    insert testContacts;
    Map<Id, Contact> testContactMap = new Map<Id, Contact>(testContacts);
    Set<Id> testContactIds = testContactMap.keySet();
    Test.startTest();
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerEvent__c = false;
    brokerSettingsMock.mock('brokerSettings', mockSettings);
    updateContactList(testContacts, 1);
    update testContacts;
    updateContactList(testContacts, 2);
    update testContacts;
    List<Contact> resultContacts = [
      SELECT Id, Sync_Status__c
      FROM Contact
      WHERE Id IN :testContactIds
    ];
    Test.stopTest();
    Assert.areEqual(
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG,
      resultContacts[0].Sync_Status__c,
      'Sync status should remain as Broker Org'
    );
  }
}
