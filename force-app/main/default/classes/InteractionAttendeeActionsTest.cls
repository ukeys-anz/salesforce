/**
 * @author Rebecca Jan
 * @since 06/2022
 * @description test class for Interaction Attendee Actions
 */
@isTest
public with sharing class InteractionAttendeeActionsTest {
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
   * @description tests for getInteractionIdFromAttendee
   */
  @isTest
  static void testGetInteractionIdFromAttendee() {
    List<Interaction> interactionList = TestInteractionMock.createMockInteractionWithAttendeeRecord();
    List<InteractionAttendee> attendeeList = (List<InteractionAttendee>) interactionList[0]
      .Attendees;
    Test.startTest();
    Set<Id> interactionIds = InteractionAttendeeActions.getInteractionIdFromAttendee(
      attendeeList
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      interactionIds.size() > 0,
      'Interaction Ids will be added in the set of related Attendee'
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
      'Test Testing lead,Shivam Swaraj,Test Coach',
      interactionUpdatedList[0].Attendees__c,
      'Attendees__c On Interaction Updated With Desiserd Values'
    );
    Assert.areEqual(
      '{"005Bm000006ZzmlIAC":"Coach"}',
      interactionUpdatedList[0].Attendees_and_Roles__c,
      'Attendees_and_Roles__c On Interaction Updated With Desiserd Values'
    );
  }
}
