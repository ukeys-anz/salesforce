/**
 * @author Ashish Kumar
 * @since 07/2023
 * @description Test class for user territory update batch sharing.
 */
@isTest
public class MLCRM_TerritoryConfigSharingBatchTest {
  @testSetup
  static void setup() {
    User adminUser = MLCRMTestDataFactory.createAdminUser();
    User mlUser1 = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlUser2 = MLCRMTestDataFactory.createMLCRMBaseUser();
    mlUser2.LastName = 'test mluser2';
    update mlUser2;
    User mlUser3 = MLCRMTestDataFactory.createMLCRMBaseUser();
    mlUser3.LastName = 'test mluser3';
    update mlUser3;
    //Create Test Lead Records
    System.runAs(adminUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        adminUser,
        true
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser1.Id,
        lstOfTerritory[0].Id
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser2.Id,
        lstOfTerritory[0].Id
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser3.Id,
        lstOfTerritory[0].Id
      );
      Test.startTest();
      MLCRMTestDataFactory.createManualLeadRecords(10, mlUser1);
      Test.stopTest();
    }
  }

  // Test Method to validate if sharing recaclculation happens when user territory is updated.
  @isTest
  static void validateRecalculation() {
    user objUser = [SELECT Id FROM User WHERE LastName = 'Admin' LIMIT 1];
    objUser.IsActive = true;
    update objUser;
    user objMlUser2 = [SELECT Id FROM User WHERE LastName = 'test mluser2'];
    user objMlUser3 = [SELECT Id FROM User WHERE LastName = 'test mluser3'];
    System.runAs(objMlUser2) {
      List<Lead> lstOfLead = [SELECT Id FROM Lead];
      // asserting if user2 get access to the record when it is created by other user in same territory.
      System.assertEquals(lstOfLead.size(), 10);
    }

    System.runAs(objUser) {
      Test.startTest();
      List<User_Territory__c> lstOfUserTerritory = [
        SELECT Id
        FROM User_Territory__c
        WHERE ML_Role__c = 'Franchise Owner' AND User__c = :objMlUser2.Id
      ];
      lstOfUserTerritory[0].user__c = objMlUser3.Id;
      update lstOfUserTerritory;
      MLCRM_TerritoryConfigSharingScheduler objScheduler = new MLCRM_TerritoryConfigSharingScheduler();
      objScheduler.execute(null);
      Test.stopTest();
    }

    System.runAs(objMlUser2) {
      List<Lead> lstOfLead = [SELECT Id FROM Lead];
      // asserting if user2 access has been removed after batch job finished
      System.assertEquals(lstOfLead.size(), 0);
    }
  }
}
