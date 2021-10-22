@isTest
public with sharing class DisputesValidationTest {
    @TestSetup
    // Turn off triggers to run tests
    static void turnOffTriggers(){
        insert new Salesforce_Library_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Disable_Triggers__c=true);
        
    // Create test data for account case
    Account acc = insert new Account(
          Name = 'TestAccount',
          Display_Name__c = 'TestAccount',
          OCV_ID__c = faker.randomString(10),
          ANZx_Customer__c = true
        );
    insert new Case (
        RecordTypeId = GetHelpCaseActions.CARD_DISPUTE_RT_ID,
        Subject = 'Test Disputes',
        Type = 'Cards',
        Dispute_Reason__c = 'Charged for a cancelled payment',
        AccountId = acc.Id,
        Is_The_Card_Lost_Stolen__c = 'Lost'
      );

    }
    // Manually re-assign Dispute Queue Owner to a User
    @isTest
    static void testOne(){
        Case c = (Case)[SELECT Id FROM Case LIMIT 1];
        c.OwnerId = UserInfo.getUserId();
        Test.startTest();
        update c;
        Test.stopTest();

        //catch errormessag


    }

    // Manually re-assign to a valid Queue

    // When status changes to closed and the External Case ID is null to throw error
    
    // When External Case ID or External System is changed, then either field is null to throw error





}
