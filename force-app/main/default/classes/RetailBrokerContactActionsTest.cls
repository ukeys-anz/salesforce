/**
 * @author Zhiren Jason Guan
 * @since  21/02/2024
 * @description Test class for RetailBrokerContactActions
 */

@IsTest
private class RetailBrokerContactActionsTest {
  private static final Lib_MockProvider BROKER_RELATION_REPOSITORY_MOCK = Lib_MockProvider.forType(
    BrokerRelationRepository.class
  );
  private static final Lib_MockProvider RETAIL_CONTACT_REPOSITORY_MOCK = Lib_MockProvider.forType(
    RetailContactRepository.class
  );
  private static final Lib_MockProvider BROKER_SETTINGS_REPOSITORY_MOCK = Lib_MockProvider.forType(
    BrokerSettingsRepository.class
  );
  private static final Lib_MockProvider USER_INFO_REPOSITORY_MOCK = Lib_MockProvider.forType(
    UserInfoRepository.class
  );
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
    USER_INFO_REPOSITORY_MOCK.mock('checkCustomPermission', true);
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerEvent__c = false;
    BROKER_SETTINGS_REPOSITORY_MOCK.mock('get', mockSettings);

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

  /**
   * @description test method for publishBrokerRelationEvents
   * @author  Saurabh Chauhan | Salesforce | 06-03-2025
   **/
  @isTest
  static void testPublishBrokerRelationEvents() {
    RETAIL_CONTACT_REPOSITORY_MOCK.mock(
      'getContacts',
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() }
    );
    BROKER_RELATION_REPOSITORY_MOCK.mock(
      'queryBrokerRelationWithRbmDetails',
      mockBrokerList()
    );
    RETAIL_CONTACT_REPOSITORY_MOCK.mock(
      'getBrokerSetContacts',
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() }
    );
    BROKER_RELATION_REPOSITORY_MOCK.mock('queryRbmUsers', mockRbmUserList());
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassBrokerRelationEvent__c = false;
    BROKER_SETTINGS_REPOSITORY_MOCK.mock('get', mockSettings);

    Contact oldContact = RetailBrokerRelationEventActionsTest.mockContact();
    oldContact.Broker_Set__c = null;

    List<SObject> publishedEvents = RetailBrokerContactActions.publishBrokerRelationEvents(
      new List<Contact>{ RetailBrokerRelationEventActionsTest.mockContact() },
      new Map<Id, Contact>{ oldContact.Id => oldContact }
    );
    Assert.isFalse(
      publishedEvents.isEmpty(),
      'No published events were returned'
    );
  }

  /**
   * @description test method for isBrokerSetOrOffGroupChanged
   * @author  Saurabh Chauhan | Salesforce | 25-03-2025
   **/
  @isTest
  static void testIsBrokerSetOrOffGroupChanged() {
    USER_INFO_REPOSITORY_MOCK.mock('checkCustomPermission', true);
    Contact oldContact = RetailBrokerRelationEventActionsTest.mockContact();
    oldContact.Broker_Set__c = null;
    Boolean brokerSetChanged = RetailBrokerContactActions.isBrokerSetOrOffGroupChanged(
      RetailBrokerRelationEventActionsTest.mockContact(),
      oldContact
    );

    Assert.isTrue(
      brokerSetChanged,
      'Broker set of the contact should have changed'
    );
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
      'Office_Group__c should not be null for contact 4'
    );
  }

  /**
   * @description to create mock Broker Relation List
   * @author  Atharv Jakate | Salesforce | 23-06-2025
   * @return List<Broker_Relation__c>
   **/
  private static List<Broker_Relation__c> mockBrokerList() {
    Broker_Relation__c newBrokerSet = (Broker_Relation__c) JSON.deserialize(
      '{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000ZI5JYAW"},"Id":"a2oAD000000ZI5JYAW","Primary_RBM__c":"005Oa000005OyubIAC","Secondary_RBM__c":"005Oa000003fFuDIAU","RecordTypeId":"012AD000001tpEDYAY","Primary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000005OyubIAC"},"Id":"005Oa000005OyubIAC","Lan_Id__c":"manish5"},"Secondary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Lan_Id__c":"sauDevtest"}}',
      Broker_Relation__c.class
    );

    Broker_Relation__c oldBrokerSet = (Broker_Relation__c) JSON.deserialize(
      '{"attributes":{"type":"Broker_Relation__c","url":"/services/data/v63.0/sobjects/Broker_Relation__c/a2oAD000000ZUuTYAW"},"Id":"a2oAD000000ZUuTYAW","Primary_RBM__c":"005Oa000003fFuDIAU","Secondary_RBM__c":"005Oa000003wiQMIAY","RecordTypeId":"012AD000001tpEDYAY","Primary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Lan_Id__c":"sauDevtest"},"Secondary_RBM__r":{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003wiQMIAY"},"Id":"005Oa000003wiQMIAY","Lan_Id__c":"utkarsh9"}}',
      Broker_Relation__c.class
    );

    return new List<Broker_Relation__c>{ oldBrokerSet, newBrokerSet };
  }

  /**
   * @description to create mock rbm users
   * @author  Atharv Jakate | Salesforce | 23-06-2025
   * @return List<User>
   **/
  private static List<User> mockRbmUserList() {
    List<User> userList = (List<User>) JSON.deserialize(
      '[{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003fFuDIAU"},"Id":"005Oa000003fFuDIAU","Name":"Saurabh Chauhan","Lan_Id__c":"sauDevtest"},{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/0055m000000XnEPAA0"},"Id":"0055m000000XnEPAA0","Name":"Jasmine Nguyen","Lan_Id__c":"jasTest"},{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000005OyubIAC"},"Id":"005Oa000005OyubIAC","Name":"Manish Bisht","Lan_Id__c":"manish5"},{"attributes":{"type":"User","url":"/services/data/v63.0/sobjects/User/005Oa000003wiQMIAY"},"Id":"005Oa000003wiQMIAY","Name":"Utkarsh Singh","Lan_Id__c":"utkarsh9"}]',
      List<User>.class
    );

    return userList;
  }
}
