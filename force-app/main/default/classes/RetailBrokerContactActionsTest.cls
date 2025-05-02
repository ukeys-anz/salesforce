/**
 * @author Zhiren Jason Guan
 * @since  21/02/2024
 * @description Test class for RetailBrokerContactActions
 */

@IsTest
private class RetailBrokerContactActionsTest {
  private static final Id RECORD_TYPE_ID_BROKER = RTContact.broker;
  static Lib_MockProvider brokerRelationMock = Lib_MockProvider.forType(
    BrokerRelationRepository.class
  );
  static Lib_MockProvider retailContactMock = Lib_MockProvider.forType(
    RetailContactRepository.class
  );
  static Lib_MockProvider brokerSettingsMock = Lib_MockProvider.forType(
    BrokerSettingsRepository.class
  );
  static Lib_MockProvider userInfoMock = Lib_MockProvider.forType(
    UserInfoRepository.class
  );
  //private static final Id RECORD_TYPE_ID_BROKER = RTContact.broker; Commented for backmerge error

  static Contact createTestContact() {
    Contact testContact = new Contact();
    testContact.FirstName = 'fNameContactTest001';
    testContact.LastName = 'lNameContactTest001';
    testContact.External_Id__c = 'exIdContactTest001';
    testContact.RecordTypeId = RECORD_TYPE_ID_BROKER;
    return testContact;
  }

  @IsTest
  static void testPublishBrokerEvents() {
    userInfoMock.mock('checkCustomPermission', true);
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerEvent__c = false;
    brokerSettingsMock.mock('get', mockSettings);

    Contact contactOld = createTestContact();
    contactOld.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    contactOld.OCV_Event_Version__c = null;
    contactOld.Sync_Status__c = null;

    //Test on add
    Contact contactNew = createTestContact();
    contactNew.Id = contactOld.Id;
    contactNew.OCV_Event_Version__c = 1;
    contactNew.Sync_Status__c = 'Broker Org';
    contactNew.CommercialTPMISAO__c = 'CommTMPITest001';

    Lib_MockProvider.forType(RetailBrokerRepository.class)
      .mock('getBrokerContactsByIds', new List<Contact>{ contactNew });

    RetailBrokerContactActions.publishBrokerEvents(
      new List<Contact>{ contactNew },
      new Map<Id, Contact>{ contactOld.Id => contactOld }
    );

    Integer cloudEventsAfter = CloudEventController.cloudEvents == null
      ? 0
      : CloudEventController.cloudEvents.size();
    Assert.areEqual(
      1,
      cloudEventsAfter,
      '1 Cloud event should be created for 1 record.'
    );
    Map<String, Object> cloudEventmap = (Map<String, Object>) JSON.deserializeUntyped(
      CloudEventController.cloudEvents[0].Data_1__c
    );
    Assert.areEqual(
      'anzx.salesforce.broker.v1alpha1.brokerdata.add',
      (String) cloudEventmap.get('ce_type'),
      'Event generated should be of type - add'
    );

    //Test on update
    contactOld = contactNew.clone(true, true);
    contactNew.OCV_Event_Version__c = 2;
    contactOld.OCV_Event_Version__c = 1;
    RetailBrokerContactActions.publishBrokerEvents(
      new List<Contact>{ contactNew },
      new Map<Id, Contact>{ contactOld.Id => contactOld }
    );
    cloudEventsAfter = CloudEventController.cloudEvents == null
      ? 0
      : CloudEventController.cloudEvents.size();
    Assert.areEqual(
      1,
      cloudEventsAfter,
      '1 Cloud event should be created for 1 record.'
    );
    cloudEventmap = (Map<String, Object>) JSON.deserializeUntyped(
      CloudEventController.cloudEvents[0].Data_1__c
    );
    Assert.areEqual(
      'anzx.salesforce.broker.v1alpha1.brokerdata.update',
      (String) cloudEventmap.get('ce_type'),
      'Event generated should be of type - update'
    );
  }

  @IsTest
  static void testProcessOCVSync() {
    Contact contactOld = createTestContact();
    contactOld.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    contactOld.OCV_Event_Version__c = 0;
    contactOld.Sync_Status__c = null;

    Contact contactNew = createTestContact();
    contactNew.Id = contactOld.Id;
    contactNew.OCV_Event_Version__c = 1;
    contactNew.Sync_Status__c = null;

    Test.startTest();
    List<Contact> results = RetailBrokerContactActions.processOCVSync(
      new List<Contact>{ contactNew },
      new Map<Id, Contact>{ contactOld.Id => contactOld }
    );
    Test.stopTest();
    Assert.areEqual(
      1,
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
  static void testIsRecordAnEligibleBrokerContact() {
    Contact contactNew = createTestContact();
    contactNew.CommercialTPMISAO__c = 'CommTMPITest001';
    Assert.isTrue(
      RetailBrokerContactActions.isRecordAnEligibleBrokerContact(contactNew),
      'Contact should be an eligible broker contact for publishing'
    );

    contactNew = createTestContact();
    contactNew.AssetFinanceTPMISAO__c = 'AssetFinanceTPMISAOTest001';
    Assert.isTrue(
      RetailBrokerContactActions.isRecordAnEligibleBrokerContact(contactNew),
      'Contact should be an eligible broker contact for publishing'
    );

    contactNew = createTestContact();
    contactNew.RetailTPMISAO__c = 'RetailTPMISAOTest001';
    contactNew.Is_Beta_Broker__c = true;
    Assert.isTrue(
      RetailBrokerContactActions.isRecordAnEligibleBrokerContact(contactNew),
      'Contact should be an eligible broker contact for publishing'
    );

    contactNew = createTestContact();
    contactNew.RetailTPMISAO__c = 'RetailTPMISAOTest001';
    contactNew.Is_Beta_Broker__c = false;
    Assert.isFalse(
      RetailBrokerContactActions.isRecordAnEligibleBrokerContact(contactNew),
      'Contact should not be an eligible broker contact for publishing'
    );

    contactNew = createTestContact();
    contactNew.RetailTPMISAO__c = '';
    contactNew.Is_Beta_Broker__c = true;
    Assert.isFalse(
      RetailBrokerContactActions.isRecordAnEligibleBrokerContact(contactNew),
      'Contact should not be an eligible broker contact for publishing'
    );
  }
  /* Commented for backmerge error -   RetailBrokerContactActionsTest    Method already defined: testIsSyncStatusValidForPublishing void RetailBrokerContactActionsTest.testIsSyncStatusValidForPublishing() */
  /* @IsTest
  static void testIsSyncStatusValidForPublishing() {
    Contact contactNew = createTestContact();
    contactNew.Sync_Status__c = null;
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusValidForPublishing(
        contactNew,
        null,
        ''
      ),
      'Contact should not be an eligible broker contact for publishing'
    );

    contactNew.Sync_Status__c = 'Broker Org';
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusValidForPublishing(
        contactNew,
        null,
        ''
      ),
      'Contact should not be an eligible broker contact for publishing'
    );
  }*/

  @IsTest
  static void testGetAction() {
    Contact contactOld = createTestContact();
    contactOld.OCV_Event_Version__c = 0;
    Contact contactNew = createTestContact();
    contactNew.OCV_Event_Version__c = 0;
    Assert.areEqual(
      '',
      RetailBrokerContactActions.getAction(contactNew, contactOld),
      'Action type should be blank, neither add nor update'
    );
    contactNew.OCV_Event_Version__c = 1;
    Assert.areEqual(
      'add',
      RetailBrokerContactActions.getAction(contactNew, contactOld),
      'Action type should be blank, neither add nor update'
    );
  }

  @IsTest
  static void testIsSyncStatusEligibleForUpdate() {
    Contact contactOld = createTestContact();
    contactOld.OCV_Event_Version__c = null;
    Contact contactNew = createTestContact();
    contactNew.OCV_Event_Version__c = 0;
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should not be eligible for update Sync Status'
    );

    contactNew.OCV_Event_Version__c = 1;
    contactOld.Sync_Status__c = 'Broker Org';
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should not be eligible for update Sync Status'
    );
    contactOld.Sync_Status__c = 'Blocked';
    contactNew.Sync_Status__c = 'Blocked';
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should not be eligible for update Sync Status'
    );

    contactOld.Sync_Status__c = 'Blocked';
    contactNew.Sync_Status__c = 'Broker Org';
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should not be eligible for update Sync Status'
    );

    contactOld.Sync_Status__c = 'Blocked';
    contactNew.Sync_Status__c = null;
    Assert.isTrue(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should be eligible for update Sync Status'
    );

    contactNew = createTestContact();
    contactNew.RetailTPMISAO__c = 'RetailTPMISAOTest001';
    contactNew.Is_Beta_Broker__c = true;
    Assert.isTrue(
      RetailBrokerContactActions.isRecordAnEligibleBrokerContact(contactNew),
      'Contact should be an eligible broker contact for publishing'
    );

    contactNew = createTestContact();
    contactNew.RetailTPMISAO__c = 'RetailTPMISAOTest001';
    contactNew.Is_Beta_Broker__c = false;
    Assert.isFalse(
      RetailBrokerContactActions.isRecordAnEligibleBrokerContact(contactNew),
      'Contact should not be an eligible broker contact for publishing'
    );

    contactNew = createTestContact();
    contactNew.RetailTPMISAO__c = '';
    contactNew.Is_Beta_Broker__c = true;
    Assert.isFalse(
      RetailBrokerContactActions.isRecordAnEligibleBrokerContact(contactNew),
      'Contact should not be an eligible broker contact for publishing'
    );
  }

  @IsTest
  static void testIsSyncStatusValidForPublishing() {
    Contact contactNew = createTestContact();
    contactNew.Sync_Status__c = null;
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusValidForPublishing(
        contactNew,
        null,
        ''
      ),
      'Contact should not be an eligible broker contact for publishing'
    );

    contactNew.Sync_Status__c = 'Broker Org';
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusValidForPublishing(
        contactNew,
        null,
        ''
      ),
      'Contact should not be an eligible broker contact for publishing'
    );
  }
  /* Commented for backmerge error-  Method already defined: testGetAction void RetailBrokerContactActionsTest.testGetAction() */
  /*@IsTest
  static void testGetAction() {
    Contact contactOld = createTestContact();
    contactOld.OCV_Event_Version__c = 0;
    Contact contactNew = createTestContact();
    contactNew.OCV_Event_Version__c = 0;
    Assert.areEqual(
      '',
      RetailBrokerContactActions.getAction(contactNew, contactOld),
      'Action type should be blank, neither add nor update'
    );
    contactNew.OCV_Event_Version__c = 1;
    Assert.areEqual(
      'add',
      RetailBrokerContactActions.getAction(contactNew, contactOld),
      'Action type should be blank, neither add nor update'
    );
  }*/

  /* Commented for backmerge error-  Method already defined: testIsSyncStatusEligibleForUpdate void RetailBrokerContactActionsTest.testIsSyncStatusEligibleForUpdate()*/
  /* @IsTest
  static void testIsSyncStatusEligibleForUpdate() {
    Contact contactOld = createTestContact();
    contactOld.OCV_Event_Version__c = null;
    Contact contactNew = createTestContact();
    contactNew.OCV_Event_Version__c = 0;
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should not be eligible for update Sync Status'
    );

    contactNew.OCV_Event_Version__c = 1;
    contactOld.Sync_Status__c = 'Broker Org';
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should not be eligible for update Sync Status'
    );
    contactOld.Sync_Status__c = 'Blocked';
    contactNew.Sync_Status__c = 'Blocked';
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should not be eligible for update Sync Status'
    );

    contactOld.Sync_Status__c = 'Blocked';
    contactNew.Sync_Status__c = 'Broker Org';
    Assert.isFalse(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should not be eligible for update Sync Status'
    );

    contactOld.Sync_Status__c = 'Blocked';
    contactNew.Sync_Status__c = null;
    Assert.isTrue(
      RetailBrokerContactActions.isSyncStatusEligibleForUpdate(
        contactNew,
        contactOld
      ),
      'Contact should be eligible for update Sync Status'
    );
  }*/

  /**
   * @description test method for publishBrokerRelationEvents
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testPublishBrokerRelationEvents() {
    retailContactMock.mock(
      'getContacts',
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() }
    );
    brokerRelationMock.mock(
      'queryBrokerRelationWithRbmDetails',
      RetailBrokerRelationEventActionsTest.mockBrokerSetMap()
    );
    retailContactMock.mock(
      'getBrokerSetContacts',
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() }
    );
    brokerRelationMock.mock(
      'queryRbmUsers',
      RetailBrokerRelationEventActionsTest.mockRbmUserMap()
    );
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerRelationEvent__c = false;
    brokerSettingsMock.mock('get', mockSettings);

    Contact oldContact = RetailBrokerRelationEventActionsTest.mockContact();
    oldContact.Broker_Set__c = null;

    List<SObject> publishedEvents = RetailBrokerContactActions.publishBrokerRelationEvents(
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() },
      new Map<Id, Contact>{ oldContact.Id => oldContact }
    );
    Assert.isFalse(publishedEvents.isEmpty(), 'Published events were returned');
  }

  /**
   * @description test method for getBrokerIdToEventTypeMap
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testGetBrokerIdToEventTypeMap() {
    Contact contactForAddEvent = RetailBrokerRelationEventActionsTest.mockContact();
    Set<Id> contactsForAddEvent = new Set<Id>{ contactForAddEvent.Id };

    Contact contactForDeleteEvent = RetailBrokerRelationEventActionsTest.mockContact();
    contactForDeleteEvent.Id = Lib_FakeIdGenerator.getMockId(
      Contact.SObjectType
    );
    Set<Id> contactsForDeleteEvent = new Set<Id>{ contactForDeleteEvent.Id };

    Map<Id, String> brokerIdToEventTypeMap = RetailBrokerContactActions.getBrokerIdToEventTypeMap(
      contactsForAddEvent,
      contactsForDeleteEvent
    );

    Assert.areEqual(
      'add',
      brokerIdToEventTypeMap.get(contactForAddEvent.Id),
      'This contact Id should be of add event'
    );
    Assert.areEqual(
      'delete',
      brokerIdToEventTypeMap.get(contactForDeleteEvent.Id),
      'This contact Id should be of delete event'
    );
  }

  /**
   * @description test method for isBrokerSetOrOffGroupChanged
   * @author  Saurabh Chauhan | Salesforce | 25-03-2025
   **/
  @isTest
  static void testIsBrokerSetOrOffGroupChanged() {
    userInfoMock.mock('checkCustomPermission', true);
    Contact oldContact = RetailBrokerRelationEventActionsTest.mockContact();
    oldContact.Broker_Set__c = null;
    Boolean brokerSetChanged = RetailBrokerContactActions.isBrokerSetOrOffGroupChanged(
      RetailBrokerRelationEventActionsTest.mockContact(),
      oldContact
    );

    Assert.isTrue(brokerSetChanged, 'Broker set of the contact is changed');
  }
  // Helper method to create test Contact records
  private static List<Contact> createTestContacts(Integer count) {
    List<Contact> contacts = new List<Contact>();

    Id brokerSetId = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    );
    Id brokerSetId2 = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    );

    for (Integer i = 0; i < count; i++) {
      Contact brokerContact = new Contact();
      brokerContact.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
      brokerContact.FirstName = 'TestFirst';
      brokerContact.RecordTypeId = RTContact.broker;
      brokerContact.LastName = 'TestLast';
      brokerContact.Broker_Set__c = (Math.mod(i, 2) == 0)
        ? brokerSetId
        : brokerSetId2; // Alternating broker sets
      brokerContact.Office_Group__c = Lib_FakeIdGenerator.getMockId(
        Broker_Relation__c.SObjectType
      ); // Some default value for Office_Group
      contacts.add(brokerContact);
    }

    return contacts;
  }

  @IsTest
  static void testBlankAggregatorOnBrokerSetChange() {
    // Prepare test data
    List<Contact> newContacts = createTestContacts(5); // 5 new contacts
    List<Contact> oldContacts = newContacts.deepClone(true); // Clone the contacts for oldMap

    // Modify some Broker_Set__c values to simulate a change
    oldContacts[0].Broker_Set__c = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    ); //  change Id

    // Create the oldMap from the cloned list
    Map<Id, Contact> oldMap = new Map<Id, Contact>(oldContacts);

    // Call the method under test
    Test.startTest();
    RetailBrokerContactActions.setBlankOfficeGroupOnChangeBrokerSet(
      newContacts,
      oldMap
    );
    Test.stopTest();

    Assert.isNull(
      newContacts[0].Office_Group__c,
      'Office_Group__c should be null for contact 1'
    );

    Assert.isNotNull(
      newContacts[3].Office_Group__c,
      'Office_Group__c should not be null for contact 3'
    );
  }
}
