/*
 * @author Pragya Awasthi
 * @since  26 Aug 2025
 * @description EventTriggerTest is the test class for trigger code coverage
 */
@isTest
public class EventTriggerTest {
  /**
   * @description test method for trigger code coverage
   */
  @isTest
  static void createEvent() {
    Event eve = new Event(
      Subject = 'Call',
      StartDateTime = System.now(),
      EndDateTime = System.now() + 1,
      RecordTypeId = RTEvent.mlEvent
    );

    try {
      Test.startTest();
      insert eve;
      Test.stopTest();
    } catch (Exception e) {
      Assert.fail('Should be no Exception');
    }
  }
}
