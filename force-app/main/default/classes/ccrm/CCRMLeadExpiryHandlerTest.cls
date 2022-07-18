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

    System.runAs(adminUser) {
      insert new Salesforce_Library_Settings__c(
        SetupOwnerId = UserInfo.getOrganizationId(),
        Disable_VRs__c = true
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
      User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
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
        WHERE Status = :CCRMConstants.STATUS_EXPIRED
      ];

      System.assertEquals(
        updatedLeads.size(),
        expiredLeadsCount,
        'Expired Leads were not updated properly.'
      );
    }
  }
}
