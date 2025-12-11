@isTest
public with sharing class LeadResponseTaskActionsTest {
  private static List<Lead_Stage_Automation__mdt> leadStageAutomationMetadata = Lead_Stage_Automation__mdt.getAll()
    .values();
  static Lib_MockProvider taskRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    taskRepoMock = Lib_MockProvider.forType(TaskActionRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testUpdateLeadsBasisLogResponse() {
    registerMocks();
    Lead leadRecord = getLeadRecord();
    List<Response_Type__c> respTypeRecords = getResponseTypeRecords();
    Task leadResponseTask = getLeadResponseTask(leadRecord, respTypeRecords[0]);
    taskRepoMock.mock(
      new Map<String, Object>{
        'getResponseTypeData' => respTypeRecords,
        'getLeadRecords' => new List<Lead>{ leadRecord },
        'getCampaignMemberRecords' => new List<CampaignMember>{
          getCampaignMemberRecord(leadRecord, 2)
        }
      }
    );
    Test.startTest();
    LeadResponseTaskActions.updateLeadsBasisLogResponse(
      new List<Task>{ leadResponseTask }
    );
    Test.stopTest();
    List<Lead> updatedLeads = (List<Lead>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    List<Lead_Stage_Automation__mdt> leadStageMdt = ListUtil.filter(
        leadStageAutomationMetadata
      )
      .equals(Lead_Stage_Automation__mdt.Lead_Record_Type__c, 'CCRM_Lead')
      .equals(Lead_Stage_Automation__mdt.Response_Status__c, 'Accepted')
      .contains(Lead_Stage_Automation__mdt.Lead_Status__c, 'In progress')
      .equals(
        Lead_Stage_Automation__mdt.Response_Type_CreateOpportunity__c,
        'true'
      )
      .toList();
    Assert.areEqual(
      leadStageMdt[0].Next_Lead_Status__c,
      updatedLeads[0].Status,
      'Status field is not updated'
    );
    Assert.areEqual(
      leadStageMdt[0].Outcome_Type__c,
      updatedLeads[0].Lead_Outcome__c,
      'Lead Outcome field is not updated'
    );
    Assert.areEqual(
      'Validate',
      updatedLeads[0].Skip_Validations__c,
      'Skip Validations field is not updated'
    );
    Assert.areEqual(
      leadStageMdt[0].Response_Status__c,
      updatedLeads[0].SubStatus__c,
      'Sub Status field is not updated'
    );
    Assert.areEqual(
      leadResponseTask.Lead_Quality__c,
      updatedLeads[0].Lead_Quality__c,
      'Lead quality field is not updated'
    );
    Assert.areEqual(
      System.today().addDays(2),
      updatedLeads[0].Expiry_Date__c,
      'Expiry date field is not updated'
    );
    Assert.areEqual(
      null,
      updatedLeads[0].Followup_Date__c,
      'Follow up date field is not marked as null'
    );
  }

  @isTest
  static void testPopulateLeadDetails() {
    registerMocks();
    Lead leadRecord = getLeadRecord();
    List<Response_Type__c> respTypeRecords = getResponseTypeRecords();
    Task leadResponseTask = getLeadResponseTask(leadRecord, respTypeRecords[0]);
    Test.startTest();
    List<Lead> updatedLeads = LeadResponseTaskActions.populateLeadDetails(
      new List<Lead>{ leadRecord },
      new Map<Id, Task>{ leadResponseTask.WhoId => leadResponseTask },
      new Map<Id, Response_Type__c>{
        respTypeRecords[0].Id => respTypeRecords[0],
        respTypeRecords[0].Id => respTypeRecords[0]
      }
    );
    Test.stopTest();
    List<Lead_Stage_Automation__mdt> leadStageMdt = ListUtil.filter(
        leadStageAutomationMetadata
      )
      .equals(Lead_Stage_Automation__mdt.Lead_Record_Type__c, 'CCRM_Lead')
      .equals(Lead_Stage_Automation__mdt.Response_Status__c, 'Accepted')
      .contains(Lead_Stage_Automation__mdt.Lead_Status__c, 'In progress')
      .equals(
        Lead_Stage_Automation__mdt.Response_Type_CreateOpportunity__c,
        'true'
      )
      .toList();
    Assert.areEqual(
      leadStageMdt[0].Next_Lead_Status__c,
      updatedLeads[0].Status,
      'Status field is not updated'
    );
    Assert.areEqual(
      leadStageMdt[0].Outcome_Type__c,
      updatedLeads[0].Lead_Outcome__c,
      'Lead Outcome field is not updated'
    );
    Assert.areEqual(
      'Validate',
      updatedLeads[0].Skip_Validations__c,
      'Skip Validations field is not updated'
    );
    Assert.areEqual(
      leadStageMdt[0].Response_Status__c,
      updatedLeads[0].SubStatus__c,
      'Sub Status field is not updated'
    );
    Assert.areEqual(
      leadResponseTask.Lead_Quality__c,
      updatedLeads[0].Lead_Quality__c,
      'Lead quality field is not updated'
    );
    Assert.areEqual(
      leadResponseTask.ActivityDate,
      updatedLeads[0].Followup_Date__c,
      'Follow up date field is not marked as null'
    );
  }

  @isTest
  static void testSetExpiryDateFromLogResponse() {
    registerMocks();
    Lead leadRecord = getLeadRecord();
    List<Response_Type__c> respTypeRecords = getResponseTypeRecords();
    Task leadResponseTask = getLeadResponseTask(leadRecord, respTypeRecords[0]);
    taskRepoMock.mock(
      new Map<String, Object>{
        'getCampaignMemberRecords' => new List<CampaignMember>{
          getCampaignMemberRecord(leadRecord, 60)
        }
      }
    );
    Test.startTest();
    LeadResponseTaskActions.setExpiryDateFromLogResponse(
      new Map<Id, Task>{ leadResponseTask.WhoId => leadResponseTask },
      new Map<Id, Response_Type__c>{
        respTypeRecords[0].Id => respTypeRecords[0],
        respTypeRecords[0].Id => respTypeRecords[0]
      },
      new List<Lead>{ leadRecord }
    );
    Test.stopTest();
    Integer extendLeadExpiryDate = Integer.valueOf(
      System.Label.CommercialExtendLeadExpiryDateForLogResponse
    );
    Integer extendTodaysDate = Integer.valueOf(
      System.Label.CommercialExtendTodaysDate
    );
    Assert.areEqual(
      DateTimeUtils.getNextWeekdayDate(extendTodaysDate + extendLeadExpiryDate),
      leadRecord.Expiry_Date__c,
      'Expiry date field is not correctly updated'
    );
    Assert.areEqual(
      null,
      leadRecord.Followup_Date__c,
      'Follow up date field is not marked as null'
    );
  }

  @isTest
  static void testValidateLeadABNACN() {
    registerMocks();
    Lead leadRecord = getLeadRecord();
    List<Response_Type__c> respTypeRecords = getResponseTypeRecords();
    Task leadResponseTask = getLeadResponseTask(leadRecord, respTypeRecords[0]);
    leadResponseTask.Response_Status__c = 'Referral Made';
    taskRepoMock.mock(
      new Map<String, Object>{
        'getLeadRecordsWithABNACN' => new List<Lead>{ leadRecord }
      }
    );
    Test.startTest();
    LeadResponseTaskActions.validateLeadABNACN(
      new List<Task>{ leadResponseTask }
    );
    Test.stopTest();
    Assert.areEqual(
      LeadResponseTaskActions.ABN_ACN_VALIDATION_MESSAGE,
      leadResponseTask.getErrors()[0].getMessage(),
      'ABN ACN error message not received'
    );
  }

  @isTest
  static void testPreventDelete() {
    Task leadResponseTask = new Task(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Task.getSObjectType()),
      RecordTypeId = RTTask.leadResponse
    );
    Test.startTest();
    LeadResponseTaskActions.preventDelete(new List<Task>{ leadResponseTask });
    Test.stopTest();
    Assert.areEqual(
      LeadResponseTaskActions.RESPONSE_DELETE_ERROR_MESSAGE,
      leadResponseTask.getErrors()[0].getMessage(),
      'Delete error message not received'
    );
  }

  static List<Lead_Stage_Automation__mdt> getLeadStageAutomationMdt() {
    return new List<Lead_Stage_Automation__mdt>{
      new Lead_Stage_Automation__mdt(
        Response_Status__c = 'Accepted',
        Response_Type_CreateOpportunity__c = 'true',
        isActive__c = true,
        What_happens_next__c = 'Dummy Text',
        Lead_Record_Type__c = 'CCRM_Lead',
        Lead_Status__c = 'Assigned,In progress',
        Next_Lead_Status__c = 'Outcome',
        Outcome_Type__c = 'No Opportunity'
      ),
      new Lead_Stage_Automation__mdt(
        Response_Status__c = 'Contact Attempted',
        Response_Type_CreateOpportunity__c = null,
        isActive__c = true,
        What_happens_next__c = 'Dummy Text',
        Lead_Record_Type__c = 'CCRM_Lead',
        Lead_Status__c = 'Assigned,In progress',
        Next_Lead_Status__c = 'In progress',
        Outcome_Type__c = 'Opportunity Identified'
      )
    };
  }

  static List<Response_Type__c> getResponseTypeRecords() {
    return new List<Response_Type__c>{
      new Response_Type__c(
        Id = Lib_FakeIdGenerator.getMockId(
          Schema.Response_Type__c.getSObjectType()
        ),
        Response_Status__c = 'Accepted',
        Create_Opportunity__c = true
      ),
      new Response_Type__c(
        Id = Lib_FakeIdGenerator.getMockId(
          Schema.Response_Type__c.getSObjectType()
        ),
        Response_Status__c = 'Contact Attempted',
        Create_Opportunity__c = true
      )
    };
  }

  static Lead getLeadRecord() {
    return new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      RecordType = new RecordType(DeveloperName = 'CCRM_Lead'),
      Status = 'In progress',
      FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
        Schema.Account.getSObjectType()
      ),
      RecordTypeId = RTLead.commercialLead,
      Followup_Date__c = System.today().addDays(3),
      Skip_Validations__c = 'SkipValidation',
      ABN__c = '10918',
      ABN_Validation_Status__c = 'Cancelled'
    );
  }

  static Task getLeadResponseTask(
    Lead leadRecord,
    Response_Type__c respTypeRecord
  ) {
    return new Task(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Task.getSObjectType()),
      RecordTypeId = RTTask.leadResponse,
      WhoId = leadRecord.Id,
      Response_Type__c = respTypeRecord.Id,
      Response_Status__c = 'Accepted',
      Lead_Quality__c = 'Good'
    );
  }

  static CampaignMember getCampaignMemberRecord(
    Lead leadRecord,
    Integer endDateExtend
  ) {
    return new CampaignMember(
      Id = Lib_FakeIdGenerator.getMockId(
        Schema.CampaignMember.getSObjectType()
      ),
      LeadId = leadRecord.Id,
      CampaignId = Lib_FakeIdGenerator.getMockId(
        Schema.Campaign.getSObjectType()
      ),
      Campaign = new Campaign(EndDate = System.today().addDays(endDateExtend))
    );
  }
}
