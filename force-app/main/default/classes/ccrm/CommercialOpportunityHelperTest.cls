/**
 * @author Ayushi Gupta
 * @since 02/2024
 * @description Test class for CommercialOpportunityHelper
 */
@isTest
private class CommercialOpportunityHelperTest {
  static Lib_MockProvider commercialOppRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Opportunity record = new Opportunity(
    Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
  );

  static void registerMocks() {
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
