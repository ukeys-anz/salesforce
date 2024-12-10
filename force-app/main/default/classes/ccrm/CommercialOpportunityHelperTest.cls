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
  static void validateOppOnInsertTest() {
    String expMsg = 'Stage can only be set to New.';
    List<Database.Error> errors;
    Database.Error error;

    Opportunity opp = CCRMTestDataFactory.createStaticOpportunityData(
      null,
      'Test Opp',
      RTOpportunity.commercialOpportunity,
      CCRMConstants.IN_PROGRESS_STAGE
    );
    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper = new CCRMOpportunityActions.CCRMOpportunityWrapper();
    oppWrapper.filteredOpps.add(opp);
    Test.startTest();
    CommercialOpportunityHelper.validateCCRMOpportunity(oppWrapper, true);
    Test.stopTest();

    errors = opp.getErrors();
    Assert.isFalse(errors.isEmpty(), 'Error not found');
    error = errors.get(0);
    Assert.areEqual(expMsg, error.getMessage(), 'No error occured');
  }

  @isTest
  static void validateCCRMOpportunitiesTest() {
    String expMsgForLeadSource = 'Other Source Detail is mandatory if Lead Source is Other.';

    Opportunity leadSourceOpp;
    List<Database.Error> leadSourceOppErrors;
    Database.Error leadSourceError;

    leadSourceOpp = CCRMTestDataFactory.createStaticOpportunityData(
      Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      'Test Opp 1',
      RTOpportunity.commercialOpportunity,
      'Needs Analysis'
    );
    leadSourceOpp.LeadSource = 'Other';

    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper = new CCRMOpportunityActions.CCRMOpportunityWrapper();
    oppWrapper.filteredOpps = new List<Opportunity>{ leadSourceOpp };

    Test.startTest();
    CommercialOpportunityHelper.validateCCRMOpportunity(oppWrapper, false);
    Test.stopTest();

    leadSourceOppErrors = leadSourceOpp.getErrors();
    Assert.isFalse(leadSourceOppErrors.isEmpty(), 'Error not found');

    leadSourceError = leadSourceOppErrors.get(0);
    Assert.areEqual(
      expMsgForLeadSource,
      leadSourceError.getMessage(),
      'Opp updated successfully'
    );
  }

  @isTest
  static void validateSkipStageTest() {
    Opportunity opp;
    Opportunity oldOpp;
    Map<Id, String> oppsStageSegmentMap;
    List<Database.Error> errors;
    Database.Error error;

    opp = CCRMTestDataFactory.createStaticOpportunityData(
      Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      'Test Opp 1',
      RTOpportunity.commercialOpportunity,
      CCRMConstants.OPP_WON
    );

    oldOpp = CCRMTestDataFactory.createStaticOpportunityData(
      opp.Id,
      'Test Opp 2',
      RTOpportunity.commercialOpportunity,
      CCRMConstants.NEW_STAGE
    );

    oppsStageSegmentMap = new Map<Id, String>{ opp.Id => 'New-CBO' };

    Test.startTest();
    CommercialOpportunityHelper.addErrorForSkippedStage(
      new List<Opportunity>{ opp },
      new Map<Id, Opportunity>{ opp.Id => oldOpp },
      oppsStageSegmentMap
    );
    Test.stopTest();

    errors = opp.getErrors();
    Assert.isFalse(errors.isEmpty(), 'Error not found');
    error = errors.get(0);
    Assert.areEqual(
      CCRMConstants.SKIP_STAGE,
      error.getMessage(),
      'Opp updated successfully'
    );
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
}
