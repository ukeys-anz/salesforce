/**
 * @author Sanskriti
 * @since 1/2025
 * @description LeadActionHelperTest class for unit testing task creation upon insertion of BOH callback request lead
 */
@isTest
private class LeadActionsHelperTest {
  static Lib_MockProvider leadMockProvider;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    leadMockProvider = Lib_MockProvider.forType(LeadActionsRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static Lead getMLCRMLead() {
    return new Lead(
      RecordTypeId = QueryRT.of(Lead.SObjectType).getId('MLCRM_Lead'),
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Campaign_Code__c = 'IKCMP-1670',
      Status = 'In progress',
      Lead_Originator__c = 'UNICA'
    );
  }

  @isTest
  static void testPopulateFieldsFromCampaign() {
    registerMocks();
    leadMockProvider.mock(
      'getCampaignRecords',
      new List<Campaign>{
        new Campaign(Code__c = 'IKCMP-1670', Description = 'New Campaign')
      }
    );
    Lead record = getMLCRMLead();
    Test.startTest();
    LeadActionsHelper.populateFieldsFromCampaign(new List<Lead>{ record });
    Test.stopTest();
    Assert.areEqual(
      'New Campaign',
      record.Description,
      'Description is not populated from campaign'
    );
  }

  @isTest
  static void testPopulateRelatedAccount() {
    Account testAccount = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Account.getSObjectType()),
      Name = 'Test Account',
      Source_System_Name__c = 'CAP-CIS',
      Source_System_ID__c = '4025663541'
    );
    registerMocks();
    leadMockProvider.mock(
      'getRelatedAccounts',
      new List<Account>{ testAccount }
    );
    Lead leadRecord = getMLCRMLead();
    leadRecord.Customer_ID__c = '4025663541';
    Test.startTest();
    LeadActionsHelper.populateRelatedAccount(new List<Lead>{ leadRecord });
    Test.stopTest();
    Assert.areEqual(
      testAccount.Id,
      leadRecord.FinServ__RelatedAccount__c,
      'Account Id is not populated'
    );
  }

  @isTest
  static void testPopulateLeadSourceForUnicaOrigin() {
    Lead record = getMLCRMLead();
    Test.startTest();
    LeadActionsHelper.populateLeadSourceForUnicaOrigin(
      new List<Lead>{ record }
    );
    Test.stopTest();
    Assert.areEqual(
      'ANZ Campaigns',
      record.LeadSource,
      'Lead source is not populated as ANZ Campaigns'
    );
  }

  @isTest
  static void testPopulateLeadSourceForAdobeOrigin() {
    Lead record = getCCRMLead();
    Test.startTest();
    LeadActionsHelper.populateLeadSourceForAdobeOrigin(
      new List<Lead>{ record }
    );
    Test.stopTest();
    Assert.areEqual(
      'ANZ.com',
      record.LeadSource,
      'Lead source is not populated as ANZ Campaigns'
    );
  }

  @isTest
  static void testPopulateRegisteredCompany() {
    Lead record = getCCRMLead();
    record.Entity_Type__c = 'Individual';
    Test.startTest();
    LeadActionsHelper.populateRegisteredCompany(new List<Lead>{ record });
    Test.stopTest();
    Assert.areEqual(
      'No',
      record.Registered_Company__c,
      'Registered company is not populated as No'
    );
  }

  static Lead getCCRMLead() {
    return new Lead(
      RecordTypeId = QueryRT.of(Lead.SObjectType).getId('CCRM_Lead'),
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Campaign_Code__c = 'IKCMP-1670',
      Status = 'New',
      Lead_Originator__c = 'Adobe'
    );
  }

  @isTest
  static void testCallbackTaskCreation() {
    registerMocks();

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
    Lead leadrecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Firstname = 'Test',
      RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID,
      LeadSource = 'Web explore',
      Is_BOH_Lead__c = true
    );
    Lead leadrecord2 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Firstname = 'Test2',
      RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID,
      LeadSource = 'Advertisement'
    );

    List<Lead> leadList = new List<Lead>{ leadrecord, leadrecord2 };
    Test.startTest();
    LeadActionsHelper.checkAndCreateCallbackTask(leadList);
    Test.stopTest();

    List<Task> taskCreated = (List<Task>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');

    Assert.isTrue(taskCreated.size() == 1, 'Only one Task should be created');
  }
}
