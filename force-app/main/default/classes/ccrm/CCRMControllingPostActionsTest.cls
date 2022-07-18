/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRM Controlling Post Action Test is the test class for CCRM Controlling Post Actions Class.
 */
@isTest
private class CCRMControllingPostActionsTest {
  @testSetup
  static void setup() {
    User ccrmAdmin = CCRMTestDataFactory.createAdminUser();

    System.runAs(ccrmAdmin) {
      Set<String> setOfEmployeeId = new Set<String>{ '10456789', '10456790' };
      CCRMTestDataFactory.createUsersWithEmployeeId(setOfEmployeeId);
    }
  }

  @isTest
  static void testCreateCPID() {
    //Given when banker creates a new Controlling post
    //When Employee ID is a valid User Id
    //Then Controlling Post Responsible Employee will be same as User Id
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Controlling_Post__c cp1 = new Controlling_Post__c();
      cp1.Is_Active__c = true;
      cp1.CPID__c = 'L6601';
      cp1.Name = 'L6601';
      cp1.Responsible_Employee_Id__c = '10456789';
      insert cp1;

      cp1 = [
        SELECT Id, Responsible_Employee__c
        FROM Controlling_Post__c
        WHERE Id = :cp1.id
      ];

      User ccrmUser = [
        SELECT id
        FROM User
        WHERE Employee_Id__c = '10456789'
        LIMIT 1
      ];

      System.assertEquals(
        cp1.Responsible_Employee__c,
        ccrmUser.Id,
        'Controlling Post ID is equal'
      );
    }
  }

  @isTest
  static void testUpdateCPID() {
    //Given when banker updating a new Controlling post with invalid Responsible Employee Id
    //When Responsible Employee ID is updated to a valid user id
    //Then Controlling Post Responsible Employee will be same as User Id
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Controlling_Post__c cp1 = new Controlling_Post__c();
      cp1.Is_Active__c = true;
      cp1.CPID__c = 'L6602';
      cp1.Name = 'L6602';
      cp1.Responsible_Employee_Id__c = '20456790';
      insert cp1;

      System.assertEquals(
        cp1.Responsible_Employee__c,
        null,
        'Controlling Post currently null'
      );

      Controlling_Post__c cp2 = [
        SELECT id, Responsible_Employee_Id__c
        FROM Controlling_Post__c
        WHERE Responsible_Employee_Id__c = '20456790'
        LIMIT 1
      ];

      cp2.Responsible_Employee_Id__c = '10456790';
      update cp2;

      Controlling_Post__c cp3 = [
        SELECT id, Responsible_Employee__c
        FROM Controlling_Post__c
        WHERE Responsible_Employee_Id__c = '10456790'
        LIMIT 1
      ];

      User ccrmUser = [
        SELECT id
        FROM User
        WHERE Employee_Id__c = '10456790'
        LIMIT 1
      ];

      System.assertEquals(
        cp3.Responsible_Employee__c,
        ccrmUser.Id,
        'Controlling Post ID is equal'
      );
    }
  }
}
