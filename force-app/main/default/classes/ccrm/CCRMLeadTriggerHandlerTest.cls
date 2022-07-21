/**
 * @author Olivier Saier
 * @since 08/2021
 * @description LeadTriggerHandlerTest is the test class for Lead Trigger and Lead Trigger Handler Class.
 */
@isTest
private class CCRMLeadTriggerHandlerTest {
  @testSetup
  static void setup() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    User ccrmIntegrationUser = CCRMTestDataFactory.createCCRMIntegrationUser();
    //CREATE Test Lead Records
    System.runAs(ccrmUser) {
      CCRMTestDataFactory.createLeadRecords(
        Integer.valueOf(Label.Test_Bulk_Size),
        ccrmUser
      );
    }
  }

  @isTest
  static void testLeadDeletion() {
    DmlException dmlError;
    //GIVEN leads
    Lead[] leads = [SELECT Id FROM Lead];
    //WHEN try to delete them
    try {
      System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
        delete leads;
      }
    } catch (DMLexception e) {
      dmlError = e;
    }
    //THEN I get an error
    system.assert(
      dmlError != null &&
      dmlError.getMessage().contains(LeadTriggerHandler.DELETE_ERROR),
      'An exception should be thrown on deleting leads.'
    );
  }

  @isTest
  static void testLeadUpdation() {
    //Declaration
    List<Lead> updateleads = new List<Lead>();

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      //GIVEN Lead
      Lead[] leads = [SELECT Id, OwnerId FROM Lead];

      //WHEN I try to update the Owner.
      for (Lead lead : leads) {
        lead.OwnerId = UserInfo.getUserId();
        updateleads.add(lead);
      }
      Database.update(updateleads);
    }
    Test.stopTest();

    //THEN a Chatter post is created automatically.
    FeedItem[] feedItemCount = [
      SELECT Id
      FROM FeedItem
      WHERE ParentId IN :updateleads
    ];
    system.assert(
      feedItemCount.size() >= Integer.ValueOf(Label.Test_Bulk_Size),
      'Chatter Feed is not getting created automatically.'
    );
  }

  @isTest
  static void testLeadCreation() {
    User ccrmIntegrationUser = CCRMTestDataFactory.getCCRMIntegrationUser();
    Test.startTest();
    System.runAs(ccrmIntegrationUser) {
      CCRMTestDataFactory.createLeadRecords(
        Integer.valueOf(Label.Test_Bulk_Size),
        ccrmIntegrationUser
      );
    }
    Test.stopTest();
    //Asserts
    //Checking by searching records with Status 'New'.
    List<Lead> createdLeads = [
      SELECT Id
      FROM Lead
      WHERE
        Status = :CCRMConstants.STATUS_NEW
        AND createdById = :ccrmIntegrationUser.Id
    ];
    System.assertEquals(
      createdLeads.size() == Integer.valueOf(Label.Test_Bulk_Size),
      true,
      'New Leads not created successfully.'
    );
  }

  @isTest
  static void testPopulateFromPreviousLead() {
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Lead[] leads = [
        SELECT Id, LastName, Description, Business_Id__c
        FROM Lead
      ];
      Test.startTest();
      //GIVEN an Adobe lead with previous lead id
      Lead leadRecord = new Lead();
      leadRecord.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
      leadRecord.Description = 'Test Description';
      leadRecord.FirstName = 'Test';
      leadRecord.LastName = 'Lead';
      leadRecord.LeadSource = 'Partner';
      leadRecord.New_to_Bank__c = 'Yes';
      leadRecord.Lead_Originator__c = 'Adobe';
      leadRecord.Previous_Lead__c = leads[0].Id;
      //WHEN it is inserted
      Database.DMLOptions dml = new Database.DMLOptions();
      dml.DuplicateRuleHeader.AllowSave = true;
      Database.SaveResult sr = Database.insert(leadRecord, dml);
      Test.stopTest();
      //THEN the field values will be copied from previous lead to new lead
      Lead record;
      record = [
        SELECT LastName, Description, Business_Id__c
        FROM Lead
        WHERE Previous_Lead__c = :leads[0].Id
      ];
      system.assertEquals(leads[0].LastName, record.LastName);
      system.assertEquals(leads[0].Description, record.Description);
      system.assertEquals(leads[0].Business_Id__c, record.Business_Id__c);
    }
  }
}
