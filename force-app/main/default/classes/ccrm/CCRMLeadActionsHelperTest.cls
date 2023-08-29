/**
 * @author Naman Garg
 * @since  30/2023
 * @description This class is to provide generic test data setups CCRM test classes.
 * @group Utils
 */

@isTest
private class CCRMLeadActionsHelperTest {
  @TestSetup
  static void setup() {
    User ccrmUserBB = CCRMTestDataFactory.createCCRMRelManagerUser();
    ccrmUserBB.Commercial_Segment__c = CCRMConstants.BB_SEGMENT;
    update ccrmUserBB;
    User ccrmUserSBB = CCRMTestDataFactory.createCCRMSmallBusinessBankingUser();
    ccrmUserSBB.Commercial_Segment__c = CCRMConstants.SBB_SEGMENT;
    update ccrmUserSBB;

    System.runAs(ccrmUserBB) {
      CCRMTestDataFactory.createLeadRecords(
        Integer.valueOf(Label.Test_Bulk_Size),
        ccrmUserBB
      );
    }
  }

  @isTest
  static void testLeadOwnership() {
    Lead getLead = [SELECT Id, OwnerId, RecordTypeId FROM Lead LIMIT 1];
    List<User> users = [
      SELECT Id, UserRole.Name, Commercial_Segment__c
      FROM User
      WHERE
        Profile.Name = 'ANZ CCRM Standard User'
        AND LastName = 'CCRM'
        AND UserRole.Name IN ('Relationship Manager', 'Small Business Banking')
      LIMIT 2
    ];

    User rmUser = users[0].UserRole.Name == 'Relationship Manager'
      ? users[0]
      : users[1];
    String errorMessage = '';
    final String expError = 'Leads can only be transferred within your segment.';

    Test.startTest();
    System.runAs(rmUser) {
      try {
        getLead.OwnerId = users[1].Id;
        update getLead;
      } catch (DMLException e) {
        errorMessage = e.getDmlMessage(0);
      }
    }

    Test.stopTest();
    system.assertEquals(expError, errorMessage, 'Lead transfer successfully');
  }
}
