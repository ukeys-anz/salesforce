/**
 * @author Sahil
 * @since  09/2021
 * @description Test class for CCRM Lead Expiry Reminder Test.
 */
@IsTest
public class CCRMLeadExpiryReminderTest {
  // Public Declaration

  @TestSetup
  static void setup() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    // CCRM Test Data Setup
    System.runAs(ccrmUser) {
      CCRMTestDataFactory.createLeadRecords(
        Integer.valueOf(Label.Test_Bulk_Size),
        new User()
      );
    }
  }

  @IsTest
  static void leadExpiryReminderTest() {
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      //GIVEN Lead expiring in 48h
      List<Lead> updatedLeads = new List<Lead>();
      for (Lead leadRecord : [SELECT Id, Name, Expiry_Date__c FROM Lead]) {
        leadRecord.Expiry_Date__c = System.today() + 1;
        updatedLeads.add(leadRecord);
      }
      Database.update(updatedLeads);
      //WHEN Job Runs
      Test.startTest();
      SchedulableContext sc = null;
      CCRMLeadExpiryReminderScheduler schedule = new CCRMLeadExpiryReminderScheduler();
      schedule.execute(sc);
      Test.stopTest();

      //THEN Owners are notified on Leads getting Expired.
      for (FeedItem item : [
        SELECT Body
        FROM FeedItem
        WHERE ParentId IN :(new Map<Id, Lead>(updatedLeads).keySet())
        ORDER BY CreatedDate DESC
        LIMIT 2
      ]) {
        System.assert(
          item.Body.contains(Label.CCRM_ExpiryReminderMessage),
          'Reminder not created for Leads about to get Expired.'
        );
      }
    }
  }
}
