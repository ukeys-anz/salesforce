/**
 * @author Rebecca Jan
 * @since 06/2022
 * @description test class for Interaction Attendee Actions
 */
@isTest
public with sharing class InteractionAttendeeActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider interactionRepoMock;
  static Lib_MockProvider userRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    interactionRepoMock = Lib_MockProvider.forType(InteractionRepository.class);
    userRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }

  /**
   * @description tests for createInteractionAndAttendeeRoleMapInternal
   */
  @isTest
  static void testCreateInteractionAndAttendeeRoleMap() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    List<InteractionAttendee> attendeeList = (List<InteractionAttendee>) interactionList[0]
      .Attendees;
    Test.startTest();
    Map<Id, String> createInteractionAndAttendeeRoleMap = InteractionAttendeeActions.createInteractionAndAttendeeRoleMap(
      attendeeList
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      createInteractionAndAttendeeRoleMap.size() == 1,
      'Internal Attendee Type Added in the Map'
    );
  }
  /**
   * @description tests for createInteractionAttendeeMap
   */
  @isTest
  static void testCreateInteractionAttendeeMap() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    List<InteractionAttendee> attendeeList = (List<InteractionAttendee>) interactionList[0]
      .Attendees;
    Test.startTest();
    Map<Id, Set<String>> createInteractionAttendeeMap = InteractionAttendeeActions.createInteractionAttendeeMap(
      attendeeList
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      new Set<String>(createInteractionAttendeeMap.get('0kzBm0000001jcbIAA'))
        .contains('Shivam Swaraj'),
      'External Attendee Type Added in the Map'
    );
  }
  /**
   * @description tests for getInteractionAttendeeFromInteraction
   */
  @isTest
  static void testGetInteractionAttendeeFromInteraction() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    Map<Id, Interaction> interactionMap = new Map<Id, Interaction>{
      interactionList.get(0).Id => interactionList.get(0)
    };

    Test.startTest();
    List<InteractionAttendee> interactionAttendeeList = InteractionAttendeeActions.getInteractionAttendeeFromInteraction(
      interactionMap
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      interactionAttendeeList.size() > 0,
      'Interaction Attendess List should be available with size greater than 0'
    );
  }
  /**
   * @description tests for UpdateAttendeeAndRoleOnInteraction
   */
  @isTest
  static void testUpdateAttendeeAndRoleOnInteraction() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    Map<Id, Interaction> interactionMap = new Map<Id, Interaction>{
      interactionList.get(0).Id => interactionList.get(0)
    };
    List<InteractionAttendee> interactionAttendeeList = InteractionAttendeeActions.getInteractionAttendeeFromInteraction(
      interactionMap
    );
    Map<Id, Set<String>> createInteractionAttendeeMap = InteractionAttendeeActions.createInteractionAttendeeMap(
      interactionAttendeeList
    );
    Map<Id, String> createInteractionAndAttendeeRoleMap = InteractionAttendeeActions.createInteractionAndAttendeeRoleMap(
      interactionAttendeeList
    );

    Test.startTest();
    List<Interaction> interactionUpdatedList = InteractionAttendeeActions.updateAttendeeAndRoleOnInteraction(
      interactionMap,
      createInteractionAttendeeMap,
      createInteractionAndAttendeeRoleMap
    );
    Test.stopTest();
    Assert.areEqual(
      'Test Testing lead,Shivam Swaraj,Test Virtual Agent,Test Broker,Test Coach',
      interactionUpdatedList[0].Attendees__c,
      'Attendees__c On Interaction Updated With Desiserd Values'
    );
    Assert.areEqual(
      '{"005Bm000006ZzmlIAC":"Coach"}',
      interactionUpdatedList[0].Attendees_and_Roles__c,
      'Attendees_and_Roles__c On Interaction Updated With Desiserd Values'
    );
  }
  /**
   * @description tests for validateAttendees
   */
  @isTest
  static void testValidateAttendees() {
    registerMocks();
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    List<InteractionAttendee> attendeeList = (List<InteractionAttendee>) interactionList[0]
      .Attendees;
    interactionList[0].RecordTypeId = RTInteraction.rbmBrokerInteraction;
    interactionRepoMock.mock(
      'queryInteractionAndRelatedAttendees',
      new List<Interaction>{ interactionList[0] }
    );

    Test.startTest();
    InteractionAttendeeActions.validateAttendees(attendeeList);
    Test.stopTest();
    Assert.isTrue(
      attendeeList[4]
        .UniqueKeyForInteractionAttendee__c
        .contains('0kzBm0000001jcbIAA_005Bm000006ZzmlIAC'),
      'UniqueKeyForInteractionAttendee__c is not correct'
    );
    Assert.isTrue(
      attendeeList[0]
        .UniqueKeyForInteractionAttendee__c
        .contains('0kzBm0000001jcbIAA_003Bm00000GFef4IAD'),
      'UniqueKeyForInteractionAttendee__c is not correct'
    );
    Assert.isTrue(
      attendeeList[3]
        .UniqueKeyForInteractionAttendee__c
        .contains('0kzBm0000001jcbIAA_003Bm00000GFef4IAK'),
      'UniqueKeyForInteractionAttendee__c is not correct'
    );
  }
  /*
   * @description tests for updateAttendees
   */
  @isTest
  static void testUpdateAttendees() {
    registerMocks();
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    List<InteractionAttendee> attendeeList = (List<InteractionAttendee>) interactionList[0]
      .Attendees;

    interactionRepoMock.mock(
      'queryInteractionAndRelatedAttendees',
      new List<Interaction>{ interactionList[0] }
    );
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
    Test.startTest();
    InteractionAttendeeActions.updateAttendees(
      attendeeList,
      new Map<Id, InteractionAttendee>(attendeeList)
    );
    Test.stopTest();
    List<Interaction> updatedInteractionList = (List<Interaction>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.isTrue(
      updatedInteractionList.size() > 0,
      'Interactions should have been updated'
    );
  }
  /*
   * @description tests for insertOwnerChangeAttendee
   */
  @isTest
  static void testInsertOwnerChangeAttendee() {
    registerMocks();
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    List<InteractionAttendee> attendeeList = (List<InteractionAttendee>) interactionList[0]
      .Attendees;
    interactionList[0].RecordTypeId = RTInteraction.message;
    interactionList[0].OwnerId = UserInfo.getUserId();
    interactionRepoMock.mock('queryInteractionAttendees', attendeeList);
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
    Test.startTest();
    InteractionAttendeeActions.insertOwnerChangeAttendee(interactionList);
    Test.stopTest();
    List<InteractionAttendee> insertedInteractionAttendeeList = (List<InteractionAttendee>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.isTrue(
      insertedInteractionAttendeeList.size() > 0,
      'Interactions should have been inserted'
    );
  }

  /*
   * @description tests for insertCustomerTypeInteractionAttendee
   */
  @isTest
  static void testInsertCustomerTypeInteractionAttendee() {
    registerMocks();
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    interactionList[0].RecordTypeId = RTInteraction.call;
    interactionList[0].AccountId = Lib_FakeIdGenerator.getMockId(
      Account.getSObjectType()
    );
    interactionRepoMock.mock('queryInteractions', interactionList);
    map<Id, Interaction> oldmap = new Map<id, interaction>(interactionList);
    oldmap.remove(interactionList[0].Id);
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
    Test.startTest();
    InteractionAttendeeActions.insertCustomerTypeInteractionAttendee(
      interactionList,
      oldmap
    );
    Test.stopTest();
    List<InteractionAttendee> insertedInteractionAttendeeList = (List<InteractionAttendee>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.isTrue(
      insertedInteractionAttendeeList.size() > 0,
      'Interactions should have been inserted'
    );
  }
  /*
   * @description tests for insertDefaultAttendee
   */
  @isTest
  static void testInsertDefaultAttendee() {
    registerMocks();
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    interactionList[0].RecordTypeId = RTInteraction.call;
    User testUser = TestUtil.createTestUserWithProfile('ANZx Standard User');

    userRepoMock.mock('checkProfile', true);
    userRepoMock.mock('getUser', testUser);

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
    Test.startTest();
    InteractionAttendeeActions.insertDefaultAttendee(interactionList);
    Test.stopTest();
    List<InteractionAttendee> insertedInteractionAttendeeList = (List<InteractionAttendee>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.isTrue(
      insertedInteractionAttendeeList.size() > 0,
      'Interactions should have been inserted'
    );
  }
}
