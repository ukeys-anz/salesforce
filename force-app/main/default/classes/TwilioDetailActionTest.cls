/**
 * @author Aman
 * @since 04/2025
 * @description Test class for TwilioDetailAction.
 */
@isTest
public with sharing class TwilioDetailActionTest {
  private static final Id TEST_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    Twilio_Details__c.SObjectType
  );

  private static Twilio_Details__c createTwilioRecord(String summary) {
    Twilio_Details__c record = new Twilio_Details__c();
    record.Id = TEST_RECORD_ID;
    record.Summary__c = summary;
    return record;
  }

  private static Map<Id, Twilio_Details__c> createOldMap(String oldSummary) {
    Twilio_Details__c oldRecord = new Twilio_Details__c(
      Id = TEST_RECORD_ID,
      Summary__c = oldSummary
    );
    return new Map<Id, Twilio_Details__c>{ TEST_RECORD_ID => oldRecord };
  }

  @isTest
  private static void testMaskSummaryWhenSummaryChanged() {
    List<Twilio_Details__c> newRecords = new List<Twilio_Details__c>{
      createTwilioRecord('Sensitive 1234-5678-9012-3456')
    };
    Map<Id, Twilio_Details__c> oldMap = createOldMap('Visible123');

    Test.startTest();
    TwilioDetailAction.maskSummary(newRecords, oldMap);
    Test.stopTest();

    Assert.areNotEqual(
      'Sensitive 1234-5678-9012-3456',
      newRecords[0].Summary__c,
      'Summary__c should be masked when changed'
    );

    Assert.areEqual(
      'Sensitive ************3456',
      newRecords[0].Summary__c,
      'Summary is not masked as expected'
    );

    Assert.areNotEqual(
      'Visible123',
      newRecords[0].Summary__c,
      'Masked Summary__c should differ from old value'
    );
  }

  @isTest
  private static void testMaskSummaryWhenSummaryChangedInvalidKeywords() {
    List<Twilio_Details__c> newRecords = new List<Twilio_Details__c>{
      createTwilioRecord('Test 123123123')
    };
    Map<Id, Twilio_Details__c> oldMap = createOldMap('Visible123');

    Test.startTest();
    TwilioDetailAction.maskSummary(newRecords, oldMap);
    Test.stopTest();

    Assert.areEqual(
      'Test 123123123',
      newRecords[0].Summary__c,
      'Summary should not be masked as it does not contains keywords'
    );
  }
}
