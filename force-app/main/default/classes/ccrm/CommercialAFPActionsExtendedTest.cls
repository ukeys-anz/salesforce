/**
 * @author Ayushi Gupta
 * @since 02/2025
 * @description  CommercialAFPActionsExtendedTest is the test class for CommercialAFPActionsExtended.
 */
@isTest
private class CommercialAFPActionsExtendedTest {
  static Lib_MockProvider commercialOppRepoMock;
  static void registerMocks() {
    commercialOppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
  }

  @isTest
  static void checkForOpenTasksTest() {
    registerMocks();
    List<Database.Error> errors;
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    ApplicationFormProduct appFormProductObj = new ApplicationFormProduct(
      Id = appFormProdId,
      Stage = 'Opportunity Won',
      ApplicationForm = new ApplicationForm(
        Id = appFormId,
        OpportunityId = oppId
      )
    );
    Map<String, Object> result = new Map<String, Object>{ 'WhatId' => oppId };
    commercialOppRepoMock.mock(
      'getOpenTasksOnClosedOpportunity',
      new List<Map<String, Object>>{ result }
    );
    Opportunity oppRec = new Opportunity(
      Id = oppId,
      StageName = 'Opportunity Won'
    );
    Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>{
      oppId => oppRec
    };
    Test.startTest();
    CommercialAFPActionsExtended.checkForOpenTasks(
      new List<ApplicationFormProduct>{ appFormProductObj },
      new List<ApplicationFormProduct>{ appFormProductObj },
      oppsToUpdate
    );
    Test.stopTest();
    errors = appFormProductObj.getErrors();
    Assert.isFalse(errors.isEmpty(), 'no errors found');
  }
  @isTest
  static void checkForOpenTasksTestWithNoTask() {
    registerMocks();
    List<Database.Error> errors;
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    ApplicationFormProduct appFormProductObj = new ApplicationFormProduct(
      Id = appFormProdId,
      Stage = 'Opportunity Won',
      ApplicationForm = new ApplicationForm(
        Id = appFormId,
        OpportunityId = oppId
      )
    );
    commercialOppRepoMock.mock(
      'getOpenTasksOnClosedOpportunity',
      new List<Map<String, Object>>{}
    );
    Opportunity oppRec = new Opportunity(
      Id = oppId,
      StageName = 'Opportunity Won'
    );
    Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>{
      oppId => oppRec
    };
    Test.startTest();
    CommercialAFPActionsExtended.checkForOpenTasks(
      new List<ApplicationFormProduct>{ appFormProductObj },
      new List<ApplicationFormProduct>{ appFormProductObj },
      oppsToUpdate
    );
    Test.stopTest();
    errors = appFormProductObj.getErrors();
    Assert.isTrue(errors.isEmpty(), 'Errors found');
  }
}
