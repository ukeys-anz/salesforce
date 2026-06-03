/**
 * @author Ayushi Gupta
 * @since 02/2024
 * @description Test class for CommercialOpportunityHelper
 */
@isTest
private class CommercialOpportunityHelperTest {
  static Lib_MockProvider commercialOppApiRepoMock;
  static Lib_MockProvider commercialOppRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Opportunity record = new Opportunity(
    Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
  );

  static void registerMocks() {
    commercialOppApiRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityAPIRepository.class
    );
    commercialOppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void checkOpenTaskForClosedOpportunitiesTest() {
    registerMocks();
    List<Database.Error> errors;
    Opportunity closedLostOpp;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Map<String, Object> result = new Map<String, Object>{ 'WhatId' => oppId };
    // Mock the Repo Methods
    commercialOppRepoMock.mock(
      'getOpenTasksOnClosedOpportunity',
      new List<Map<String, Object>>{ result }
    );

    closedLostOpp = CCRMTestDataFactory.createStaticOpportunityData(
      oppId,
      'Test Opp',
      RTOpportunity.commercialOpportunity,
      CCRMConstants.OPP_LOST
    );
    Test.startTest();
    CommercialOpportunityHelper.checkOpenTaskForClosedOpportunities(
      new Map<Id, Opportunity>{ closedLostOpp.Id => closedLostOpp }
    );
    Test.stopTest();
    errors = closedLostOpp.getErrors();
    Assert.isFalse(errors.isEmpty(), 'no errors found');
  }

  @isTest
  static void addErrorOnOppForMissingFieldsOnClosedAFPTest() {
    Opportunity opp;
    ApplicationFormProduct afp;
    List<Database.Error> errors;
    Database.Error error;

    opp = CCRMTestDataFactory.createStaticOpportunityData(
      Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      'Test Opp 1',
      RTOpportunity.commercialOpportunity,
      CCRMConstants.OPP_WON
    );

    afp = (ApplicationFormProduct) TestUtil.setFields(
      new ApplicationFormProduct(
        Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
        Stage = CCRMConstants.OPP_LOST,
        Lost_reason__c = '',
        Lost_Reason_Detail__c = '',
        ApplicationForm = new ApplicationForm(
          Id = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType),
          OpportunityId = opp.Id
        )
      ),
      new Map<String, Object>{ 'Name' => 'AFP-01234' }
    );

    Test.startTest();
    CommercialOpportunityHelper.addErrorOnOppForMissingFieldsOnClosedAFP(
      new List<ApplicationFormProduct>{ afp },
      new Map<Id, Opportunity>{ opp.Id => opp }
    );
    Test.stopTest();

    errors = opp.getErrors();
    Assert.isFalse(errors.isEmpty(), 'Error not found');
    error = errors.get(0);
    Assert.areEqual(
      'For ' +
        afp.Name +
        ', ' +
        CommercialOpportunityHelper.LOST_REASON_DETAIL_MISSING_AFP +
        '\n' +
        'For ' +
        afp.Name +
        ', ' +
        CommercialOpportunityHelper.WON_LOST_MANDATORY_AFP,
      error.getMessage(),
      'Opp updated successfully'
    );
  }

  @isTest
  static void testProcessPublishCaseToPega() {
    registerMocks();
    // Create test data
    OpportunityLineItem oli = new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType)
    );
    FinServ__AccountAccountRelation__c entity = new FinServ__AccountAccountRelation__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__AccountAccountRelation__c.SObjectType
      )
    );
    List<OpportunityLineItem> mockOliList = new List<OpportunityLineItem>{
      oli
    };
    List<FinServ__AccountAccountRelation__c> mockRelatedEntities = new List<FinServ__AccountAccountRelation__c>{
      entity
    };

    PegaCaseResponseModel mockResponse = new PegaCaseResponseModel();
    mockResponse.pyID = 'PEGA-CASE-12345';

    // Mock repository methods
    commercialOppRepoMock.mock(
      'getOpportunity',
      new List<Opportunity>{ record }
    );
    commercialOppRepoMock.mock('getOppProductsForOpportunity', mockOliList);
    commercialOppRepoMock.mock('getRelatedEntities', mockRelatedEntities);
    commercialOppApiRepoMock.mock('publishCaseToPega', mockResponse);

    Test.startTest();
    String result = CommercialOpportunityHelper.processPublishCaseToPega(
      record.Id,
      new List<Id>{ entity.Id },
      'Test entity product mapping notes'
    );
    Test.stopTest();

    Assert.areEqual('PEGA-CASE-12345', result, 'Case ID should match');

    // Verify API repository was called with correct parameters
    Assert.isNotNull(
      commercialOppApiRepoMock.getHistory('publishCaseToPega'),
      'publishCaseToPega should have been called'
    );

    // Verify repository was called with correct parameters
    Set<Id> opps = (Set<Id>) commercialOppRepoMock.getHistory('getOpportunity')
      .getParam('oppIds');

    Assert.isTrue(
      opps.contains(record.Id),
      'Opportunity ID passed to getOpportunity should be included'
    );

    Set<Id> oppLineItemIds = (Set<Id>) commercialOppRepoMock.getHistory(
        'getOppProductsForOpportunity'
      )
      .getParam('oppIds');

    Assert.isTrue(
      oppLineItemIds.contains(record.Id),
      'Opportunity ID passed to getOppProductsForOpportunity should be included'
    );

    Set<Id> relatedEntityIds = (Set<Id>) commercialOppRepoMock.getHistory(
        'getRelatedEntities'
      )
      .getParam('entityIds');

    Assert.isTrue(
      relatedEntityIds.containsAll(new List<Id>{ entity.Id }),
      'All related entity IDs should be passed to getRelatedEntities'
    );
  }

  @isTest
  static void testUpdateOpportunityWithPegaDetails() {
    registerMocks();

    // Create test data
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    String caseId = 'PEGA-CASE-12345';

    Database.SaveResult saveResult = TestUtil.getMockSaveResult(
      '{"success":true}'
    );
    // Mock DML repository
    dmlRepoMock.mock('doUpdate', saveResult);

    Test.startTest();
    CommercialOpportunityHelper.updateOpportunityWithPegaDetails(
      oppId,
      caseId,
      'Test entity product mapping notes'
    );
    Test.stopTest();

    // Verify DML was called
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    // Verify the opportunity record has the correct fields
    Opportunity updatedOpp = (Opportunity) dmlRepoMock.getHistory('doUpdate')
      .getParam('record');
    Assert.areEqual(oppId, updatedOpp.Id, 'Opportunity Id should match');
    Assert.areEqual(
      caseId,
      updatedOpp.Pega_Case_Unique_Identifier__c,
      'Pega Case ID should be set correctly on the opportunity'
    );
  }

  @isTest
  static void testUpdateOpportunityWithPegaDetailsNullCaseId() {
    registerMocks();

    // Create test data
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    String caseId = null;

    // Mock DML update
    dmlRepoMock.mock('doUpdate', null);

    Test.startTest();
    CommercialOpportunityHelper.updateOpportunityWithPegaDetails(
      oppId,
      caseId,
      ''
    );
    Test.stopTest();

    // Verify DML was called
    Lib_MockProvider.MockHistory dmlHistory = dmlRepoMock.getHistory(
      'doUpdate'
    );
    Assert.isNotNull(dmlHistory, 'doUpdate should have been called');

    // Verify the opportunity record has the correct fields
    Opportunity updatedOpp = (Opportunity) dmlRepoMock.getHistory('doUpdate')
      .getParam('record');
    Assert.areEqual(oppId, updatedOpp.Id, 'Opportunity Id should match');
    Assert.areEqual(
      null,
      updatedOpp.Pega_Case_Unique_Identifier__c,
      'Pega Case ID should be set correctly on the opportunity'
    );
  }

  @isTest
  static void validateCCRMOpportunityTest() {
    registerMocks();
    List<Database.Error> errors;
    Database.Error error;
    //GIVEN list of Opportunity records, old Map of Opportunity records
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Account accRecord = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount
    );
    //List<Opportunity> oppList = new List<Opportunity>(){};
    List<Opportunity> records = new List<Opportunity>{
      new Opportunity(
        Id = oppId,
        AccountId = accRecord.Id,
        Name = 'Test',
        StageName = 'In Progress',
        LeadSource = 'Other'
      )
    };
    CommercialOpportunityActions.CCRMOpportunityWrapper oppWrapper = new CommercialOpportunityActions.CCRMOpportunityWrapper();
    oppWrapper.filteredOpps = records;
    //WHEN calling a method
    Test.startTest();
    CommercialOpportunityHelper.validateCCRMOpportunity(oppWrapper, true);
    Test.stopTest();

    errors = records[0].getErrors();
    error = errors.get(0);
    Assert.isTrue(
      error.getMessage()
        .contains(CommercialOpportunityHelper.OTHER_SOURCE_DETAIL_MANDATORY),
      'Validation error when opportunity is closed without app launch'
    );
  }
}
