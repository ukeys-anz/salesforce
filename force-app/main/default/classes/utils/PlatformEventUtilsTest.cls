/**
 * @author Jasmine Nguyen
 * @since Nov 2021
 * @description Test class for {@link PlatformEventUtils}
 * @group Utility
 */
@isTest
public with sharing class PlatformEventUtilsTest {
  // Test publishing platform event successfully
  @isTest
  static void testPublishPlatformEventsSuccessfully() {
    // GIVEN
    // A platform event with a field values
    Disputes_PEGA_Integration_Event__e pe = new Disputes_PEGA_Integration_Event__e(
      Case_Id__c = '00012ABCDEF',
      Transaction_Id__c = 'abc-123-cdf-456',
      Original_Case_Number__c = 'ABC123',
      Record_Type_Name__c = 'ATM',
      Span_Id__c = 'ab752jf9sd7',
      Correlation_Id__c = 'fjsadj2378fsj'
    );
    List<sObject> events = new List<sObject>();
    events.add(pe);

    // WHEN
    // Calling publishEvents()
    Test.startTest();
    List<sObject> publishedEvents = PlatformEventUtils.publishEvents(events);
    Test.stopTest();

    // THEN
    // A plafform event with the specified type and field values is published
    System.assertEquals(
      1,
      publishedEvents.size(),
      'Number of published events should match.'
    );
    System.assertEquals(
      '00012ABCDEF',
      publishedEvents[0].get('Case_Id__c'),
      'Case Id should match.'
    );
    System.assertEquals(
      'abc-123-cdf-456',
      publishedEvents[0].get('Transaction_Id__c'),
      'Transaction Id should match.'
    );
    System.assertEquals(
      'ABC123',
      publishedEvents[0].get('Original_Case_Number__c'),
      'Case Number should match.'
    );
    System.assertEquals(
      'ATM',
      publishedEvents[0].get('Record_Type_Name__c'),
      'Record Type Name should match.'
    );
    System.assertEquals(
      'ab752jf9sd7',
      publishedEvents[0].get('Span_Id__c'),
      'Span Id should match.'
    );
    System.assertEquals(
      'fjsadj2378fsj',
      publishedEvents[0].get('Correlation_Id__c'),
      'Correlation Id should match.'
    );
  }

  // Test publishing platform event unsuccessfully
  @isTest
  static void testPublishPlatformEventsUnsuccessfully() {
    // GIVEN
    // A platform event with a specified type and field values
    Disputes_PEGA_Integration_Event__e pe = new Disputes_PEGA_Integration_Event__e(
      Case_Id__c = '00012ABCDEF',
      Transaction_Id__c = 'abc-123-cdf-456',
      Original_Case_Number__c = 'ABC123',
      Record_Type_Name__c = 'ATM',
      Span_Id__c = 'ab752jf9sd7',
      Correlation_Id__c = 'fjsadj2378fsj'
    );
    List<sObject> events = new List<sObject>();
    events.add(pe);

    // WHEN
    // Calling publishEvents()
    Test.startTest();
    PlatformEventUtils.throwException = true;
    List<sObject> publishedEvents = PlatformEventUtils.publishEvents(events);
    Test.stopTest();

    // THEN
    // A plafform event with the specified type and field values is NOT published
    System.assertEquals(
      0,
      publishedEvents.size(),
      'Number of published events should match.'
    );
    // CANNOT assert if log has been created since the Database.Immediate() does not fire in test context
  }
}
