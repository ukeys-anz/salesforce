/**
 * @author Ashish Kumar
 * @since 07/2023
 * @description Test class for user territory update batch sharing.
 */
@isTest
public class MLCRM_TerritoryRecalculationBatchTest {
  @testSetup
  static void setup() {
    User mlBusinessAdminUser = MLCRMTestDataFactory.createMLBusinessAdminUser();
    User mlUser1 = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlUser2 = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlUser3 = MLCRMTestDataFactory.createMLCRMBaseUser();
    User iiQUser = MLCRMTestDataFactory.createIIQBaseUser();
    User adobeUser = MLCRMTestDataFactory.getMLCRMIntegrationUser(
      Label.AdobeIntegrationUserName
    );
    mlUser3.LastName = 'test mluser3';
    update mlUser3;
    //Create Test Lead Records
    System.runAs(mlBusinessAdminUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlBusinessAdminUser,
        true
      );
      List<Territory__Share> lstOfTerritoryShare = new List<Territory__Share>();
      Territory__Share objShare = new Territory__Share();
      objShare.parentId = lstOfTerritory[0].Id;
      objShare.accesslevel = 'Edit';
      objShare.userOrgroupid = mlUser1.Id;
      lstOfTerritoryShare.add(objShare);
      Territory__Share objShare1 = new Territory__Share();
      objShare1.parentId = lstOfTerritory[0].Id;
      objShare1.accesslevel = 'Edit';
      objShare1.userOrgroupid = mlUser2.Id;
      lstOfTerritoryShare.add(objShare1);
      Territory__Share objShare2 = new Territory__Share();
      objShare2.parentId = lstOfTerritory[0].Id;
      objShare2.accesslevel = 'Edit';
      objShare2.userOrgroupid = mlUser3.Id;
      lstOfTerritoryShare.add(objShare2);
      insert lstOfTerritoryShare;
    }
    //update ml user record so that user trigger creates corresponding user territory record
    System.runAs(iiQUser) {
      Test.startTest();
      List<User> lstofUserToUpdate = new List<User>();
      mlUser1.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser1.ML_Role__c = 'Loan Writer';
      lstofUserToUpdate.add(mlUser1);

      mlUser2.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser2.ML_Role__c = 'Franchise Owner';
      mlUser2.lastName = 'MLCRM11';
      lstofUserToUpdate.add(mlUser2);
      mlUser3.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser3.ML_Role__c = 'Franchise Owner';
      lstofUserToUpdate.add(mlUser3);

      update lstofUserToUpdate;
      Test.stopTest();
    }
    System.runAs(adobeUser) {
      MLCRMTestDataFactory.createManualLeadRecords(10, mlUser2);
    }
    //Create Test customer relationship notes Records
    System.runAs(mlUser1) {
      MLCRMTestDataFactory.createCustomerRelationNotes();
    }
  }

  //Method to check if records created by excluded user get the access after batch job runs.
  @isTest
  static void validateRecalculation() {
    user objUser = [
      SELECT Id
      FROM User
      WHERE username LIKE :Label.AdobeIntegrationUserName
      LIMIT 1
    ];
    user objMlUser = [SELECT Id FROM User WHERE LastName = 'test mluser3'];
    System.runAs(objUser) {
      Test.startTest();
      MLCRM_TerritorySharingScheduler objScheduler = new MLCRM_TerritorySharingScheduler();
      objScheduler.execute(null);
      Test.stopTest();
    }

    System.runAs(objMlUser) {
      List<Lead> lstOfLead = [SELECT Id FROM Lead];
      //asserting if records created by excluded user get the access after batch job runs
      System.assertEquals(lstOfLead.size(), 0);
    }
  }
}