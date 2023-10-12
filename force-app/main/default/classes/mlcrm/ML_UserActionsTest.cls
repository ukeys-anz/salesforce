/**
 * @author Ashish Kumar
 * @since 05/2023
 * @description ML_UserActionsTest is the test class for MLCRMUserTerritorySetupActions Class functionality.
 */
@isTest
public class ML_UserActionsTest {
  @testSetup
  static void setup() {
    User adminUser = MLCRMTestDataFactory.createAdminUser();
    System.runAs(adminUser) {
      Territory__c objTerritory = new Territory__c();
      objTerritory.Name = 'Canberra Inner South (ACT)';
      objTerritory.Access_Scope__c = 'Unrestricted';
      insert objTerritory;

      Territory__c objTerritory1 = new Territory__c();
      objTerritory1.Name = 'Central Coast North (NSW)';
      objTerritory1.Access_Scope__c = 'Unrestricted';
      insert objTerritory1;

      Territory__c objTerritory2 = new Territory__c();
      objTerritory2.Name = 'Canberra Southside (ACT)';
      objTerritory2.Access_Scope__c = 'Unrestricted';
      insert objTerritory2;
    }
    Test.startTest();
    MLCRMTestDataFactory.createListOfMLCRMBaseUser(10);
    Test.stopTest();
  }

  // Test Method to validate user territory creation when ML user is created.
  @IsTest
  static void validateUserInsertion() {
    List<User_Territory__c> lstOfUserTerritory = [
      SELECT Id
      FROM User_Territory__c
      WHERE ML_Role__c = 'Franchise Owner'
    ];
    System.assertEquals(20, lstOfUserTerritory.size());
  }

  // Test Method to validate user territory creation/updation when ML user is updated.
  @IsTest
  static void validateUserUpdation() {
    Test.startTest();
    List<User> lstOfMlUser = [SELECT Id FROM User WHERE LastName = 'MLCRM'];
    for (User objUser : lstOfMlUser) {
      ObjUser.ML_Role__c = 'Admin';
      ObjUser.ML_Territories__c = 'Central Coast North (NSW);Canberra Southside (ACT)';
    }
    update lstOfMlUser;
    Test.stopTest();
    List<User_Territory__c> lstOfUserTerritory = [
      SELECT Id
      FROM User_Territory__c
      WHERE ML_Role__c = 'Admin'
    ];
    System.assertEquals(20, lstOfUserTerritory.size());
    List<User_Territory__c> lstOfInactiveUserTerritory = [
      SELECT Id
      FROM User_Territory__c
      WHERE ML_Role__c = 'Franchise Owner' AND Status__c = 'Inactive'
    ];
    System.assertEquals(10, lstOfInactiveUserTerritory.size());
  }
}
