/**
 * @author Zhiren Jason Guan
 * @since  21/02/2024
 * @description Test class for RetailBrokerContactActions
 */
@IsTest
private class RetailBrokerContactActionsTest {
  private static final Id RECORD_TYPE_ID_BROKER = RTContact.broker;

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
    contactOld = contactNew;
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
  }
}
