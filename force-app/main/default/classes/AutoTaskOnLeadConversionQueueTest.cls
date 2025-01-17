/**
 * @author Ankit Garg
 * @since July 2023
 * @description test class for AutoTaskOnLeadConversionQueueable
 * @group Service
 */
@isTest
public with sharing class AutoTaskOnLeadConversionQueueTest {
  static Lib_MockProvider leadActionsRepoMock;
  static Lib_MockProvider dmlMockProvider;

  static void registerMocks() {
    leadActionsRepoMock = Lib_MockProvider.forType(
      LeadConversionActionsRepository.class
    );
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
  }

  @IsTest
  static void testAutoTaskLeadConvMLCRMWithNameMatch() {
    registerMocks();
    Lead leadRecord = getMockLead(true, 'MLCRM_Lead');
    leadActionsRepoMock.mock('getLeadsWithCustomerDetails', leadRecord);
    Test.startTest();
    System.enqueuejob(
      new AutoTaskOnLeadConversionQueueable(
        new Map<Id, Id>{ leadRecord.Id => leadRecord.ConvertedOpportunity.Id }
      )
    );
    Test.stopTest();
    List<Task> tasks = (List<Task>) dmlMockProvider.getHistory('doInsert')
      .getParam('records');
    Assert.isFalse(
      tasks[0].Description.contains('First Name'),
      'No mismatch in Name'
    );
    Assert.isTrue(
      tasks[0].Description.contains('Home Phone'),
      'Mismatch in Home Phone'
    );
    Assert.areEqual(
      tasks[0].RecordTypeId,
      RTTask.mlcrmTask,
      'Check RecordType is MLCRM'
    );
  }

  @IsTest
  static void testAutoTaskLeadConvMLCRMWithNameMisMatch() {
    registerMocks();
    Lead leadRecord = getMockLead(false, 'MLCRM_Lead');
    leadActionsRepoMock.mock('getLeadsWithCustomerDetails', leadRecord);
    Test.startTest();
    System.enqueuejob(
      new AutoTaskOnLeadConversionQueueable(
        new Map<Id, Id>{ leadRecord.Id => leadRecord.ConvertedOpportunity.Id }
      )
    );
    Test.stopTest();
    List<Task> tasks = (List<Task>) dmlMockProvider.getHistory('doInsert')
      .getParam('records');
    Assert.isTrue(
      tasks[0].Description.contains('First Name'),
      'Mismatch in Name'
    );
    Assert.isTrue(
      tasks[0].Description.contains('Home Phone'),
      'Mismatch in Home Phone'
    );
    Assert.areEqual(
      tasks[0].RecordTypeId,
      RTTask.mlcrmTask,
      'Check RecordType is MLCRM'
    );
  }

  @IsTest
  static void testAutoTaskLeadConvCCRM() {
    registerMocks();
    Lead leadRecord = getMockLead(false, 'CCRM_Lead');
    leadActionsRepoMock.mock('getLeadsWithCustomerDetails', leadRecord);
    Test.startTest();
    System.enqueuejob(
      new AutoTaskOnLeadConversionQueueable(
        new Map<Id, Id>{ leadRecord.Id => leadRecord.ConvertedOpportunity.Id }
      )
    );
    Test.stopTest();
    List<Task> tasks = (List<Task>) dmlMockProvider.getHistory('doInsert')
      .getParam('records');
    Assert.areEqual(
      tasks[0].RecordTypeId,
      RTTask.ccrmTask,
      'Check RecordType is CCRM'
    );
  }

  @isTest
  static void testCheckLeadMisMatchCustomer() {
    registerMocks();
    Lead leadRecord = getMockLead(false, 'MLCRM_Lead');
    Test.startTest();
    Map<Id, String> result = AutoTaskOnLeadConversionHelper.checkLeadMisMatchCustomer(
      leadRecord
    );
    Test.stopTest();
    Assert.isTrue(
      result.get(leadRecord.Id).contains('First Name'),
      'Mismatch in Name'
    );
    Assert.isTrue(
      result.get(leadRecord.Id).contains('Home Phone'),
      'Mismatch in Home Phone'
    );
  }

  @isTest
  static void testCompareLeadWithCustomerFields() {
    registerMocks();
    Lead leadRecord = getMockLead(true, 'MLCRM_Lead');
    Set<String> fieldsToCompare = new Set<String>{
      'FirstName',
      'Home_Phone__c'
    };
    Test.startTest();
    Set<String> result = AutoTaskOnLeadConversionHelper.compareLeadWithCustomerFields(
      leadRecord,
      fieldsToCompare
    );
    Test.stopTest();
    Assert.isFalse(result.contains('First Name'), 'No Mismatch in Name');
    Assert.isTrue(result.contains('Home Phone'), 'Mismatch in Home Phone');
  }

  @isTest
  static void testCheckField() {
    registerMocks();
    Lead leadRecord = getMockLead(true, 'MLCRM_Lead');
    Test.startTest();
    Boolean result = AutoTaskOnLeadConversionHelper.checkField(
      leadRecord,
      'FirstName'
    );
    Test.stopTest();
    Assert.areEqual(result, true, 'Name is matched');
  }

  @isTest
  static void testGetTargetValue() {
    registerMocks();
    Lead leadRecord = getMockLead(true, 'MLCRM_Lead');
    Test.startTest();
    String result = (String) AutoTaskOnLeadConversionHelper.getTargetValue(
      leadRecord,
      'FirstName'
    );
    Test.stopTest();
    Assert.areEqual(result, 'test', 'Name is matched');
  }

  @isTest
  static void testArePhonesEqual() {
    Test.startTest();
    Boolean result = AutoTaskOnLeadConversionHelper.arePhonesEqual(
      '88888888',
      '88888888'
    );
    Test.stopTest();
    Assert.areEqual(result, true, 'Phone numbers are matched');
  }

  @isTest
  static void testAreAdvertisingIndicatorEquals() {
    Test.startTest();
    Boolean result = AutoTaskOnLeadConversionHelper.areAdvertisingIndicatorEquals(
      true,
      'Y'
    );
    Test.stopTest();
    Assert.areEqual(result, true, 'Advertising Indicators are matched');
  }

  @isTest
  static void testGenerateTasks() {
    registerMocks();
    Lead leadRecord = getMockLead(true, 'MLCRM_Lead');
    Test.startTest();
    List<Task> tasks = AutoTaskOnLeadConversionHelper.generateTasks(
      leadRecord,
      leadRecord.ConvertedOpportunity.Id,
      new Map<Id, String>{ leadRecord.Id => 'Name' }
    );
    Test.stopTest();
    Assert.areEqual(
      tasks[0].recordtypeId,
      RTTask.mlcrmTask,
      'Recordtype is matched'
    );
    Assert.areEqual(tasks[0].Status, 'Open', 'Status is matched');
  }

  @isTest
  static void testAutocreateTaskForML() {
    registerMocks();
    Lead leadRecord = getMockLead(true, 'MLCRM_Lead');
    Test.startTest();
    Task taskRecord = AutoTaskOnLeadConversionHelper.autocreateTaskForML(
      leadRecord,
      leadRecord.ConvertedOpportunity.Id,
      'Name'
    );
    Test.stopTest();
    Assert.areEqual(
      taskRecord.recordtypeId,
      RTTask.mlcrmTask,
      'Recordtype is matched'
    );
    Assert.areEqual(taskRecord.Status, 'Open', 'Status is matched');
    Assert.isTrue(
      taskRecord.Description.contains('Name'),
      'Name is mismatched'
    );
  }

  @isTest
  static void testAutocreateTaskForCCRM() {
    registerMocks();
    Lead leadRecord = getMockLead(true, 'CCRM_Lead');
    Test.startTest();
    Task taskRecord = AutoTaskOnLeadConversionHelper.autocreateTaskForCCRM(
      leadRecord,
      leadRecord.ConvertedOpportunity.Id,
      'Name'
    );
    Test.stopTest();
    Assert.areEqual(
      taskRecord.recordtypeId,
      RTTask.ccrmTask,
      'Recordtype is matched'
    );
    Assert.areEqual(taskRecord.Status, 'Open', 'Status is matched');
    Assert.isTrue(
      taskRecord.Description.contains('Name'),
      'Name is mismatched'
    );
  }

  static Lead getMockLead(Boolean isNameMatch, String recordType) {
    Id accountId = Lib_FakeIdGenerator.getMockId(
      Schema.Account.getSObjectType()
    );
    return new Lead(
      FinServ__RelatedAccount__c = accountId,
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      FirstName = 'test',
      MiddleName = 'test',
      LastName = 'test',
      Email = 'test@gmail.com',
      Is_Valid_Address__c = true,
      Gender__c = 'M',
      Home_Phone__c = '+61533333333',
      MobilePhone = '+61533333333',
      Work_Phone__c = '+61533333333',
      Street = 'Str 123',
      City = 'City 123',
      Country = 'Australia',
      State = 'State 123',
      PostalCode = '123',
      ConvertedOpportunity = new Opportunity(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType())
      ),
      AdvertisingIndicator__c = true,
      RecordType = new RecordType(DeveloperName = recordType),
      FinServ__RelatedAccount__r = new Account(
        Id = accountId,
        FirstName = isNameMatch ? 'test' : 'test1',
        MiddleName = isNameMatch ? 'test' : 'test1',
        LastName = isNameMatch ? 'test' : 'test1',
        Advertising_Indicator__c = 'Y',
        OCV_Event_Version__c = 1
      )
    );
  }
}
