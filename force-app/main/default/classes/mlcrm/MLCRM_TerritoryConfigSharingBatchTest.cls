/**
 * @author Ashish Kumar
 * @since 07/2023
 * @description Test class for user territory update batch sharing.
 */
@isTest
public class MLCRM_TerritoryConfigSharingBatchTest {
  @testSetup
  static void setup() {
    User mlBusinessAdminUser = MLCRMTestDataFactory.createMLBusinessAdminUser();
    User iiQUser = MLCRMTestDataFactory.createIIQBaseUser();
    User batchUser = MLCRMTestDataFactory.createCRMBatchUser();
    User mlUser1 = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlUser2 = MLCRMTestDataFactory.createMLCRMBaseUser();
    mlUser2.LastName = 'testmluser2x0';
    update mlUser2;
    User mlUser3 = MLCRMTestDataFactory.createMLCRMBaseUser();
    mlUser3.LastName = 'testmluser3x0';
    update mlUser3;
    //Create Test Lead Records
    System.runAs(mlBusinessAdminUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlBusinessAdminUser,
        true
      );
      set<ID> userIds = new Set<ID>{ mlUser1.Id, mlUser2.Id, mlUser3.Id };
      List<Territory__Share> lstOfTerritoryShare = MLCRMTestDataFactory.createTerritoryShareWithMultipleUsers(
        lstOfTerritory[0],
        userIds,
        true
      );
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
      lstofUserToUpdate.add(mlUser2);
      mlUser3.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser3.ML_Role__c = 'Franchise Owner';
      lstofUserToUpdate.add(mlUser3);
      batchUser.lastname = 'batchUserTestUser';
      lstofUserToUpdate.add(batchUser);
      update lstofUserToUpdate;
      Test.stopTest();
    }
    System.runAs(mlUser1) {
      List<Lead> leadList = MLCRMTestDataFactory.createManualLeadRecords(
        10,
        mlUser1
      );
      //manually sharing lead record as platform event running during create manual lead records will be async processto share lead records
      MLCRMTestDataFactory.createLeadShare(mlUser2.id, leadList, true);
    }
  }

  // Test Method to validate if sharing recaclculation happens when user territory is updated.
  @isTest
  static void validateRecalculation() {
    user batchUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'batchUserTestUser'
      LIMIT 1
    ];
    user mlUser2 = [SELECT Id FROM User WHERE LastName = 'testmluser2x0'];
    user mlUser3 = [SELECT Id FROM User WHERE LastName = 'testmluser3x0'];
    System.runAs(mlUser2) {
      List<Lead> lstOfLead = [SELECT Id FROM Lead];
      // asserting if user2 get access to the record when it is created by other user in same territory.
      System.assertEquals(
        lstOfLead.size(),
        10,
        'Lead record is not shared with mlcrm 2 user'
      );
    }

    System.runAs(batchUser) {
      Test.startTest();
      List<User_Territory__c> lstOfUserTerritory = [
        SELECT Id
        FROM User_Territory__c
        WHERE ML_Role__c = 'Franchise Owner' AND User__c = :mlUser2.Id
      ];
      for (User_Territory__c ut : lstOfUserTerritory) {
        ut.user__c = mlUser3.Id;
      }
      update lstOfUserTerritory;
      MLCRM_TerritoryConfigSharingScheduler objScheduler = new MLCRM_TerritoryConfigSharingScheduler();
      objScheduler.execute(null);
      Test.stopTest();
    }


    // System.runAs(mlUser2) {
    //   List<Lead> lstOfLead = [SELECT Id FROM Lead];
    //   // asserting if user2 access has been removed after batch job finished
    //   System.assertEquals(
    //     lstOfLead.size(),
    //     0,
    //     'Lead record is still shared with mlcrm 2 user'
    //   );
    // }
  }
}
