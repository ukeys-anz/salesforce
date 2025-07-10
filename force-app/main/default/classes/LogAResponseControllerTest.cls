/**
 * @author Ashwin Mohan
 * @since May 2025
 * @description Test class for LogAResponseController class
 */
@isTest
public class LogAResponseControllerTest {
  static Lib_MockProvider logAResponseRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    logAResponseRepoMock = Lib_MockProvider.forType(
      LogAResponseRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testGetLeadResponseGuidanceMappingCCRM() {
    registerMocks();
    Lead leadRecord = getCommercialLeadRecord();
    logAResponseRepoMock.mock(
      new Map<String, Object>{
        'getLeadInstance' => leadRecord,
        'getLeadStageAutomationMetadata' => getLeadStageAutomationMdt(),
        'getLeadResponseConvGuide' => getLeadResponseCovGuideMdt()
      }
    );
    Test.startTest();
    String output = LogAResponseController.getLeadResponseGuidanceMapping(
      leadRecord.Id
    );
    Test.stopTest();
    LogAResponseController.LeadGuidance leadGuidanceWrapper = (LogAResponseController.LeadGuidance) JSON.deserialize(
      output,
      LogAResponseController.LeadGuidance.class
    );
    Assert.areEqual(
      'https://campaignlead.com',
      leadGuidanceWrapper.campaignLeadsLink,
      'Campaign Leads link is not populated'
    );
    Assert.areEqual(
      'https://dummylink.com',
      leadGuidanceWrapper.customerConversationGuideLink,
      'Conversation guide link is not populated'
    );
    Assert.isNotNull(
      leadGuidanceWrapper.mapOfLeadStatusReasonAndNextDetail,
      'Map of Lead Status is not populated'
    );
  }

  @isTest
  static void testGetLeadResponseGuidanceMappingML() {
    registerMocks();
    Lead leadRecord = getMobileLendingLeadRecord();
    logAResponseRepoMock.mock(
      new Map<String, Object>{
        'getLeadInstance' => leadRecord,
        'getLeadStageAutomationMetadata' => new List<Lead_Stage_Automation__mdt>(),
        'getLeadResponseConvGuide' => new List<DCRM_Lead_Response_Conversation_Guide__mdt>{
          getLeadResponseCovGuideMdt()[1]
        }
      }
    );
    Test.startTest();
    String output = LogAResponseController.getLeadResponseGuidanceMapping(
      leadRecord.Id
    );
    Test.stopTest();
    LogAResponseController.LeadGuidance leadGuidanceWrapper = (LogAResponseController.LeadGuidance) JSON.deserialize(
      output,
      LogAResponseController.LeadGuidance.class
    );
    Assert.areEqual(
      'https://campaignleadmlcrm.com',
      leadGuidanceWrapper.campaignLeadsLink,
      'Campaign Leads link is not populated'
    );
    Assert.areEqual(
      'https://dummylinkmlcrm.com',
      leadGuidanceWrapper.customerConversationGuideLink,
      'Conversation guide link is not populated'
    );
    Assert.isTrue(
      leadGuidanceWrapper.mapOfLeadStatusReasonAndNextDetail.isEmpty(),
      'Map of Lead Status is getting populated'
    );
  }

  @istest
  static void testResponseStatusDependentValues() {
    registerMocks();
    Lead leadRecord = getCommercialLeadRecord();
    logAResponseRepoMock.mock(
      new Map<String, Object>{
        'getCampaignMemberRecord' => getCampaingMemberRecord(leadRecord),
        'getResponseTypeRecords' => new List<Response_Type__c>{
          new Response_Type__c(
            Response_Status__c = 'Accepted',
            Outcome_Reason__c = 'Appointment Made'
          ),
          new Response_Type__c(
            Response_Status__c = 'Accepted',
            Outcome_Reason__c = 'Referral made'
          ),
          new Response_Type__c(
            Response_Status__c = 'Referral Made',
            Outcome_Reason__c = 'Other referral made'
          )
        }
      }
    );
    Test.startTest();
    String output = LogAResponseController.responseStatusDependentValues(
      leadRecord.Id
    );
    Test.stopTest();
    Map<String, List<Response_Type__c>> responseStatusWrapper = (Map<String, List<Response_Type__c>>) JSON.deserialize(
      output,
      Map<String, List<Response_Type__c>>.class
    );
    Assert.areEqual(
      2,
      responseStatusWrapper.get('Accepted').size(),
      'Response type map is not created correctly'
    );
  }

  @isTest
  static void testCreateResponseRecordCCRM() {
    registerMocks();
    Lead leadRecord = getCommercialLeadRecord();

    LogAResponseController.LeadResponseWrapper leadResponseData = new LogAResponseController.LeadResponseWrapper();
    leadResponseData.responseStatus = 'Accepted';
    leadResponseData.outcomeReason = 'Happy with the Offer.';
    leadResponseData.followUpDate = System.today() + 10;
    leadResponseData.commentVal = 'Customer is happy with the offer.';
    leadResponseData.leadId = leadRecord.Id;
    leadResponseData.responseTypeValue = Lib_FakeIdGenerator.getMockId(
      Schema.Response_Type__c.getSObjectType()
    );
    leadResponseData.autoCreateActivities = false;

    logAResponseRepoMock.mock(
      new Map<String, Object>{
        'getLeadInstance' => leadRecord,
        'getLeadStageAutomationMetadata' => new List<Lead_Stage_Automation__mdt>{},
        'getCampaignMemberRecord' => getCampaingMemberRecord(leadRecord)
      }
    );
    Test.startTest();
    String output = LogAResponseController.createResponseRecord(
      JSON.serialize(leadResponseData)
    );
    Test.stopTest();
    Task taskInserted = (Task) dmlRepoMock.getHistory('doInsert')
      .getParam('record');
    ResponseCapturedDataWrapper responseWrapper = (ResponseCapturedDataWrapper) JSON.deserialize(
      output,
      ResponseCapturedDataWrapper.class
    );
    Assert.areEqual(
      true,
      responseWrapper.isCampaignEndDateMax,
      ' The campaign end date is not max date'
    );
    Assert.areEqual('Completed', taskInserted.Status, 'Task is not inserted');
  }

  @isTest
  static void testCreateResponseRecordMLCRM() {
    registerMocks();
    Lead leadRecord = getMobileLendingLeadRecord();

    LogAResponseController.LeadResponseWrapper leadResponseData = new LogAResponseController.LeadResponseWrapper();
    leadResponseData.responseStatus = 'Accepted';
    leadResponseData.outcomeReason = 'Happy with the Offer.';
    leadResponseData.followUpDate = System.today() + 10;
    leadResponseData.commentVal = 'Customer is happy with the offer.';
    leadResponseData.leadId = leadRecord.Id;
    leadResponseData.responseTypeValue = Lib_FakeIdGenerator.getMockId(
      Schema.Response_Type__c.getSObjectType()
    );
    leadResponseData.autoCreateActivities = false;

    logAResponseRepoMock.mock(
      new Map<String, Object>{
        'getLeadInstance' => leadRecord,
        'getLeadStageAutomationMetadata' => new List<Lead_Stage_Automation__mdt>{},
        'getCampaignMemberRecord' => getCampaingMemberRecord(leadRecord)
      }
    );
    Test.startTest();
    String output = LogAResponseController.createResponseRecord(
      JSON.serialize(leadResponseData)
    );
    Test.stopTest();
    Task taskInserted = (Task) dmlRepoMock.getHistory('doInsert')
      .getParam('record');
    ResponseCapturedDataWrapper responseWrapper = (ResponseCapturedDataWrapper) JSON.deserialize(
      output,
      ResponseCapturedDataWrapper.class
    );
    Assert.areEqual(
      true,
      responseWrapper.isCampaignEndDateMax,
      ' The campaign end date is not max date'
    );
    Assert.areEqual(
      leadResponseData.followUpDate,
      taskInserted.ActivityDate,
      'Follow up date is not stamped as ActivityDate for Task created for ML lead'
    );
    Assert.areEqual('Completed', taskInserted.Status, 'Task is not inserted');
  }

  static List<Lead_Stage_Automation__mdt> getLeadStageAutomationMdt() {
    return new List<Lead_Stage_Automation__mdt>{
      new Lead_Stage_Automation__mdt(
        Response_Status__c = 'Accepted',
        Response_Type_CreateOpportunity__c = 'false',
        isActive__c = true,
        What_happens_next__c = 'Dummy Text',
        Lead_Record_Type__c = 'CCRM_Lead',
        Lead_Status__c = 'Assigned,In progress'
      ),
      new Lead_Stage_Automation__mdt(
        Response_Status__c = 'Contact Attempted',
        Response_Type_CreateOpportunity__c = null,
        isActive__c = true,
        What_happens_next__c = 'Dummy Text',
        Lead_Record_Type__c = 'CCRM_Lead',
        Lead_Status__c = 'Assigned,In progress'
      )
    };
  }

  static List<DCRM_Lead_Response_Conversation_Guide__mdt> getLeadResponseCovGuideMdt() {
    return new List<DCRM_Lead_Response_Conversation_Guide__mdt>{
      new DCRM_Lead_Response_Conversation_Guide__mdt(
        Profile__c = 'ANZ CCRM Standard User',
        User_Role__c = 'SME Assistant Manager',
        Campaign_Lead_URL__c = 'https://campaignlead.com',
        Conversation_Guide_URL__c = 'https://dummylink.com'
      ),
      new DCRM_Lead_Response_Conversation_Guide__mdt(
        Profile__c = 'ANZ ML Standard User',
        User_Role__c = 'ANZ Mobile Lending Support Team,ANZ Mobile Lending Team,Mobile Lending Franchise Users',
        Campaign_Lead_URL__c = 'https://campaignleadmlcrm.com',
        Conversation_Guide_URL__c = 'https://dummylinkmlcrm.com'
      )
    };
  }

  static Lead getCommercialLeadRecord() {
    return (Lead) TestUtil.setFields(
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
        RecordType = new RecordType(DeveloperName = 'CCRM_Lead'),
        Status = 'In Progress',
        FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
          Schema.Account.getSObjectType()
        ),
        FinServ__ExpressedInterest__c = 'Purchasing Vacant Land',
        ABN__c = '99 083 344 334',
        ACN__c = '083 344 334',
        ABN_Validation_Status__c = 'Active',
        ACN_Validation_Status__c = 'Active',
        RecordTypeId = RTLead.commercialLead
      ),
      new Map<String, Object>{
        'Name' => 'Test CCRM Lead',
        'Owner' => new User(
          Profile = new Profile(Name = 'ANZ CCRM Standard User'),
          UserRole = new UserRole(Name = 'SME Assistant Manager')
        )
      }
    );
  }

  static Lead getMobileLendingLeadRecord() {
    return (Lead) TestUtil.setFields(
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
        RecordType = new RecordType(DeveloperName = 'MLCRM_Lead'),
        Status = 'In Progress',
        FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
          Schema.Account.getSObjectType()
        ),
        RecordTypeId = RTLead.mlcrmLead
      ),
      new Map<String, Object>{
        'Name' => 'Test MLCRM Lead',
        'Owner' => new User(
          Profile = new Profile(Name = 'ANZ ML Standard User'),
          UserRole = new UserRole(Name = 'Mobile Lending Franchise User')
        )
      }
    );
  }

  static CampaignMember getCampaingMemberRecord(Lead leadRecord) {
    return new CampaignMember(
      Id = Lib_FakeIdGenerator.getMockId(
        Schema.CampaignMember.getSObjectType()
      ),
      LeadId = leadRecord.Id,
      CampaignId = Lib_FakeIdGenerator.getMockId(
        Schema.Campaign.getSObjectType()
      ),
      Campaign = new Campaign(EndDate = System.today().addDays(5)),
      Lead = new Lead(Expiry_Date__c = System.today().addDays(5))
    );
  }
}
