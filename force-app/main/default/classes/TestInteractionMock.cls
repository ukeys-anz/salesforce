/**
 * @author Kopal Goswami
 * @since 02/2024
 * @description Mock data to test the functionality of methods in the test classes
 */
@isTest
public with sharing class TestInteractionMock {
  /**
   * @description Mock data to test the functionality of methods
   * @return list of interactions for testing the method's functionality
   */
  public static List<Interaction> createMockInteraction() {
    Id callInteractionRecordId = GetHelpConstants.INTERACTION_GENERAL_RT_ID;
    Id chatInteractionRecordId = GetHelpConstants.INTERACTION_MESSAGE_RT_ID;
    String strInteraction =
      '[{"Id":"0kzBm0000001jmHIAQ","AccountId":"001Bm00000FY6jvIAD","RecordTypeId":"' +
      CallInteractionRecordId +
      '","Account":{"attributes":{"type":"Account","url":"/services/data/v60.0/sobjects/Account/001Bm00000FY6jvIAD"},"Id":"001Bm00000FY6jvIAD","PersonContactId":"003Bm00000GCPnqIAH"}},{"attributes":{"type":"Interaction","url":"/services/data/v60.0/sobjects/Interaction/0kzBm0000001l3JIAQ"},"Id":"0kzBm0000001l3JIAQ","AccountId":"001Bm00000FY6jvIAD","RecordTypeId":"' +
      CallInteractionRecordId +
      '","Account":{"attributes":{"type":"Account","url":"/services/data/v60.0/sobjects/Account/001Bm00000FY6jvIAD"},"Id":"001Bm00000FY6jvIAD","PersonContactId":"003Bm00000GCPnqIAH"}},{"attributes":{"type":"Interaction","url":"/services/data/v60.0/sobjects/Interaction/0kzBm0000001r77IAA"},"Id":"0kzBm0000001r77IAA","AccountId":"001Bm00000FY6jwIAD","RecordTypeId":"' +
      chatInteractionRecordId +
      '","Account":{"attributes":{"type":"Account","url":"/services/data/v60.0/sobjects/Account/001Bm00000FY6jwIAD"},"Id":"001Bm00000FY6jwIAD","PersonContactId":"003Bm00000GCPnrIAH"}}]';
    List<Interaction> interactionList = (List<Interaction>) JSON.deserialize(
      strInteraction,
      List<Interaction>.class
    );
    return interactionList;
  }

  /**
   * @description Mock Interaction with Attendee Record to test the functionality of methods
   * @return List of Interaction with Attendees for testing the method's functionality
   */
  public static List<Interaction> createMockInteractionWithAttendeeRecord() {
    String strInteractionWithAttendee = Service.getStaticResource(
      'mock_InteractionWithAttendee'
    );
    List<Interaction> interactionWithAttendeeRecord = (List<Interaction>) JSON.deserialize(
      strInteractionWithAttendee,
      List<Interaction>.class
    );
    return interactionWithAttendeeRecord;
  }
}
