/**
 * @author Sahil
 * @since  12/2021
 * @description Test class for CCRM Task Action Class.
 */
@IsTest
public with sharing class CCRMTaskActionsTest {
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
      CCRMTestDataFactory.createLeadWithBusinessAccount(new User());
      List<Campaign> campaignRecord = CCRMTestDataFactory.createCCRMCampaignRecord(
        1
      );
      CCRMTestDataFactory.createResponseTypeRecords(campaignRecord[0]);
    }

    System.runAs(mlUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        10,
        mlUser,
        true
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        10,
        mlUser.Id,
        lstOfTerritory[0].Id
      );
      MLCRMTestDataFactory.createLeadRecords(10, mlUser);
    }
  }

  @isTest
  static void testExpiryDateLogResponseAddedWithoutFollowupDate() {
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //GIVEN leads
      List<Lead> leads = [SELECT Id FROM Lead LIMIT 1];

      Response_Type__c rtAccepted = [
        SELECT Id, Name, Campaign__c, Response_Status__c, Create_Opportunity__c
        FROM Response_Type__c
        WHERE Response_Status__c = 'Accepted'
        LIMIT 1
      ];

      CCRMTestDataFactory.createCampaignMemberRecord(
        leads,
        rtAccepted.Campaign__c
      );

      Task task = new Task();
      task.Response_Status__c = 'Accepted';
      task.Status = CCRMConstants.STATUS_COMPLETED;
      task.Outcome_Reason__c = 'Happy with the offer';
      task.Subject = 'Accepted' + ': ' + 'Happy with the offer';
      task.Description = 'Test expiry date';
      task.recordTypeId = CCRMConstants.LEAD_RESPONSE_RT_ID;
      task.WhoId = leads[0].Id;
      task.ActivityDate = null;
      task.Response_Type__c = rtAccepted.Id;

      //WHEN
      insert task;
      Test.stopTest();

      //THEN
      Date todaysDate = Date.valueOf(
        System.today() + Integer.valueOf(System.Label.CCRM_Today_Date)
      );
      Date newExpiryDate = DateTimeUtils.getWeekday(
        todaysDate.addDays(5),
        false,
        true
      );
      Lead[] updatedlead = [
        SELECT Id, Expiry_Date__c
        FROM Lead
        WHERE Id = :leads
      ];
      System.assertEquals(
        updatedlead[0].Expiry_Date__c,
        newExpiryDate,
        'Expiry date updated correctly'
      );
    }
  }

  @IsTest
  static void testDeleteResponse() {
    Task task;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //GIVEN a response is logged against lead
      List<Lead> leads = [SELECT Id FROM Lead LIMIT 1];

      Response_Type__c rtAccepted = [
        SELECT Id, Name, Campaign__c, Response_Status__c, Create_Opportunity__c
        FROM Response_Type__c
        WHERE Response_Status__c = 'Accepted'
        LIMIT 1
      ];
      task = new Task();
      task.Response_Status__c = 'Accepted';
      task.Status = CCRMConstants.STATUS_COMPLETED;
      task.Outcome_Reason__c = 'Happy with the offer';
      task.Subject = 'Accepted' + ': ' + 'Happy with the offer';
      task.Description = 'Test delete response';
      task.recordTypeId = CCRMConstants.LEAD_RESPONSE_RT_ID;
      task.WhoId = leads[0].Id;
      task.Response_Type__c = rtAccepted.Id;
      insert task;

      //WHEN the response is deleted
      CCRMTaskActions.preventDelete(new List<Task>{ task });
      Test.stopTest();
    }

    //THEN the delete action will fail
    System.assert(
      task.hasErrors() &&
      task.getErrors()[0]
        .getMessage()
        .contains(CCRMTaskActions.RESPONSE_DELETE_ERROR_MESSAGE),
      'Must not be able to delete response'
    );
  }

  @IsTest
  static void testMLStatusLogResponse() {
    User objUser = [SELECT Id FROM User WHERE LastName = 'MLCRM' LIMIT 1];
    System.runAs(ObjUser) {
      List<Lead> lstOfLead = [
        SELECT Id
        FROM Lead
        WHERE RecordTypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
        LIMIT 1
      ];

      Response_Type__c rtAccepted = [
        SELECT Id, Name, Campaign__c, Response_Status__c, Create_Opportunity__c
        FROM Response_Type__c
        WHERE Response_Status__c = 'Accepted'
        LIMIT 1
      ];
      Test.startTest();
      Task task = new Task();
      task.Response_Status__c = 'Accepted';
      task.Status = CCRMConstants.STATUS_COMPLETED;
      task.Outcome_Reason__c = 'Happy with the offer';
      task.Subject = 'Accepted' + ': ' + 'Happy with the offer';
      task.Description = 'Test delete response';
      task.recordTypeId = CCRMConstants.LEAD_RESPONSE_RT_ID;
      task.WhoId = lstOfLead[0].Id;
      task.Response_Type__c = rtAccepted.Id;
      insert task;
      Test.stopTest();
      List<Lead> lstOfUpdatedLead = [
        SELECT Id, Status
        FROM Lead
        WHERE RecordTypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
        LIMIT 1
      ];
      Assert.areEqual(
        'Opportunity Identified',
        lstOfUpdatedLead[0].status,
        'stage is not opportunity identified!'
      );
    }
  }

  @IsTest
  static void validateLeadExpiryDatePreponed() {
    List<Lead> lstOfLead = new List<Lead>();
    Map<String, Task> mapLeadResponses = new Map<String, Task>();
    Map<Id, Response_Type__c> mapResponseTypeMeta = new Map<Id, Response_Type__c>();
    Map<Id, Date> mapOfCampaign = new Map<Id, Date>();
    Lead leadRecord = new Lead();
    leadRecord.Email = 'sam@test.com';
    leadRecord.RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID;
    leadRecord.Description = 'Need a new Credit Card';
    leadRecord.Expiry_Date__c = System.today() + 10;
    leadRecord.FinServ__ExpressedInterest__c = 'Personal Loan';
    leadRecord.FinServ__PotentialValue__c = 12000;
    leadRecord.FirstName = 'Sam';
    leadRecord.LastName = 'Jacob';
    leadRecord.LeadSource = 'Partner';
    leadRecord.New_to_Bank__c = 'Yes';
    leadRecord.Lead_Originator__c = 'Adobe';
    leadRecord.Business_ID__c = '012345';
    leadRecord.Status = CCRMConstants.STATUS_NEW;
    leadRecord.Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    lstOfLead.add(leadRecord);

    Task task = new Task();
    task.Response_Status__c = 'Accepted';
    task.Status = CCRMConstants.STATUS_COMPLETED;
    task.Outcome_Reason__c = 'Happy with the offer';
    task.Subject = 'Accepted' + ': ' + 'Happy with the offer';
    task.Description = 'Test delete response';
    task.recordTypeId = CCRMConstants.LEAD_RESPONSE_RT_ID;
    task.WhoId = lstOfLead[0].Id;

    mapLeadResponses.put(task.WhoId, task);

    Campaign campaignRecord = new Campaign();
    campaignRecord.Name = 'CRM Manual Leads';
    campaignRecord.Code__c = System.Label.Commercial_DefaultCampaign;
    campaignRecord.Type = 'Targeted Offer';
    campaignRecord.StartDate = System.today();
    campaignRecord.EndDate = campaignRecord.StartDate.addMonths(1);
    campaignRecord.Source__c = 'CCM';
    campaignRecord.Organization__c = 'ANZ Commercial Bank';
    campaignRecord.Description = 'Manual Leads created by bankers in CRM';
    campaignRecord.Id = Lib_FakeIdGenerator.getMockId(Campaign.SObjectType);

    mapOfCampaign.put(campaignRecord.Id, campaignRecord.EndDate);

    Response_Type__c responseTypeRecord1 = new Response_Type__c();
    responseTypeRecord1.Campaign__c = campaignRecord.Id;
    responseTypeRecord1.Name = 'Flex Field Test Data';
    responseTypeRecord1.Display_Order__c = 1;
    responseTypeRecord1.Response_Status__c = 'Accepted';
    responseTypeRecord1.Outcome_Reason__c = 'Happy with the Offer.';
    responseTypeRecord1.Create_Opportunity__c = true;
    responseTypeRecord1.Create_To_Do_Activities__c = true;
    responseTypeRecord1.Follow_Up_State__c = 'R';
    responseTypeRecord1.Is_Active__c = true;
    responseTypeRecord1.UNICA_Lead_SubStatus__c = 'RPC';
    responseTypeRecord1.Id = Lib_FakeIdGenerator.getMockId(
      Response_Type__c.SObjectType
    );

    mapResponseTypeMeta.put(responseTypeRecord1.Id, responseTypeRecord1);

    CCRMTaskActions.calculateExpiryDate(
      lstOfLead,
      mapLeadResponses,
      mapResponseTypeMeta,
      mapOfCampaign
    );
    System.assertEquals(
      leadRecord.Expiry_Date__c,
      lstOfLead[0].Expiry_Date__c,
      'Expiry date cannot be preposned'
    );
  }
}
