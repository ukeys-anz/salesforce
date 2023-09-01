/**
 * @author Ashish Kumar
 * @since 07/2023
 * @description Test class for user territory update batch sharing.
 */
@isTest
public class MLCRM_TerritoryRecalculationBatchTest {
  @testSetup
  static void setup() {
    User adminUser = MLCRMTestDataFactory.createAdminUser();
    User mlUser1 = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlUser2 = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlUser3 = MLCRMTestDataFactory.createMLCRMBaseUser();
    mlUser3.LastName = 'test mluser3';
    update mlUser3;
    adminUser.username = 'Adobe.Integration@anzx.com';
    update adminUser;
    //Create Test Lead Records
    System.runAs(adminUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlUser1,
        true
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
      MLCRMTestDataFactory.createManualLeadRecords(10, mlUser2);
      Test.stopTest();
    }
  }

  //Method to check if records created by excluded user get the access after batch job runs.
  @isTest
  static void validateRecalculation() {
    user objUser = [
      SELECT Id
      FROM User
      WHERE username = 'Adobe.Integration@anzx.com'
      LIMIT 1
    ];
    user objMlUser = [SELECT Id FROM User WHERE LastName = 'test mluser3'];
    System.runAs(objUser) {
      Test.startTest();
      MLCRM_TerritorySharingScheduler objSchedular = new MLCRM_TerritorySharingScheduler();
      objSchedular.execute(null);
      Test.stopTest();
    }

    System.runAs(objMlUser) {
      List<Lead> lstOfLead = [SELECT Id FROM Lead];
      //asserting if records created by excluded user get the access after batch job runs.
      System.assertEquals(lstOfLead.size(), 10);
    }
  }
}
