/**
 * @author Sahil
 * @since  09/2021
 * @description Test class for CCRM Lead Expiry Reminder Test.
 */
@IsTest(seeAllData=false)
public class CCRMLeadExpiryReminderTest {
  // Public Declaration

  @TestSetup
  static void setup() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    // CCRM Test Data Setup
    System.runAs(ccrmUser) {
      CCRMTestDataFactory.createLeadRecords(
        Integer.valueOf(Label.Test_Bulk_Size),
        new User()
      );
    }
    System.runAs(mlUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(10,mlUser,true);
      MLCRMTestDataFactory.createUserTerritoryRecords(10,mlUser.Id,lstOfTerritory[0].Id);
      MLCRMTestDataFactory.createLeadRecords(
        Integer.valueOf(Label.Test_Bulk_Size),
        new User()
      );
    }
  }

  @IsTest
  static void leadExpiryReminderTest() {
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Map<Id, Boolean> mapOfLeadIdToTypeOfLead = new Map<Id, Boolean>();
      //GIVEN Lead expiring in 48h
      List<Lead> updatedLeads = new List<Lead>();
      for (Lead leadRecord : [
        SELECT
          Id,
          Name,
          RecordTypeId,
          Expiry_Date__c,
          CCRM_ExpiryNotificationCheck__c
        FROM Lead
      ]) {
        if (leadRecord.recordtypeId == CCRMConstants.CCRM_LEAD_RT_ID) {
          leadRecord.Expiry_Date__c = System.today() + 1;
        } else if (leadRecord.recordtypeId == MLCRMConstants.MLCRM_LEAD_RT_ID) {
          leadRecord.Expiry_Date__c = System.today() + 2;
        }
        mapOfLeadIdToTypeOfLead.put(
          leadRecord.Id,
          leadRecord.recordtypeId == CCRMConstants.CCRM_LEAD_RT_ID
            ? true
            : false
        );
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
        SELECT Body, ParentId
        FROM FeedItem
        WHERE ParentId IN :(new Map<Id, Lead>(updatedLeads).keySet())
        ORDER BY CreatedDate DESC
        LIMIT 2
      ]) {
        if (
          mapOfLeadIdToTypeOfLead.containsKey(item.parentId) &&
          mapOfLeadIdToTypeOfLead.get(item.parentId)
        ) {
          System.assert(
            item.Body.contains(Label.NotfiyInprogressLead1DayPriorExpiry),
            'Reminder not created for Leads about to get Expired.'
          );
        } else {
          System.assert(
            item.Body.contains(Label.ML_ExpiryRemainderMessage),
            'Reminder not created for Leads about to get Expired.'
          );
        }
      }
    }
  }
}
