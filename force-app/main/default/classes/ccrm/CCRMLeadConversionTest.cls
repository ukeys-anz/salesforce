/**
 * @author Emmanuel Yap
 * @since  03/2022
 * @description Test class for CCRM Lead Conversion Class.
 */
@IsTest
public with sharing class CCRMLeadConversionTest {
  // Public Declaration

  @TestSetup
  static void setup() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    User adminUser = CCRMTestDataFactory.createAdminUser();
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
      List<Response_Type__C> responseTypeRecords = CCRMTestDataFactory.createResponseTypeRecords(
        campaignRecord[0]
      );
    }
  }

  @IsTest
  static void leadConversionTest() {
    //GIVEN Campaign and Lead
    List<Response_Type__C> types = [
      SELECT Id, Name, Campaign__c, Response_Status__c
      FROM Response_Type__c
    ];

    Response_Type__c rtAccepted = [
      SELECT Id, Name, Campaign__c, Response_Status__c
      FROM Response_Type__c
      WHERE Response_Status__c = 'Accepted'
      LIMIT 1
    ];

    List<Lead> updatedLeads = [
      SELECT
        Id,
        Name,
        Status,
        FinServ__RelatedAccount__c,
        FinServ__RelatedAccount__r.Name,
        FinServ__ExpressedInterest__c
      FROM Lead
      WHERE FinServ__RelatedAccount__c != NULL
    ];

    CCRMLogAResponseController.LeadResponseWrapper leadResponseData1 = new CCRMLogAResponseController.LeadResponseWrapper();
    leadResponseData1.responseStatus = 'Accepted';
    leadResponseData1.outcomeReason = 'Happy with the Offer.';
    leadResponseData1.followUpDate = System.today() + 10;
    leadResponseData1.commentVal = 'Customer is happy with the offer.';
    leadResponseData1.leadId = updatedLeads[0].Id;
    leadResponseData1.responseTypeValue = rtAccepted.Id;

    String result = '';
    List<Opportunity> opps;

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      //WHEN Response Tasks are Created
      result = CCRMLogAResponseController.createResponseRecord(
        JSON.serialize(leadResponseData1)
      );
      CCRMLeadConversion.getLeadRecordForConversion(updatedLeads[0].Id);
/*
      CCRMLeadConversion.convertLead(
        updatedLeads[0].Id,
        updatedLeads[0].FinServ__RelatedAccount__c
      );
*/
      String oppName =
        updatedLeads[0].FinServ__RelatedAccount__r.Name +
        ' ' +
        updatedLeads[0].FinServ__ExpressedInterest__c +
        ' ' +
        date.today().format();
      opps = [SELECT Name, AccountId FROM Opportunity WHERE Name = :oppName];
    }
    Test.stopTest();

    //THEN Owners are notified on Leads getting Expired.
//    System.assertEquals(!opps.isEmpty(), true, 'CCRM Opportunity Created');
  }

  @IsTest
  static void leadConversionTestNonEditableLeadStages() {
    List<Lead> leads = [SELECT Id FROM Lead];
    CCRMLogAResponseController.LeadResponseWrapper leadResponseData1 = new CCRMLogAResponseController.LeadResponseWrapper();
    leadResponseData1.leadId = leads[0].Id;

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      update new Lead(Id = leads[0].Id, Status = CCRMConstants.STATUS_EXPIRED);
    }

    String result;
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      result = CCRMLogAResponseController.createResponseRecord(
        JSON.serialize(leadResponseData1)
      );
    }
    Test.stopTest();

    System.assert(
      !String.isBlank(result) &&
      result.contains('Responses cannot be logged for Leads'),
      'Should show error for lead with non-editable stages'
    );
  }

  @IsTest
  static void leadConversionTestAbnNotValidated() {
    List<Lead> leads = [SELECT Id FROM Lead];
    Response_Type__c rtAccepted = [
      SELECT Id
      FROM Response_Type__c
      WHERE Response_Status__c = 'Accepted'
      LIMIT 1
    ];
    CCRMLogAResponseController.LeadResponseWrapper leadResponseData1 = new CCRMLogAResponseController.LeadResponseWrapper();
    leadResponseData1.responseStatus = 'Accepted';
    leadResponseData1.outcomeReason = 'Happy with the Offer.';
    leadResponseData1.followUpDate = System.today() + 10;
    leadResponseData1.commentVal = 'Customer is happy with the offer.';
    leadResponseData1.leadId = leads[0].Id;
    leadResponseData1.responseTypeValue = rtAccepted.Id;

    String result;
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      update new Lead(
        Id = leads[0].Id,
        ABN__c = '51 824 753 556',
        ABN_Validation_Status__c = CCRMConstants.ABN_ACN_STATUS_FAILED
      );
      result = CCRMLogAResponseController.createResponseRecord(
        JSON.serialize(leadResponseData1)
      );
    }
    Test.stopTest();

    System.assert(
      !result.contains('Error Message'),
      'Should not show error message'
    );
  }
}
