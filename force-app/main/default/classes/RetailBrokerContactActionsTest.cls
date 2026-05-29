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
  private static final Lib_MockProvider RETAIL_CONTACT_MERGE_REPOSITORY_MOCK = Lib_MockProvider.forType(
    RetailContactMergeRepository.class
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
  static Lib_MockProvider dmlRepoMock = Lib_MockProvider.forType(
    DMLRepository.class
  );
  private static final Id RECORD_TYPE_ID_BROKER = RTContact.broker;

  static Contact createTestContact() {
    Contact testContact = new Contact();
    testContact.FirstName = 'fNameContactTest001';
    testContact.LastName = 'lNameContactTest001';
    testContact.External_Id__c = 'exIdContactTest001';
    testContact.RecordTypeId = RECORD_TYPE_ID_BROKER;
    return testContact;
  }
  static Broker_Code__c createBrokerCode() {
    Broker_Code__c brokCode = new Broker_Code__c();
    return brokCode;
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

    Contact contactNew = createTestContact();
    contactNew.Id = contactOld.Id;
    contactNew.OCV_Event_Version__c = 1;
    contactNew.Sync_Status__c = RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG;
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
      'anzx.salesforce.broker.v1alpha1.brokerdata.add',
      (String) cloudEventmap.get('ce_type'),
      'Event generated should be of type - add'
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
      'Broker Org',
      results[0].Sync_Status__c,
      'The sync status should be set to Broker Org'
    );
  }

  @IsTest
  static void testIsEligibleWhenCommercialAndAssetTpmiNotBlank() {
    Contact contactNew = createTestContact();
    Contact contactOld = createTestContact();
    contactNew.CommercialTPMISAO__c = 'CommTMPITest001';
    contactNew.AssetFinanceTPMISAO__c = 'AssetFinanceTPMISAOTest001';

    Boolean result;
    Test.startTest();
    result = RetailBrokerContactActions.isRecordAnEligibleBrokerContact(
      contactNew,
      contactOld
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      result,
      'Contact should be eligible when Commercial or Asset Finance TPMI SAO is populated'
    );
  }

  @IsTest
  static void testIsEligibleWhenRetailTpmiNotBlankAndIsBetaBroker() {
    Contact contactNew = createTestContact();
    Contact contactOld = createTestContact();
    contactNew.RetailTPMISAO__c = 'RetailTPMISAOTest001';
    Boolean result;

    Test.startTest();
    result = RetailBrokerContactActions.isRecordAnEligibleBrokerContact(
      contactNew,
      contactOld
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      result,
      'Contact should be eligible when Retail TPMI SAO is populated and is a beta broker is true'
    );
  }

  @IsTest
  static void testIsEligibleWhenIsBetaBroker() {
    Contact contactNew = createTestContact();
    Contact contactOld = createTestContact();
    contactOld.RetailTPMISAO__c = 'RetailTPMISAOTest001';
    contactNew.RetailTPMISAO__c = 'RetailTPMISAOTest001';
    Boolean result;

    Test.startTest();
    result = RetailBrokerContactActions.isRecordAnEligibleBrokerContact(
      contactNew,
      contactOld
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      result,
      'Contact should be eligible when Retail TPMI SAO is unchanged but contact is a beta broker is true'
    );
  }

  @IsTest
  static void testIsEligibleWhenAllFieldsBlankOrUnchanged() {
    Contact contactNew = createTestContact();
    Contact contactOld = createTestContact();
    contactOld.RetailTPMISAO__c = 'RetailTPMISAOTest001';
    contactNew.RetailTPMISAO__c = 'RetailTPMISAOTest001';
    Boolean result;

    Test.startTest();
    result = RetailBrokerContactActions.isRecordAnEligibleBrokerContact(
      contactNew,
      contactOld
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      result,
      'Contact should be eligible when all values are blank or unchanged'
    );
  }

  @IsTest
  static void testIsEligibleWhenIsBetaBrokerFalse() {
    Contact contactNew = createTestContact();
    Contact contactOld = createTestContact();

    contactOld.RetailTPMISAO__c = 'oldRetail';
    contactNew.RetailTPMISAO__c = 'newRetail';
    Boolean result;

    Test.startTest();
    result = RetailBrokerContactActions.isRecordAnEligibleBrokerContact(
      contactNew,
      contactOld
    );
    Test.stopTest();

    Assert.isTrue(
      result,
      'Contact should not be eligible if RetailTPMISAO__c changed.'
    );
  }

  @IsTest
  static void testIsNotEligibleWhenRetailTpmiBlankAndIsBetaBroker() {
    Contact contactNew = createTestContact();
    Contact contactOld = createTestContact();
    contactNew.RetailTPMISAO__c = '';
    contactOld.RetailTPMISAO__c = '';
    Boolean result;
    Test.startTest();
    result = RetailBrokerContactActions.isRecordAnEligibleBrokerContact(
      contactNew,
      contactOld
    );
    Test.stopTest();

    Assert.isFalse(
      result,
      'Contact should not be eligible when Retail TPMI SAO is blank.'
    );
  }

  @IsTest
  static void testGetAction() {
    Contact contactOld = createTestContact();
    contactOld.OCV_Event_Version__c = 0;
    Contact contactNew = createTestContact();
    contactNew.OCV_Event_Version__c = 0;
    Assert.areEqual(
      '',
      RetailBrokerContactActions.getAction(contactNew),
      'Action type should be blank, neither add nor update'
    );
    contactNew.OCV_Event_Version__c = 1;
    contactNew.Sync_Status__c = RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG;
    Assert.areEqual(
      'add',
      RetailBrokerContactActions.getAction(contactNew),
      'Action type should be blank, neither add nor update'
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
    Assert.areEqual(
      false,
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

    Assert.areEqual(
      true,
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
    List<Contact> newContacts = createTestContacts(5);
    List<Contact> oldContacts = newContacts.deepClone(true);

    oldContacts[0].Broker_Set__c = Lib_FakeIdGenerator.getMockId(
      Broker_Relation__c.SObjectType
    );

    Map<Id, Contact> oldMap = new Map<Id, Contact>(oldContacts);
    USER_INFO_REPOSITORY_MOCK.mock('checkProfile', false);

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

  @IsTest
  static void testContactMergeEvent() {
    List<Contact> newContacts = createTestContacts(2);

    newContacts[0]
      .Sync_Status__c = RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG;
    newContacts[0].External_Id__c = 'exIdContactTest001';
    newContacts[1].External_Id__c = 'exIdContactTest002';
    newContacts[1]
      .Sync_Status__c = RetailBrokerContactActions.SYNC_STATUS_BLOCKED;
    List<Contact> oldContacts = newContacts.deepClone(true);
    newContacts[0].Survivor_Party_Id__c = newContacts[1].External_Id__c;
    newContacts[0].Victim_Party_Id__c = newContacts[0].External_Id__c;
    Broker_Code__c brokerCode = createBrokerCode();
    brokerCode.Broker_Name__c = newContacts[0].Id;
    RETAIL_CONTACT_MERGE_REPOSITORY_MOCK.mock(
      'getRelatedBrokerCodes',
      new List<Broker_Code__c>{ brokerCode }
    );
    RETAIL_CONTACT_MERGE_REPOSITORY_MOCK.mock(
      'queryContactRecordsByExternalIds',
      new List<Contact>{ newContacts[1] }
    );
    RETAIL_CONTACT_MERGE_REPOSITORY_MOCK.mock(
      'getDuplicateContacts',
      new List<Contact>{ newContacts[1] }
    );
    RETAIL_CONTACT_MERGE_REPOSITORY_MOCK.mock(
      'getContactsByIds',
      new List<Contact>{ newContacts[1] }
    );

    Test.startTest();
    RetailBrokerContactActions.contactMergeEvent(
      newContacts,
      new Map<Id, Contact>(newContacts),
      new Map<Id, Contact>(oldContacts)
    );
    Test.stopTest();
    List<Broker_Code__c> deletebrokerCode = (List<Broker_Code__c>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');

    Assert.areEqual(
      1,
      deletebrokerCode.size(),
      'Must have one Broker code to delete'
    );
  }

  @IsTest
  static void testUpdateAssistedBrokerLookup() {
    List<Contact> newContacts = createTestContacts(1);
    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.Assisted_Broker_TPMI_SAO__c = 'Retail-Active';

    FinServ__FinancialAccount__c finServAcc = new FinServ__FinancialAccount__c();
    finServAcc.Assisted_Broker_TPMI_SAO__c = 'Retail-Active';

    List<Contact> oldContacts = newContacts.deepClone(true);
    oldContacts[0].RetailTPMISAO__c = 'Retail-Active-Old';
    oldContacts[0].Broker_Accreditation_Type__c = 'Commerical';
    oldContacts[0].External_Id__c = 'Ex-sur1234';

    newContacts[0]
      .Sync_status__c = RetailBrokerContactActions.SYNC_STATUS_BROKER_ORG;
    newContacts[0].RetailTPMISAO__c = 'Retail-Active';
    newContacts[0].Broker_Accreditation_Type__c = 'Retail;Commerical';
    newContacts[0].Survivor_Party_Id__c = 'Ex-sur1234';
    newContacts[0].External_Id__c = 'Ex-sur1234';

    Test.startTest();
    List<Contact> updateContacts = RetailBrokerContactActions.updateAssistedBrokerLookup(
      new Map<Id, Contact>{ newContacts[0].Id => newContacts[0] },
      new Map<Id, Contact>(oldContacts)
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      updateContacts.size(),
      'Must have one Contacts to Update'
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
