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
  static void testFilterBrokerContacts() {
    List<Contact> brokerContacts = createTestContactList(RECORD_TYPE_ID_BROKER);
    List<Contact> staffContacts = createTestContactList(RECORD_TYPE_ID_STAFF);
    List<Contact> combinedContacts = new List<Contact>();
    combinedContacts.addAll(brokerContacts);
    combinedContacts.addAll(staffContacts);
    Test.startTest();
    List<Contact> results = RetailBrokerContactTriggerHandler.filterBrokerContacts(
      combinedContacts
    );
    Test.stopTest();
    Assert.areEqual(
      brokerContacts.size(),
      results.size(),
      'filter results size should be same as brokerContacts size'
    );
  }

  @IsTest
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
    RetailBrokerContactTriggerHandler.mockBrokerSettings = new BrokerSettings__c(
      BypassBrokerSyncEvents__c = true
    );
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
    RetailBrokerContactTriggerHandler.mockBrokerSettings = new BrokerSettings__c(
      BypassBrokerSyncEvents__c = false
    );
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

  @IsTest
  static void testRetrieveBrokerSettings() {
    Test.startTest();
    BrokerSettings__c brokerSettings = RetailBrokerContactTriggerHandler.brokerSettings();
    Test.stopTest();
    Assert.isNotNull(brokerSettings, 'Broker settings should not be null');
  }
}
