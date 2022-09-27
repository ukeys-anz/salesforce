/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRM Account Action Test is the test class for CCRM Account Actions Class.
 */
@isTest
private class CCRMAccountActionsTest {
  @testSetup
  static void setup() {
    User ccrmAdmin = CCRMTestDataFactory.createAdminUser();
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();

    System.runAs(ccrmAdmin) {
      Set<String> setOfEmployeeId = new Set<String>{ '30456789', '10456790' };
      CCRMTestDataFactory.createUsersWithEmployeeId(setOfEmployeeId);
    }
    System.runAs(ccrmAdmin) {
      Map<String, String> values = new Map<String, String>{
        'L7601' => '30456789',
        'L7602' => '30456790'
      };
      CCRMTestDataFactory.createControllingPosts(values);
    }
  }

  @isTest
  static void testCreateAccount() {
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //Given when banker creates a new Account
      //When CPID is set to a valid CPID
      //Then CPID Link will not be null, it is a hyperlink string
      Account acc = new Account(
        Name = 'Test ANZx Account',
        OCV_ID__c = 'TESTOCVID4321',
        AR_C_Customer__c = true,
        CPID__c = 'L7601'
      );
      insert acc;

      acc = [SELECT Id, CPID_Link__c FROM Account WHERE id = :acc.id];

      System.assertNotEquals(acc.CPID_Link__c, null, acc.CPID_Link__c);
      Test.stopTest();
    }
  }

  @isTest
  static void testCreateAccountWithNoCPID() {
    //Given when banker creates a new Account
    //When CPID is set to a invalid CPID
    //Then CPID Link will be null
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      Account acc1 = new Account(
        Name = 'Test ANZx Account',
        OCV_ID__c = 'TESTOCVID4321',
        AR_C_Customer__c = true,
        CPID__c = 'L7603'
      );
      insert acc1;
      acc1 = [SELECT Id, CPID_Link__c FROM Account WHERE id = :acc1.id];

      System.assertEquals(acc1.CPID_Link__c, 'L7603', 'CPID is plain text');
      Test.stopTest();
    }
  }
}
