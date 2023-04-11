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
  }

  @IsTest
  static void updateCCRMLeadsTest() {
    //GIVEN Campaign and Lead
    Response_Type__c rtAccepted = [
      SELECT Id, Name, Campaign__c, Response_Status__c
      FROM Response_Type__c
      WHERE Response_Status__c = 'Accepted'
      LIMIT 1
    ];

    Response_Type__c rtDeclined = [
      SELECT Id, Name, Campaign__c, Response_Status__c
      FROM Response_Type__c
      WHERE Response_Status__c = 'Customer Declined'
      LIMIT 1
    ];

    List<Lead> updatedLeads = [
      SELECT Id, Name, Status
      FROM Lead
      WHERE Status IN ('New', 'In progress')
    ];

    CCRMLogAResponseController.LeadResponseWrapper leadResponseData1 = new CCRMLogAResponseController.LeadResponseWrapper();
    leadResponseData1.responseStatus = 'Accepted';
    leadResponseData1.outcomeReason = 'Happy with the Offer.';
    leadResponseData1.followUpDate = System.today() + 10;
    leadResponseData1.commentVal = 'Customer is happy with the offer.';
    leadResponseData1.leadId = updatedLeads[0].Id;
    leadResponseData1.responseTypeValue = rtAccepted.Id;
    leadResponseData1.autoCreateActivities = false;

    CCRMLogAResponseController.LeadResponseWrapper leadResponseData2 = new CCRMLogAResponseController.LeadResponseWrapper();
    leadResponseData2.responseStatus = 'Customer Declined';
    leadResponseData2.outcomeReason = 'Competitor offer superior';
    leadResponseData2.commentVal = 'Customer declined.';
    leadResponseData2.followUpDate = null;
    leadResponseData2.leadId = updatedLeads[1].Id;
    leadResponseData2.responseTypeValue = rtDeclined.Id;
    leadResponseData2.autoCreateActivities = false;

    String result = '';
    String result2 = '';

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      //WHEN Response Tasks are Created
      result = CCRMLogAResponseController.createResponseRecord(
        JSON.serialize(leadResponseData1)
      );
      result2 = CCRMLogAResponseController.createResponseRecord(
        JSON.serialize(leadResponseData2)
      );
    }
    Test.stopTest();

    //THEN Owners are notified on Leads getting Expired.
    System.assertEquals(
      String.isNotBlank(result),
      true,
      'CCRM Lead updated based on Logged Response.'
    );

    System.assertEquals(
      String.isNotBlank(result2),
      true,
      'CCRM Lead updated based on Logged Response. - Customer Declined Scenario'
    );
  }

  @IsTest
  static void callBackResponseTest() {
    //GIVEN Campaign and Lead
    Response_Type__c rtCallBack = [
      SELECT Id, Name, Campaign__c, Response_Status__c
      FROM Response_Type__c
      WHERE Response_Status__c = 'Customer Declined'
      LIMIT 1
    ];

    List<Lead> updatedLeads = [
      SELECT Id, Name, Status
      FROM Lead
      WHERE Status IN ('New', 'In progress')
    ];

    CCRMLogAResponseController.LeadResponseWrapper leadResponseData1 = new CCRMLogAResponseController.LeadResponseWrapper();
    leadResponseData1.responseStatus = 'Call Back';
    leadResponseData1.outcomeReason = 'Customer was busy';
    leadResponseData1.followUpDate = System.today() + 2;
    leadResponseData1.commentVal = 'Customer asked me to call the next day';
    leadResponseData1.leadId = updatedLeads[0].Id;
    leadResponseData1.responseTypeValue = rtCallBack.Id;
    leadResponseData1.autoCreateActivities = false;

    CCRMLogAResponseController.LeadResponseWrapper leadResponseData2 = new CCRMLogAResponseController.LeadResponseWrapper();
    leadResponseData2.responseStatus = 'Call Back';
    leadResponseData2.outcomeReason = 'Customer was busy';
    leadResponseData2.followUpDate = System.today() + 3;
    leadResponseData2.commentVal = 'Customer asked me to call the next day';
    leadResponseData2.leadId = updatedLeads[0].Id;
    leadResponseData2.responseTypeValue = rtCallBack.Id;
    leadResponseData2.autoCreateActivities = false;

    String result = '';
    String result2 = '';

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      //WHEN Response Tasks are Created
      result = CCRMLogAResponseController.createResponseRecord(
        JSON.serialize(leadResponseData1)
      );
      result2 = CCRMLogAResponseController.createResponseRecord(
        JSON.serialize(leadResponseData2)
      );
    }
    Test.stopTest();

    //THEN Owners are notified on Leads getting Expired.
    System.assertEquals(
      String.isNotBlank(result),
      true,
      'CCRM Lead updated based on Logged Response.'
    );

    System.assertEquals(
      String.isNotBlank(result2),
      true,
      'CCRM Lead updated based on Logged Response. - Customer Declined Scenario'
    );
  }

  @IsTest
  static void responseStatusDependentValuesTest() {
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      //GIVEN Campaign and Lead
      Response_Type__c responseTypeRecord = [
        SELECT Id, Name, Campaign__c, Response_Status__c
        FROM Response_Type__c
        WHERE Response_Status__c = 'Accepted'
        LIMIT 1
      ];
      List<Lead> updatedLeads = new List<Lead>();
      for (Lead leadRecord : [
        SELECT Id, Name, Status
        FROM Lead
        WHERE Status IN ('New', 'In progress')
      ]) {
        updatedLeads.add(leadRecord);
      }
      CCRMTestDataFactory.createCampaignMemberRecord(
        updatedLeads,
        responseTypeRecord.Campaign__c
      );

      String result = '';

      Test.startTest();
      //WHEN Campaign is linked to Lead
      result = CCRMLogAResponseController.responseStatusDependentValues(
        updatedLeads[0].Id
      );
      Test.stopTest();

      //THEN Owners are notified on Leads getting Expired.
      System.assertEquals(
        String.isNotBlank(result),
        true,
        'CCRM Lead updated based on Logged Response.'
      );
    }
  }

  @isTest
  static void testExpiryDateLogResponseAddedWithoutFollowupDate() {
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
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
      Test.startTest();
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
      Lead[] updatedlead = [SELECT Id, Expiry_Date__c FROM Lead where Id=:leads];
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

      Test.startTest();
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
}
