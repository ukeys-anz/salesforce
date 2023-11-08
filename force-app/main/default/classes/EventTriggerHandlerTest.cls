/*
 * @author Shivraj Kadam
 * @since  09/2023
 * @description EventTriggerHandlerTest is the test class to cover tests for {@link EventTriggerHandler}
 */
@isTest
private class EventTriggerHandlerTest {
  @testSetup
  static void setup() {
    Id recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName()
      .get('ML Event')
      .getRecordTypeId();
    Event eve = new Event();
    eve.Subject = 'Call';
    eve.StartDateTime = System.now();
    eve.EndDateTime = System.now() + 1;
    eve.RecordTypeId = recordTypeId;
    insert eve;
  }
  @isTest
  static void getEvent() {
    Test.startTest();
    Event eve = [SELECT ID FROM Event LIMIT 1];
    eve.Description = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';
    update eve;
    System.assert(eve != null);
    Test.stopTest();
  }
}
