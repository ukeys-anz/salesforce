/*
 * @author Shivraj Kadam
 * @since  09/2023
 * @description EventTriggerHandlerTest is the test class to cover tests for {@link EventTriggerHandler}
 */
@isTest
private class EventTriggerHandlerTest {
  static Id eventId = Lib_FakeIdGenerator.getMockId(
    Schema.Event.getSObjectType()
  );

  static Event getEvent(Id eventId) {
    return new Event(
      Id = eventId,
      StartDateTime = System.now(),
      EndDateTime = System.now() + 1,
      RecordTypeId = RTEvent.mlEvent,
      Description = 'A sample text with Passport12345678',
      Subject = 'A sample text with Passport12345678',
      Location = 'A sample text with Passport12345678'
    );
  }

  /**
   * @description test method for BeforeInsert in Handler
   */
  @isTest
  static void testBeforeInsert() {
    //Event record
    Event eve = getEvent(eventId);

    Test.startTest();
    EventTriggerHandler handler = new EventTriggerHandler();
    handler.records = new List<Event>{ eve };
    handler.onBeforeInsert();
    Test.stopTest();

    Assert.areEqual(
      'A sample text with Passport****5678',
      eve.Description,
      'Keyword entered in Description should be masked'
    );

    Assert.areEqual(
      'A sample text with Passport****5678',
      eve.Subject,
      'Keyword entered in Subject should be masked'
    );

    Assert.areEqual(
      'A sample text with Passport****5678',
      eve.Location,
      'Keyword entered in Location should be masked'
    );
  }

  /**
   * @description test method for BeforeUpdate in Handler
   */
  @isTest
  static void testBeforeUpdate() {
    //Event record
    Event eve = getEvent(eventId);
    eve.Description = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';
    eve.Subject = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';
    eve.Location = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';

    //setting oldmap
    Map<Id, Event> oldMap = new Map<Id, Event>{ eve.Id => eve };

    Test.startTest();
    EventTriggerHandler handler = new EventTriggerHandler();
    handler.records = new List<Event>{ eve };
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      eve.Description,
      'Keyword entered in Description should be masked'
    );

    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      eve.Subject,
      'Keyword entered in Subject should be masked'
    );

    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      eve.Location,
      'Keyword entered in Location should be masked'
    );
  }
}
