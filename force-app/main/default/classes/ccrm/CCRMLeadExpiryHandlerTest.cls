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
    mlUser1.lastName = 'MLCRM1';
    update mlUser1;
    System.runAs(adminUser) {
      insert new Salesforce_Library_Settings__c(
        SetupOwnerId = UserInfo.getOrganizationId(),
        Disable_VRs__c = true
      );
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        adminUser,
        true
      );
      territory__share obj = new territory__share();
      obj.UserOrGroupId = mlUser.id;
      obj.ParentId = lstOfTerritory[0].id;
      obj.AccessLevel = 'read';
      insert obj;
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser.Id,
        lstOfTerritory[0].Id
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser1.Id,
        lstOfTerritory[0].Id
      );
    }
    // CCRM Test Data Setup
    System.runAs(ccrmUser) {
      CCRMTestDataFactory.createLeadRecords(10, ccrmUser);
    }
  }

  @IsTest
  static void leadUpdateTest() {
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      CCRMTestDataFactory.getCCRMBaseUser();
      //Update Expired lead
      List<Lead> updatedLeads = new List<Lead>();
      for (Lead leadRecord : [
        SELECT Id, Name, Expiry_Date__c, OwnerId
        FROM Lead
      ]) {
        leadRecord.Expiry_Date__c = System.today() - 2;
        updatedLeads.add(leadRecord);
      }

      Database.update(updatedLeads);
      Test.startTest();
      SchedulableContext sc = null;
      CCRMLeadExpiryScheduler schedule = new CCRMLeadExpiryScheduler();
      schedule.execute(sc);
      Test.stopTest();

      //Asserts
      //Checking by searching records with Status 'Expired'.
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
    List<String> lstOfMLUser = new List<String>{'MLCRM','MLCRM1'};
    User objMLUser ;
    User objMLUser1;
    for(User objUser : [SELECT Id, LastName, FirstName
      FROM User
      WHERE LastName IN: lstOfMLUser]) {
        if(objUser.LastName == 'MLCRM') {
          objMLUser = objUser;
        }
        else {
          objMLUser1 = objUser;
        }
      }
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Test.startTest();
      List<Lead> lstOfLead = MLCRMTestDataFactory.createLeadRecords(
        10,
        objMLUser
      );
      // Explicitly creating lead share record for other MLUser to check same gets deleted after batch runs
      LeadShare objShare = new LeadShare();
      objShare.LeadId = lstOfLead[0].Id;
      objShare.LeadAccessLevel = 'Read';
      objShare.RowCause = 'Manual';
      objShare.UserOrGroupId = objMLUser1.Id;
      insert objShare;

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
      SchedulableContext sc = null;
      CCRMLeadExpiryScheduler schedule = new CCRMLeadExpiryScheduler();
      schedule.execute(sc);
      Test.stopTest();

      //checking MLCRM user has lost the access after expiry batch has runs
      System.runAs(objMLUser1) {
        Integer leadsCount = [
          SELECT COUNT()
          FROM Lead
          WHERE recordtypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
        ];
        System.assertEquals(LeadsCount, 0, 'Expired ML lead still visible to user1');
      }

      System.runAs(objMLUser) {
        Integer leadsCount = [
          SELECT COUNT()
          FROM Lead
          WHERE recordtypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
        ];
        System.assertEquals(LeadsCount, 0, 'Expired ML lead still visible to user');
      }
      //Asserts
      //Checking by searching records with Status 'Expired'.
      Integer expiredLeadsCount = [
        SELECT COUNT()
        FROM Lead
        WHERE Status = :CCRMConstants.STATUS_EXPIRED
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
        System.assertEquals(
          objLead.OwnerId,
          objGrp.Id,
          'ML Lead owner did not updated properly.'
        );
      }
    }
  }
}
