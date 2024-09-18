/**
 * @author Zhiren Jason Guan
 * @since  21/02/2024
 * @description Test class for RetailBrokerContactActions
 */

@IsTest
private class RetailBrokerContactActionsTest {
  private static final Id RECORD_TYPE_ID_BROKER = SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Broker')
    .recordTypeId;

  static List<Contact> createTestContactList() {
    List<Contact> contacts = new List<Contact>();
    for (Integer counter = 0; counter < 10; counter++) {
      Contact brokerContact = new Contact();
      brokerContact.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
      brokerContact.FirstName = 'TestFirst';
      brokerContact.LastName = 'TestLast';
      brokerContact.External_Id__c = '123456';
      brokerContact.OCV_Event_Version__c = 1;
      brokerContact.RecordTypeId = RECORD_TYPE_ID_BROKER;
      contacts.add(brokerContact);
    }
    return contacts;
  }

  static List<Contact> updateContactList(
    List<Contact> contactList,
    Decimal version,
    String syncStatus
  ) {
    for (Integer counter = 0; counter < contactList.size(); counter++) {
      contactList[counter].OCV_Event_Version__c = version;
      contactList[counter].Sync_Status__c = syncStatus;
    }
    return contactList;
  }

  @IsTest
  static void testProcessOCVSync() {
    List<Contact> newContactsForAdd = createTestContactList();
    List<Contact> oldContactsForAdd = newContactsForAdd.deepClone(true);
    updateContactList(oldContactsForAdd, 0, null);
    Map<Id, Contact> oldMapForAdd = new Map<Id, Contact>(oldContactsForAdd);
    Test.startTest();
    List<Contact> results = RetailBrokerContactActions.processOCVSync(
      newContactsForAdd,
      oldMapForAdd
    );
    Test.stopTest();
    Assert.areEqual(
      newContactsForAdd.size(),
      results.size(),
      'The size of the result should be the same as the input'
    );
    Assert.areEqual(
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG,
      results[0].Sync_Status__c,
      'The sync status should be set to Broker Org'
    );
  }

  @IsTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  // Added SuppressWarnings as calling method is void and didn't return anything for Assert.
  static void testPublishBrokerEvents() {
    // Prepare test data for add event
    List<Contact> newContactsForAdd = createTestContactList();
    List<Contact> oldContactsForAdd = newContactsForAdd.deepClone(true);
    updateContactList(
      newContactsForAdd,
      1,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    updateContactList(oldContactsForAdd, 0, null);
    // Prepare test data for update event
    List<Contact> newContactsForUpdate = createTestContactList();
    List<Contact> oldContactsForUpdate = newContactsForUpdate.deepClone(true);
    updateContactList(
      newContactsForUpdate,
      2,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    updateContactList(
      oldContactsForUpdate,
      1,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    Test.startTest();
    // no assertion required for void methods
    RetailBrokerContactActions.publishBrokerEvents(
      newContactsForAdd,
      new Map<Id, Contact>(oldContactsForAdd)
    );
    RetailBrokerContactActions.publishBrokerEvents(
      newContactsForUpdate,
      new Map<Id, Contact>(oldContactsForUpdate)
    );
    Test.stopTest();
  }

  @IsTest
  static void testIsBrokerAddedPositive() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(
      newContacts,
      1,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    updateContactList(oldContacts, 0, null);
    Test.startTest();
    Boolean isBrokerAdded = RetailBrokerContactActions.isBrokerAdded(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isTrue(isBrokerAdded, 'The broker should indicate add event');
  }

  @IsTest
  static void testIsBrokerAddedInvalidVersion() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    Test.startTest();
    Boolean isBrokerAdded = RetailBrokerContactActions.isBrokerAdded(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(isBrokerAdded, 'The broker should not indicate add event');
  }

  @IsTest
  static void testIsBrokerAddedInvalidNewStatus() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(newContacts, 1, null);
    updateContactList(oldContacts, 0, null);
    Test.startTest();
    Boolean isBrokerAdded = RetailBrokerContactActions.isBrokerAdded(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(isBrokerAdded, 'The broker should not indicate add event');
  }
  @IsTest
  static void testIsBrokerAddedInvalidOldStatus() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(
      newContacts,
      1,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    updateContactList(
      oldContacts,
      0,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    Test.startTest();
    Boolean isBrokerAdded = RetailBrokerContactActions.isBrokerAdded(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(isBrokerAdded, 'The broker should not indicate add event');
  }

  @IsTest
  static void testIsBrokerUpdatedPositive() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(
      newContacts,
      2,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    updateContactList(
      oldContacts,
      1,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    Test.startTest();
    Boolean isBrokerUpdated = RetailBrokerContactActions.isBrokerUpdated(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isTrue(isBrokerUpdated, 'The broker should indicate update event');
  }

  @IsTest
  static void testIsBrokerUpdatedInvalidVersion() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    Test.startTest();
    Boolean isBrokerUpdated = RetailBrokerContactActions.isBrokerUpdated(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(
      isBrokerUpdated,
      'The broker should not indicate update event'
    );
  }

  @IsTest
  static void testIsBrokerUpdatedInvalidNewStatus() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(newContacts, 2, null);
    updateContactList(oldContacts, 1, null);
    Test.startTest();
    Boolean isBrokerUpdated = RetailBrokerContactActions.isBrokerUpdated(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(
      isBrokerUpdated,
      'The broker should not indicate update event'
    );
  }

  @IsTest
  static void testIsBrokerUpdatedInvalidOldStatus() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(
      newContacts,
      2,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    updateContactList(oldContacts, 1, null);
    Test.startTest();
    Boolean isBrokerUpdated = RetailBrokerContactActions.isBrokerUpdated(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(
      isBrokerUpdated,
      'The broker should not indicate update event'
    );
  }

  @IsTest
  static void testSyncStatusPositive() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(oldContacts, 0, null);
    Test.startTest();
    Boolean isEligible = RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isTrue(
      isEligible,
      'The broker should be eligible to set Broker Org'
    );
  }

  @IsTest
  static void testSyncStatusInvalidVersion() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    Test.startTest();
    Boolean isEligible = RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(
      isEligible,
      'The broker should not be eligible to set Broker Org'
    );
  }

  @IsTest
  static void testSyncStatusInvalidOldStatus() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(newContacts, 1, null);
    updateContactList(
      oldContacts,
      0,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    Test.startTest();
    Boolean isEligible = RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(
      isEligible,
      'The broker should not be eligible to set Broker Org'
    );
  }

  @IsTest
  static void testSyncStatusInvalidNewStatus() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(
      newContacts,
      1,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    updateContactList(oldContacts, 0, null);
    Test.startTest();
    Boolean isEligible = RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(
      isEligible,
      'The broker should not be eligible to set Broker Org'
    );
  }

  @IsTest
  static void testSyncStatusInvalidBlocked() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(
      newContacts,
      1,
      RetailBrokerContactActions.SYNC_STATUS_BLOCKED
    );
    updateContactList(oldContacts, 0, null);
    Test.startTest();
    Boolean isEligible = RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(
      isEligible,
      'The broker should not be eligible to set Broker Org'
    );
  }

  @IsTest
  static void testSyncStatusBlocked() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(
      newContacts,
      0,
      RetailBrokerContactActions.SYNC_STATUS_BLOCKED
    );
    updateContactList(
      oldContacts,
      1,
      RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG
    );
    Test.startTest();
    Boolean isEligible = RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isFalse(
      isEligible,
      'The broker should be able to set to Blocked and should not be eligible to set Broker Org'
    );
  }

  @IsTest
  static void testSyncStatusFromBlockedToBrokerOrg() {
    List<Contact> newContacts = createTestContactList();
    List<Contact> oldContacts = newContacts.deepClone(true);
    updateContactList(newContacts, 1, null);
    updateContactList(
      oldContacts,
      0,
      RetailBrokerContactActions.SYNC_STATUS_BLOCKED
    );
    Test.startTest();
    Boolean isEligible = RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
      newContacts[0],
      oldContacts[0]
    );
    Test.stopTest();
    Assert.isTrue(
      isEligible,
      'The broker should be eligible to set to Broker Org from Blocked'
    );
  }
}
