/**
 * @description       : Apex Test class for RBMInteractionActions
 * @author            : Smruti Khobragade | Salesforce
 * @last modified on  : 01-30-2025
 * @last modified by  : Smruti Khobragade | Salesforce
 **/
@isTest
private class RBMInteractionActionsTest {
  static Lib_MockProvider interactionRepoMock = Lib_MockProvider.forType(
    RBMInteractionRepository.class
  );
  static Lib_MockProvider associatedLoanApplicationRepoMock = Lib_MockProvider.forType(
    AssociatedLoanApplicationRepository.class
  );
  static Lib_MockProvider dmlRepoMock = Lib_MockProvider.forType(
    DMLRepository.class
  );
  /*
   * @description unit test to CreateInteractionNotes
   */
  @isTest
  static void testCreateInteractionNotes() {
    List<Interaction> mockInteractions = createMockInteraction(1);
    Test.startTest();
    RBMInteractionActions.createInteractionNotes(mockInteractions);
    Test.stopTest();
    List<ContentNote> contentNotes = (List<ContentNote>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      contentNotes[0].Title,
      'Closed - Completed Note',
      'ContentNote title must match'
    );
  }
  /*
   * @description unit test to CreateInteractionAttende
   */
  @isTest
  static void testCreateInteractionAttende() {
    List<Interaction> mockInteractions = createMockInteraction(1);
    Contact brokerContact = new Contact(
      Office_Group__c = mockInteractions[0].Office_Group__c,
      Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType)
    );
    interactionRepoMock.mock(
      'queryBrokersFromOfficeGroups',
      new List<Contact>{ brokerContact }
    );
    Test.startTest();
    RBMInteractionAttendeeActions.createInteractionAttendee(mockInteractions);
    Test.stopTest();
    List<InteractionAttendee> interactionAttendees = (List<InteractionAttendee>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      interactionAttendees.size(),
      2,
      'Expected two InteractionAttendees to be created for the given mock Interaction'
    );
  }
  /*
   * @description unit test to CreateAssociatedLoanApplication
   */
  @isTest
  static void testCreateAssociatedLoanApplication() {
    List<Interaction> mockInteractions = createMockInteraction(1);
    Test.startTest();
    RBMInteractionApplicationActions.createAssociatedLoanApplication(
      mockInteractions
    );
    Test.stopTest();
    List<Associated_Loan_Application__c> associatedLoans = (List<Associated_Loan_Application__c>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      associatedLoans[0].Interaction__c,
      mockInteractions[0].Id,
      'Associated Loan Application must map with mock Interaction'
    );
    Assert.areEqual(
      associatedLoans[0].Residential_Loan_Application__c,
      mockInteractions[0].Loan_Application__c,
      'Associated Loan Application must map with same mock interaction loan'
    );
  }
  /*
   * @description unit test to UpdateAssociatedLoanApplication
   */
  @isTest
  static void testUpdateAssociatedLoanApplication() {
    List<Interaction> mockInteractions = createMockInteraction(2);
    List<Interaction> secondInteraction = createMockInteraction(2);
    List<Interaction> thirdInteraction = createMockInteraction(2);
    thirdInteraction[0].Loan_Application__c = null;
    secondInteraction[1].Loan_Application__c = null;
    mockInteractions[1].Loan_Application__c = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    Map<Id, Interaction> oldRecord = new Map<Id, Interaction>{
      mockInteractions[1].id => mockInteractions[1],
      secondInteraction[1].Id => secondInteraction[1],
      thirdInteraction[1].Id => thirdInteraction[1]
    };
    Associated_Loan_Application__c associatedLoanApplication = new Associated_Loan_Application__c();
    associatedLoanApplication.Residential_Loan_Application__c = mockInteractions[1]
      .Loan_Application__c;
    associatedLoanApplication.Interaction__c = mockInteractions[1].Id;
    associatedLoanApplication.Id = Lib_FakeIdGenerator.getMockId(
      Associated_Loan_Application__c.SObjectType
    );
    Associated_Loan_Application__c oldAssociatedLoanApplication = new Associated_Loan_Application__c();
    oldAssociatedLoanApplication.Residential_Loan_Application__c = thirdInteraction[1]
      .Loan_Application__c;
    oldAssociatedLoanApplication.Interaction__c = thirdInteraction[0].Id;
    oldAssociatedLoanApplication.Id = Lib_FakeIdGenerator.getMockId(
      Associated_Loan_Application__c.SObjectType
    );
    associatedLoanApplicationRepoMock.mock(
      'getRelatedLoanApplication',
      new List<Associated_Loan_Application__c>{ associatedLoanApplication }
    );
    Test.startTest();
    RBMInteractionApplicationActions.updateAssociatedLoanApplication(
      new List<Interaction>{
        mockInteractions[0],
        secondInteraction[0],
        thirdInteraction[0]
      },
      oldRecord
    );
    Test.stopTest();
    List<Associated_Loan_Application__c> newassociatedLoans = (List<Associated_Loan_Application__c>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    List<Associated_Loan_Application__c> deleteAssociatedLoans = (List<Associated_Loan_Application__c>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      newassociatedLoans.size(),
      2,
      'Must have two new Associated Loan Application for creation'
    );
    Assert.areEqual(
      deleteAssociatedLoans.size(),
      1,
      'Must have one Associated Loan Applications to delete'
    );
  }
  /*
   * @description unit test to CreateInteractionEvents
   */
  @isTest
  static void testCreateInteractionEvents() {
    List<Interaction> mockInteractions = createMockInteraction(1);
    Test.startTest();
    RBMInteractionActions.createInteractionEvents(mockInteractions);
    Test.stopTest();
    List<Event> events = (List<Event>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');
    Assert.areEqual(events.size(), 1, 'Must have one event only');
    Assert.areEqual(events[0].IsReminderSet, true, 'Event Reminder must set');
  }
  /*
   * @description unit test to AfterInsertInteractionClosingNotes
   */
  @isTest
  static void testAfterInsertInteractionClosingNotes() {
    List<Interaction> mockInteractions = createMockInteraction(1);
    mockInteractions[0]
      .Status__c = BrokerConstants.INTERACTION_STATUS_CLOSED_COMPLETED;
    Test.startTest();
    RBMInteractionActions.createInteractionClosingNotes(mockInteractions);
    Test.stopTest();
    List<ContentNote> contentNotes = (List<ContentNote>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      contentNotes[0].Title,
      'Closed - Completed Note',
      'ContentNote title must match'
    );
  }
  /*
   * @description unit test to AfterUpdateInteractionClosingNotes
   */
  @isTest
  static void testAfterUpdateInteractionClosingNotes() {
    List<Interaction> mockInteractions = createMockInteraction(2);
    mockInteractions[1].Status__c = 'Open';
    Map<Id, Interaction> oldRecord = new Map<Id, Interaction>{
      mockInteractions[1].id => mockInteractions[1]
    };
    Test.startTest();
    RBMInteractionActions.createInteractionClosingNotes(
      new List<Interaction>{ mockInteractions[0] },
      oldRecord
    );
    Test.stopTest();
    List<ContentNote> contentNotes = (List<ContentNote>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      contentNotes[0].Title,
      'Closed - Completed Note',
      'ContentNote title must match'
    );
  }
  /*
   * @description unit test to UpdateInteractionName
   */
  @isTest
  static void testUpdateInteractionName() {
    List<Interaction> mockInteractions = createMockInteraction(2);
    mockInteractions[1].Status__c = 'Open';
    Map<Id, Interaction> oldRecord = new Map<Id, Interaction>{
      mockInteractions[1].id => mockInteractions[1]
    };
    Broker_Relation__c officeGroup = new Broker_Relation__c();
    officeGroup.Id = mockInteractions[0].Office_Group__c;
    officeGroup.Name = 'Test OfficeGroup';
    Contact brokerContact = (Contact) JSON.deserialize(
      '{"Id":"' +
        mockInteractions[0].Broker__c +
        '","Name":"Sample Broker Contact"}',
      Contact.class
    );
    interactionRepoMock.mock(
      'queryBrokerContacts',
      new List<Contact>{ brokerContact }
    );
    interactionRepoMock.mock(
      'queryOfficeGroups',
      new List<Broker_Relation__c>{ officeGroup }
    );
    Test.startTest();
    RBMInteractionActions.updateInteractionName(
      oldRecord,
      new List<Interaction>{ mockInteractions[0] }
    );
    Test.stopTest();
    Assert.areNotEqual(
      mockInteractions[0].Name,
      mockInteractions[1].Name,
      'Interaction Name must change'
    );
    String relatedName =
      brokerContact.Name +
      ' - ' +
      mockInteractions[0].Interaction_Type__c;
    Assert.areNotEqual(
      mockInteractions[0].Name,
      relatedName,
      'Expected Interaction Name Change must be ' + relatedName
    );
  }
  /*
   * @description unit test to check clear closing notes
   */
  @isTest
  static void testClearClosingNotes() {
    List<Interaction> mockInteractions = createMockInteraction(2);
    mockInteractions[0].Status__c = 'Open';

    Map<Id, Interaction> oldRecord = new Map<Id, Interaction>{
      mockInteractions[1].id => mockInteractions[1]
    };

    Broker_Relation__c officeGroup = new Broker_Relation__c();
    officeGroup.Id = mockInteractions[0].Office_Group__c;
    officeGroup.Name = 'Test OfficeGroup';

    Contact brokerContact = (Contact) JSON.deserialize(
      '{"Id":"' +
        mockInteractions[1].Broker__c +
        '","Name":"Sample Broker Contact"}',
      Contact.class
    );
    interactionRepoMock.mock(
      'queryBrokerContacts',
      new List<Contact>{ brokerContact }
    );
    interactionRepoMock.mock(
      'queryOfficeGroups',
      new List<Broker_Relation__c>{ officeGroup }
    );
    Test.startTest();
    RBMInteractionActions.clearClosingNotes(
      new List<Interaction>{ mockInteractions[0] },
      oldRecord
    );
    Test.stopTest();
    Assert.areNotEqual(
      mockInteractions[0].Closing_Notes__c,
      'Test Closing Note',
      'Interaction Closing Note should have initial value'
    );
    Assert.areEqual(
      mockInteractions[0].Closing_Notes__c,
      '',
      'Interaction Closing Note must be cleared'
    );
  }
  /*
   * @description unit test for after update Interactions to upsert Interaction Events
   */
  @isTest
  static void testUpsertInteractionEvents() {
    List<Interaction> mockInteractions = createMockInteraction(2);
    mockInteractions[0].StartTime = DateTime.newInstance(
      DateTime.now().year() + 1,
      2,
      1
    );
    mockInteractions[0].Status__c = 'Open';
    Map<Id, Interaction> oldRecord = new Map<Id, Interaction>{
      mockInteractions[1].id => mockInteractions[1]
    };
    Event mockEvent = new Event();
    mockEvent.Id = Lib_FakeIdGenerator.getMockId(Event.SObjectType);
    mockEvent.StartDateTime = mockInteractions[1].StartTime;
    mockEvent.WhatId = mockInteractions[1].Id;
    interactionRepoMock.mock(
      'getEvents',
      new Map<Id, Event>{ mockEvent.Id => mockEvent }
    );
    Test.startTest();
    RBMInteractionActions.upsertInteractionEvents(
      new List<Interaction>{ mockInteractions[0] },
      oldRecord
    );
    Test.stopTest();
    List<Event> upsertedEvents = (List<Event>) dmlRepoMock.getHistory(
        'doUpsert'
      )
      .getParam('records');
    Assert.areNotEqual(
      upsertedEvents[0].StartDateTime,
      mockInteractions[1].StartTime,
      'Interaction old start time must not same in event StartDateTime'
    );
  }
  /*
   * @description unit test to validAndSetStartTime
   */
  @isTest
  static void testValidAndSetStartTime() {
    List<Interaction> mockInteractions = createMockInteraction(1);
    mockInteractions[0].StartTime = null;
    Test.startTest();
    RBMInteractionActions.validAndSetStartTime(mockInteractions);
    Test.stopTest();
    Assert.areNotEqual(
      mockInteractions[0].StartTime,
      null,
      'Interaction old start time must not same in event StartDateTime'
    );
  }
  /**
   * @description createMockInteraction
   * @param reqRecords Integer value for limit the number of mock records to create
   * @return List<Interaction>
   */
  private static List<Interaction> createMockInteraction(Integer reqRecords) {
    List<Interaction> interactions = new List<Interaction>();
    for (Integer i = 0; i < reqRecords; i++) {
      Boolean isOldRecord = (i > 0) ? true : false;
      Interaction mockInteraction = new Interaction();
      mockInteraction.Id = isOldRecord
        ? interactions[0].Id
        : Lib_FakeIdGenerator.getMockId(Interaction.SObjectType);
      mockInteraction.RecordTypeId = RTInteraction.rbmBrokerInteraction;
      mockInteraction.Name = isOldRecord
        ? 'Test Interaction Old'
        : 'Test Interaction';
      mockInteraction.Broker__c = Lib_FakeIdGenerator.getMockId(
        Contact.SObjectType
      );
      mockInteraction.StartTime = DateTime.newInstance(
        DateTime.now().year() + 1,
        1,
        1
      );
      mockInteraction.Interaction_Purpose__c = InteractionConstants.OTHER_PURPOSE_NAME;
      mockInteraction.Status__c = BrokerConstants.INTERACTION_STATUS_CLOSED_COMPLETED; //'Open';
      mockInteraction.Interaction_Type__c = isOldRecord
        ? 'Online/Virtual'
        : 'Phone';
      mockInteraction.Optional_Notes__c = 'Open';
      mockInteraction.Attendee_Category__c = 'Office Group';
      mockInteraction.Closing_Notes__c = 'Test Closing Note';
      mockInteraction.Office_Group__c = Lib_FakeIdGenerator.getMockId(
        Broker_Relation__c.SObjectType
      );
      mockInteraction.Loan_Application__c = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      interactions.add(mockInteraction);
    }
    return interactions;
  }
}
