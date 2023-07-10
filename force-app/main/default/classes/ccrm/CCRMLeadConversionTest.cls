/**
 * @author Emmanuel Yap
 * @since  03/2022
 * @description Test class for CCRM Lead Conversion Class.
 */
@IsTest
public class CCRMLeadConversionTest {
  // Public Declaration

  @TestSetup
  static void setup() {
    User ccrmUser = CCRMTestDataFactory.createCCRMBaseUser();
    CCRMTestDataFactory.createAdminUser();
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
  static void leadConversionTest() {
    //GIVEN Campaign and Lead
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
        FinServ__ExpressedInterest__c,
        FinServ__PotentialValue__c,
        OwnerId,
        Description
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
    leadResponseData1.autoCreateActivities = false;

    String result = '';

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      CCRMTestDataFactory.createCampaignMemberRecord(
        updatedLeads,
        rtAccepted.Campaign__c
      );

      //WHEN Response Tasks are Created
      result = CCRMLogAResponseController.createResponseRecord(
        JSON.serialize(leadResponseData1)
      );
      CCRMLeadConversion.getLeadRecordForConversion(updatedLeads[0].Id);
      /*
      Id oppId = CCRMLeadConversion.convertLead(
        updatedLeads[0].Id,
        updatedLeads[0].FinServ__RelatedAccount__c
      );
*/

      /*
      opps = [
        SELECT
          Name,
          Description,
          Amount,
          OwnerId,
          CampaignId,
          StageName,
          AccountId,
          Opp_Id__c,
          Account.Name
        FROM Opportunity
        WHERE Id = :oppId
      ];
*/
    }

    Test.stopTest();

    //THEN Owners are notified on Leads getting Expired.
    /*
    System.assertEquals(!opps.isEmpty(), true, 'CCRM Opportunity Created');
    System.assertEquals(
      opps[0].Description,
      updatedLeads[0].Description,
      'Opportunity created with same Desciption as Lead'
    );
    System.assertEquals(
      opps[0].OwnerID,
      updatedLeads[0].OwnerID,
      'Opportunity created with same Owner as Lead'
    );
    System.assertEquals(
      opps[0].CampaignId,
      rtAccepted.Campaign__c,
      'Opportunity created with same Campaign as Lead'
    );
    System.assertEquals(
      opps[0].StageName,
      'Opportunity Identified',
      'Opportunity created with Stage - Opportunity Identified'
    );
    System.assertEquals(
      opps[0].Amount,
      updatedLeads[0].FinServ__PotentialValue__c,
      'Opportunity created with same Amount as Lead'
    );
    System.assertEquals(
      opps[0].Name,
      opps[0].Opp_Id__c +
      ' ' +
      opps[0].Account.Name,
      'Opportunity Name is Opp Id and Customer Name'
    );
*/
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
    leadResponseData1.autoCreateActivities = false;

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
