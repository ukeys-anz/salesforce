/*
 * @author Pragya Awasthi
 * @since  08/2025
 * @description test class for MobileLendingLeadTriggerHandler
 */
@isTest
public class MobileLendingLeadTriggerHandlerTest {
  static Lib_MockProvider leadMockProvider;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userActionsRepositoryMock;
  static Id campaignId = Lib_FakeIdGenerator.getMockId(
    Schema.Campaign.getSObjectType()
  );

  static void registerMocks() {
    leadMockProvider = Lib_MockProvider.forType(LeadActionsRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    userActionsRepositoryMock = Lib_MockProvider.forType(
      UserActionsRepository.class
    );
  }

  static Lead getMLCRMLead() {
    return new Lead(
      RecordTypeId = RTLead.mlcrmLead,
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Description = 'A sample text with Passport12345678',
      Status = 'New',
      Skip_Validations__c = '',
      OwnerId = UserInfo.getUserId(),
      Campaign_Code__c = 'IKCMP-1670',
      Territory__c = null
    );
  }

  @isTest
  static void testIsValidRecord() {
    Lead newLead = getMLCRMLead();
    Test.startTest();
    MobileLendingLeadTriggerHandler handler = new MobileLendingLeadTriggerHandler();
    Boolean output = handler.isValidRecord(newLead);
    Test.stopTest();
    Assert.isTrue(output, 'Lead is not of MLCRM recordtype');
  }

  @isTest
  static void testonApplyDefaults() {
    Lead leadrecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Expiry_Date__c = null,
      Lead_Originator__c = MobileLendingLeadActions.LEAD_ORIGINATOR_LENDER_ENGAGE,
      RecordTypeId = RTLead.mlcrmLead
    );
    Test.startTest();
    MobileLendingLeadTriggerHandler handler = new MobileLendingLeadTriggerHandler();
    handler.records = new List<Lead>{ leadrecord };
    handler.onApplyDefaults();
    Test.stopTest();
    String dayName = DateTimeUtils.getDay(
      System.today()
        .addDays(Integer.valueOf(System.Label.DefaultAEMLeadExpiryDate))
    );
    switch on dayName {
      when 'Sat' {
        Assert.areEqual(
          System.today()
            .addDays(
              Integer.valueOf(System.Label.DefaultAEMLeadExpiryDate) + 2
            ),
          leadrecord.Expiry_Date__c,
          'Expiry_Date__c is not getting populated correctly when day is Saturday'
        );
      }
      when 'Sun' {
        Assert.areEqual(
          System.today()
            .addDays(
              Integer.valueOf(System.Label.DefaultAEMLeadExpiryDate) + 1
            ),
          leadrecord.Expiry_Date__c,
          'Expiry_Date__c is not getting populated correctly when day is Sunday'
        );
      }
      when else {
        Assert.areEqual(
          System.today()
            .addDays(Integer.valueOf(System.Label.DefaultAEMLeadExpiryDate)),
          leadrecord.Expiry_Date__c,
          'For Monday to Friday Expiry Date is not getting populated correctly'
        );
      }
    }
  }

  @isTest
  static void testBeforeInsert() {
    registerMocks();
    Lead newLead = getMLCRMLead();
    newLead.Lead_Originator__c = 'Adobe';
    Account testAccount = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Account.getSObjectType()),
      Name = 'Test Account',
      Source_System_Name__c = 'CAP-CIS',
      Source_System_ID__c = '4025663541'
    );
    //mocking
    leadMockProvider.mock(
      'getCampaignRecords',
      new List<Campaign>{
        new Campaign(Code__c = 'IKCMP-1670', Id = campaignId)
      }
    );
    leadMockProvider.mock(
      'getRelatedAccounts',
      new List<Account>{ testAccount }
    );
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    userActionsRepositoryMock.mock('isIntegrationUser', true);
    userActionsRepositoryMock.mock(
      'getUserMapFromUserIds',
      new Map<Id, User>{
        userId => new User(id = userId, Lan_Id__c = 'test123')
      }
    );

    Test.startTest();
    MobileLendingLeadTriggerHandler handler = new MobileLendingLeadTriggerHandler();
    handler.records = new List<Lead>{ newLead };
    handler.onBeforeInsert();
    Test.stopTest();
    //test maskSObjectDataANZExtended
    Assert.areEqual(
      'A sample text with Passport****5678',
      newLead.Description,
      'Keyword entered in Description should be masked'
    );
  }

  @isTest
  static void testBeforeUpdate() {
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id territoryId = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    registerMocks();

    Lead oldLead = getMLCRMLead();
    oldLead.Id = leadId;
    oldLead.Territory__c = territoryId;
    //update lead values
    Lead newLead = getMLCRMLead();
    newLead.Id = leadId;
    newLead.Status = 'In progress';
    newLead.Description = 'DL-22222222, CC - 1234567812345678, PP- PA112222233';
    newLead.Territory__c = territoryId;
    Map<Id, Lead> oldMap = new Map<Id, Lead>{ oldLead.Id => oldLead };
    //mocking
    userActionsRepositoryMock.mock('isIntegrationUser', true);
    Test.startTest();
    MobileLendingLeadTriggerHandler handler = new MobileLendingLeadTriggerHandler();
    handler.records = new List<Lead>{ newLead };
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();
    //test maskSObjectDataANZExtended
    Assert.areEqual(
      'DL-****2222, CC - ************5678, PP- PA*****2233',
      newLead.Description,
      'Keyword entered in Description should be masked'
    );
  }
  @isTest
  static void testAfterInsert() {
    registerMocks();
    Lead leadRecord = getMLCRMLead();
    leadRecord = (Lead) TestUtil.setFields(
      leadRecord,
      new Map<String, Object>{
        'Lead_Auto_Number__c' => '00006397',
        'Lead_Id__c' => '',
        'OwnerId' => QueryQueue.mlExpiredLeadsQueue.Id
      }
    );
    List<Lead> leadRecords = new List<Lead>{ leadRecord };
    //mocking
    leadMockProvider.mock(
      'getCampaignRecords',
      new List<Campaign>{
        new Campaign(
          Code__c = 'IKCMP-1670',
          Id = campaignId,
          Description = 'New Campaign',
          Name = 'Test Campaign'
        )
      }
    );
    Test.startTest();
    MobileLendingLeadTriggerHandler handler = new MobileLendingLeadTriggerHandler();
    handler.records = leadRecords;
    handler.onAfterInsert();
    Test.stopTest();
    //Assert the test for copyLeadId
    List<Lead> updatedLeadRecords = (List<Lead>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.isTrue(
      !updatedLeadRecords.isEmpty(),
      'copyLeadId is not updating records correctly'
    );
    Assert.areEqual(
      updatedLeadRecords[0].Lead_Id__c,
      leadRecord.Lead_Auto_Number__c,
      'Lead_Id__c should be updating correctly'
    );
    Assert.areEqual(
      updatedLeadRecords[0].Skip_Validations__c,
      'copyLeadId',
      'Skip_Validations__c should be updating with copyLeadId'
    );
    //Assert the test for createCampaignMember
    List<CampaignMember> cmCreated = (List<CampaignMember>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.isTrue(!cmCreated.isEmpty(), 'campaign members should be created!');
  }
  @isTest
  static void testAfterUpdate() {
    registerMocks();
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Lead leadRecord = getMLCRMLead();
    leadRecord.Id = leadId;
    leadRecord.Status = 'In Progress';
    leadRecord.Lead_Originator__c = 'Adobe';
    leadRecord.Territory__c = Lib_FakeIdGenerator.getMockId(
      Territory__c.SObjectType
    );
    Lead oldLead = getMLCRMLead();
    oldlead.Id = leadId;
    oldlead.Status = 'New';
    oldlead.Lead_Originator__c = 'Adobe';
    oldlead.Territory__c = Lib_FakeIdGenerator.getMockId(
      Territory__c.SObjectType
    );
    //mocking
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    userActionsRepositoryMock.mock('isIntegrationUser', false);
    userActionsRepositoryMock.mock(
      'getUserMapFromUserIds',
      new Map<Id, User>{
        userId => new User(id = userId, Lan_Id__c = 'test123')
      }
    );
    Task taskRecord = new Task(
      whoId = leadId,
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType)
    );
    leadMockProvider.mock('getLeadList', new List<Lead>());
    leadMockProvider.mock(
      new Map<String, Object>{
        'getTaskRecords' => new List<Task>{ taskRecord },
        'getLeadResponseToPlatformEventMappingMetadata' => new List<CCRM_Lead_Response_Event_Mapping__mdt>{
          new CCRM_Lead_Response_Event_Mapping__mdt(
            Object__c = 'Task',
            Platform_Event_Field_API_Name__c = 'Activity_Date__c',
            Task_or_Lead_Field_API_Name__c = 'ActivityDate'
          )
        }
      }
    );

    Map<Id, Lead> oldMap = new Map<Id, Lead>{ oldLead.Id => oldLead };
    //start test
    Test.startTest();
    MobileLendingLeadTriggerHandler handler = new MobileLendingLeadTriggerHandler();
    handler.records = new List<Lead>{ leadRecord };
    handler.onAfterUpdate(oldMap);
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doPublish'),
      'sendLeadUpdateToUnicaOrAdobe did not published Event successfully'
    );
  }
}
