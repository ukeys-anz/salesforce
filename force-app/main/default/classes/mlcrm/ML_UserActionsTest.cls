/**
 * @author Ashish Kumar
 * @since 05/2023
 * @description ML_UserActionsTest is the test class for MLCRMUserTerritorySetupActions Class functionality.
 */
@isTest
public class ML_UserActionsTest {
  @testSetup
  static void setup() {
    User mlBusinessAdminUser = MLCRMTestDataFactory.createMLBusinessAdminUser();
    System.runAs(mlBusinessAdminUser) {
      List<Territory__c> territoriesToInsert = new List<Territory__c>();
      territoriesToInsert.add(
        createTerritory('Canberra Inner South (ACT)', 'Unrestricted')
      );
      territoriesToInsert.add(
        createTerritory('Central Coast North (NSW)', 'Unrestricted')
      );
      territoriesToInsert.add(
        createTerritory('Canberra Southside (ACT)', 'Unrestricted')
      );
      insert territoriesToInsert;
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
      WHERE ML_Role__c = 'Franchise Owner' AND Status__c = 'Active'
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
      WHERE ML_Role__c = 'Admin' AND Status__c = 'Active'
    ];
    System.assertEquals(20, lstOfUserTerritory.size());
    List<User_Territory__c> lstOfInactiveUserTerritory = [
      SELECT Id
      FROM User_Territory__c
      WHERE ML_Role__c = 'Admin' AND Status__c = 'Inactive'
    ];
    System.assertEquals(10, lstOfInactiveUserTerritory.size());
  }

  static Territory__c createTerritory(
    String territoryName,
    String accessScope
  ) {
    Territory__c recordTerritory = new Territory__c();
    recordTerritory.Name = territoryName;
    recordTerritory.Access_Scope__c = accessScope;
    recordTerritory.Primary_Franchise_Owner__c = userInfo.getUserId();
    return recordTerritory;
  }
}
