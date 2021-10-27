@isTest
public with sharing class DisputesValidationTest {
  @TestSetup
  // Turn off triggers to run tests
  static void turnOffTriggers() {
    Id cardRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get('Card_Dispute')
      .getRecordTypeId();
    // Create test data for account case
    Account acc = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = 'OCV78786678',
      ANZx_Customer__c = true
    );
    insert acc;
    insert new Case(
      RecordTypeID = cardRTId,
      Subject = 'Test Disputes',
      Type = 'Cards',
      Dispute_Reason__c = 'Charged for a cancelled payment',
      AccountId = acc.Id,
      Is_The_Card_Lost_Stolen__c = 'Lost',
      Status = 'Open',
      Queue__c = null
    );
    insert new Salesforce_Library_Settings__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      Disable_Triggers__c = true
    );
  }
  // When Case Owner is manually re-assigned from Queue to a User
  @isTest
  static void testDisputesQueuetoUser() {
    Case c = (Case) [SELECT Id FROM Case LIMIT 1];
    c.OwnerId = UserInfo.getUserId();
    Test.startTest();
    try {
      update c;
    } catch (Exception e) {
      System.assertEquals(
        true,
        e.getMessage()
          .contains(
            'For ATM or Card record types, please select either Card Disputes - General Queue or Card Disputes - Fraud Queue.'
          ),
        'Incorrect error message.'
      );
    }
    Test.stopTest();
  }

  // When manually re-assigned to a valid Queue to pass
  @isTest
  static void testDisputesValidQueue() {
    Case c = (Case) [SELECT Id FROM Case LIMIT 1];
    c.Queue__c = 'Card Disputes - General Queue';
    Test.startTest();
    try {
      update c;
    } catch (Exception e) {
      System.assertEquals(
        false,
        e.getMessage()
          .contains(
            'For ATM or Card record types, please select either Card Disputes - General Queue or Card Disputes - Fraud Queue.'
          ),
        'Incorrect error message.'
      );
    }
    Test.stopTest();
  }

  // When the Status changes to closed and the External Case ID is null
  @isTest
  static void testDisputesStatusClosedNullExternal() {
    Case c = (Case) [SELECT Id, External_System__c, Status FROM Case LIMIT 1];
    c.External_Case_ID__c = null;
    c.Status = 'Closed';
    Test.startTest();
    try {
      update c;
    } catch (Exception e) {
      System.assertEquals(
        true,
        e.getMessage()
          .contains(
            'These fields are required in order to change Status from open - External System and External Case ID.'
          ),
        'Incorrect error message.'
      );
    }
    Test.stopTest();
  }

  // When External System is changed and External Case ID is null
  @isTest
  static void testDisputesChangedButNullExternal() {
    Case c = (Case) [
      SELECT Id, External_System__c, External_Case_ID__c
      FROM Case
      LIMIT 1
    ];
    c.External_Case_ID__c = null;
    c.External_System__c = 'CARBe';
    Test.startTest();
    try {
      update c;
    } catch (Exception e) {
      System.assertEquals(
        true,
        e.getMessage()
          .contains(
            'Please select an External System and acknowledge that External System ID has been provided.'
          ),
        'Incorrect error message.'
      );
    }
    Test.stopTest();
  }
}
