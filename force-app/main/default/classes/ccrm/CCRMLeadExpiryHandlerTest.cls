/**
 * @author Sahil
 * @since  09/2021
 * @description Test class for CCRM Lead Expiry updates.
 */
@IsTest
public class CCRMLeadExpiryHandlerTest {
  // Public Declaration

  @TestSetup
  static void setup() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    User adminUser = CCRMTestDataFactory.createAdminUser();
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlUser1 = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlBusinessAdminUser = MLCRMTestDataFactory.createMLBusinessAdminUser();
    User iiQUser = MLCRMTestDataFactory.createIIQBaseUser();
    User batchUser = MLCRMTestDataFactory.createCRMBatchUser();
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
      objShare1.userOrgroupid = mlUser.Id;
      lstOfTerritoryShare.add(objShare1);

      insert lstOfTerritoryShare;
    }

    //update ml user record so that user trigger creates corresponding user territory record
    System.runAs(iiQUser) {
      Test.startTest();
      List<User> lstofUserToUpdate = new List<User>();
      mlUser.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser.ML_Role__c = 'Loan Writer';
      lstofUserToUpdate.add(mlUser);

      mlUser1.ML_Territories__c = 'Melbourne CBD (VIC)';
      mlUser1.ML_Role__c = 'Franchise Owner';
      mlUser1.lastName = 'MLCRM1';
      lstofUserToUpdate.add(mlUser1);

      update lstofUserToUpdate;
      Test.stopTest();
    }
    // CCRM Test Data Setup
    System.runAs(ccrmUser) {
      CCRMTestDataFactory.createLeadRecords(10, ccrmUser);
    }
  }

  @IsTest
  static void leadUpdateTest() {
    List<String> lstOfMLUser = new List<String>{ 'Batch User', 'Admin' };
    User objBatchUser;
    User adminUser;
    for (User objUser : [
      SELECT Id, LastName, FirstName
      FROM User
      WHERE LastName IN :lstOfMLUser
    ]) {
      if (objUser.LastName == 'Batch User') {
        objBatchUser = objUser;
      } else {
        adminUser = objUser;
      }
    }

    // admin user to update expiry date to past date for testing purpose.
    System.runAs(adminUser) {
      insert new Salesforce_Library_Settings__c(
        SetupOwnerId = adminUser.Id,
        Disable_VRs__c = true
      );
      //Update Expired lead
      List<Lead> updatedLeads = new List<Lead>();
      for (Lead leadRecord : [
        SELECT Id, Name, Expiry_Date__c, OwnerId
        FROM Lead
        WHERE recordtypeId = :CCRMConstants.CCRM_LEAD_RT_ID
      ]) {
        leadRecord.Expiry_Date__c = System.today() - 2;
        updatedLeads.add(leadRecord);
      }
      Database.update(updatedLeads);
    }
    System.runAs(objBatchUser) {
      List<lead> updatedLeads = [
        SELECT Id, Name, Expiry_Date__c, OwnerId
        FROM Lead
        WHERE recordtypeId = :CCRMConstants.CCRM_LEAD_RT_ID
      ];
      Test.startTest();
      SchedulableContext sc = null;
      CCRMLeadExpiryScheduler schedule = new CCRMLeadExpiryScheduler();
      schedule.execute(sc);
      Test.stopTest();
    }

    System.runAs(adminUser) {
      List<lead> updatedLeads = [
        SELECT Id, Name, Expiry_Date__c, OwnerId
        FROM Lead
        WHERE recordtypeId = :CCRMConstants.CCRM_LEAD_RT_ID
      ];
      Integer expiredLeadsCount = [
        SELECT COUNT()
        FROM Lead
        WHERE
          (Status = :CCRMConstants.STATUS_OUTCOME
          AND Lead_Outcome__c = :CCRMConstants.STATUS_EXPIRED)
          OR Status = :CCRMConstants.STATUS_EXPIRED
      ];
      System.assertEquals(
        updatedLeads.size(),
        expiredLeadsCount,
        'Expired Leads were not updated properly.'
      );
    }
  }
  @IsTest
  static void validateMLleadUpdateTest() {
    List<String> lstOfMLUser = new List<String>{
      'Batch User',
      'Admin',
      'MLCRM'
    };
    User objBatchUser;
    User adminUser;
    User objMLUser;
    for (User objUser : [
      SELECT Id, LastName, FirstName
      FROM User
      WHERE LastName IN :lstOfMLUser AND IsActive = TRUE
    ]) {
      if (
        objUser.LastName == 'Batch User' && objUser.FirstName.contains('CRM')
      ) {
        objBatchUser = objUser;
      } else if (objUser.LastName == 'Admin') {
        adminUser = objUser;
      } else {
        objMLUser = objUser;
      }
    }

    System.runAs(objMLUser) {
      List<Lead> lstOfLead = MLCRMTestDataFactory.createLeadRecords(
        10,
        objMLUser
      );
    }

    // admin user to update expiry date to past date for testing purpose.
    System.runAs(adminUser) {
      insert new Salesforce_Library_Settings__c(
        SetupOwnerId = adminUser.Id,
        Disable_VRs__c = true
      );
      //Update Expired lead
      List<Lead> updatedLeads = new List<Lead>();
      for (Lead leadRecord : [
        SELECT Id, Name, Expiry_Date__c, OwnerId
        FROM Lead
        WHERE recordtypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
      ]) {
        leadRecord.Expiry_Date__c = System.today() - 2;
        updatedLeads.add(leadRecord);
      }
      Database.update(updatedLeads);
    }
    System.runAs(objBatchUser) {
      List<lead> updatedLeads = [
        SELECT Id, Name, Expiry_Date__c, OwnerId
        FROM Lead
        WHERE recordtypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
      ];

      Test.startTest();
      SchedulableContext sc = null;
      CCRMLeadExpiryScheduler schedule = new CCRMLeadExpiryScheduler();
      schedule.execute(sc);
      Test.stopTest();
    }

    System.runAs(adminUser) {
      List<lead> updatedLeads = [
        SELECT Id, Name, Expiry_Date__c, OwnerId
        FROM Lead
        WHERE recordtypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
      ];
      Integer expiredLeadsCount = [
        SELECT COUNT()
        FROM Lead
        WHERE
          Status = :CCRMConstants.STATUS_EXPIRED
          AND recordtypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
      ];
      System.assertEquals(
        updatedLeads.size(),
        expiredLeadsCount,
        'Expired Leads were not updated properly.'
      );
      Group objGrp = [
        SELECT Id
        FROM Group
        WHERE Name = 'ML Expired Leads' AND Type = 'Queue'
        LIMIT 1
      ];
      List<Lead> lstOfMlLead = [
        SELECT Id, OwnerId
        FROM Lead
        WHERE recordtypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
      ];
      for (Lead objLead : lstOfMlLead) {
        // asserting that owner is updated to queue
        System.assertEquals(
          objLead.OwnerId,
          objGrp.Id,
          'ML Lead owner did not updated properly.'
        );
      }
    }
  }
}
