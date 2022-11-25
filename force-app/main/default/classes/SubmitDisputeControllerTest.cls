/**
 *
 * @author Rebecca Jan
 * @since 2021
 * @description SubmitDisputeControllerTest is the test class for the SubmitDisputeController class
 */
@isTest
public with sharing class SubmitDisputeControllerTest {
  @TestSetup
  // Turn off triggers to run tests
  static void turnOffTriggers() {
    // Create test data for account case
    Account acc = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = 'OCV78786678',
      ANZx_Customer__c = true
    );
    insert acc;
    insert new Case(
      RecordTypeID = GetHelpConstants.CARD_DISPUTE_RT_ID,
      Subject = 'Test Disputes',
      Type = 'Cards',
      Dispute_Reason__c = 'Don\'t recognise the transaction',
      AccountId = acc.Id,
      Is_The_Card_Lost_Stolen__c = 'Lost',
      Has_The_Card_Been_Stopped__c = 'Yes',
      Status = 'Open',
      Queue__c = null,
      Description = 'Some description'
    );
    insert new Salesforce_Library_Settings__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      Disable_Triggers__c = true
    );
  }

  @isTest
  static void submitDisputeFlagTest() {
    Case c = [SELECT Id FROM Case LIMIT 1];
    Test.startTest();
    try {
      Boolean result = SubmitDisputeController.updateSubmitFlag(c.Id);
      System.assertEquals(
        true,
        result,
        'The controller failed to update Submitted__c to true.'
      );
    } catch (Exception ex) {
      if (ex.getMessage().contains('Dispute unable to be submitted')) {
        System.assert(true, 'Error message displayed');
      } else {
        System.assert(false, 'Incorrect error message');
      }
    }
    Test.stopTest();
  }

  @isTest
  static void testMissingCardTokenNumberCardDispute() {
    Case c = [SELECT Id FROM Case LIMIT 1];

    Test.startTest();
    Boolean cardNumberIsMissing = SubmitDisputeController.verifyCardTokenNumber(
      c.Id
    );
    Test.stopTest();

    System.assertEquals(
      true,
      cardNumberIsMissing,
      'The controller should confirm card number is missing.'
    );
  }

  @isTest
  static void testCardTokenNumberNotStoredDirectEntryDispute() {
    Case c = [SELECT Id FROM Case LIMIT 1];
    c.RecordTypeId = GetHelpConstants.DIRECT_DEBIT_DISPUTE_RT_ID;
    update c;

    Test.startTest();
    Boolean cardNumberIsMissing = SubmitDisputeController.verifyCardTokenNumber(
      c.Id
    );

    Test.stopTest();

    System.assertEquals(
      false,
      cardNumberIsMissing,
      'The controller should confirm card number is not missing as not required for this dispute type.'
    );
  }

  @isTest
  static void testCardTokenNumberExists() {
    Case c = [SELECT Id, Card_Token_Number__c FROM Case LIMIT 1];

    c.Card_Token_Number__c = '8051997368527878';
    update c;

    Test.startTest();
    Boolean cardNumberIsMissing = SubmitDisputeController.verifyCardTokenNumber(
      c.Id
    );
    Test.stopTest();

    System.assertEquals(
      false,
      cardNumberIsMissing,
      'The controller should confirm card number was not missing.'
    );
  }
}
