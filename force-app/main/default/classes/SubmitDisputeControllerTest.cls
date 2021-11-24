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
      Dispute_Reason__c = 'Charged for a cancelled payment',
      AccountId = acc.Id,
      Is_The_Card_Lost_Stolen__c = 'Lost',
      Status = 'Open',
      Queue__c = null,
      Description = 'Some description',
      Regular_Payment_Cancellation_Date__c = Date.valueOf('2021-10-15'),
      Customer_Contacted_Merchant__c = 'Yes',
      Merchant_Description__c = 'Coles'
    );
    insert new Salesforce_Library_Settings__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      Disable_Triggers__c = true
    );
  }

  @isTest
  static void submitDisputeFlagTest() {
    Case c = (Case) [SELECT Id FROM Case LIMIT 1];
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
}
