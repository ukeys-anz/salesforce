/**
 * @author Ayushi Gupta
 * @since 08/2024
 * @description  CommercialAppFormActionsTest is the test class for CommercialAppFormActions.
 */

@isTest
private class CommercialAppFormActionsTest {
  static Lib_MockProvider appFormProductRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    appFormProductRepoMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
    );
  }

  @isTest
  static void getOppIdsRelatedToAmountUpdatedAppFormsTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<ApplicationForm> appForms = CCRMTestDataFactory.createAppForm(
      1,
      oppId
    );
    appForms[0].Id = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    ApplicationForm oldAppForm = CCRMTestDataFactory.createAppForm(1, oppId)[0];
    oldAppForm.Application_Amount__c = 123;
    oldAppForm.Id = appForms[0].Id;
    Test.startTest();
    Set<Id> oppIds = CommercialAppFormActions.getOppIdsRelatedToAmountUpdatedAppForms(
      appForms,
      new Map<Id, ApplicationForm>{ appForms[0].Id => oldAppForm }
    );
    Test.stopTest();
    Assert.areEqual(1, oppIds.size(), 'No opp ids found');
  }

  @isTest
  static void updateOpportunityWithTotalAmountTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Map<String, Object> appForms = new Map<String, Object>{
      'OpportunityId' => oppId,
      'Amount' => 123
    };
    Test.startTest();
    List<Opportunity> updatedOpps = CommercialAppFormActions.updateOpportunityWithTotalAmount(
      new List<Map<String, Object>>{ appForms }
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      updatedOpps.size(),
      'There should be atleast one opportunity which needs to be updated'
    );
  }

  @isTest
  static void setTotalAmountOnOppTest() {
    registerMocks();
    //Create mock data
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Opportunity opp = CCRMTestDataFactory.createStaticOpportunityData(
      null,
      'Test Opp',
      RTOpportunity.commercialOpportunity,
      CCRMConstants.NEW_STAGE
    );
    opp.Id = oppId;
    Map<String, Object> result = new Map<String, Object>{
      'OpportunityId' => oppId,
      'Amount' => 123
    };
    List<ApplicationForm> appForms = CCRMTestDataFactory.createAppForm(
      1,
      oppId
    );
    appForms[0].Id = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    appForms[0].Application_Amount__c = 5;
    ApplicationForm oldAppForm = CCRMTestDataFactory.createAppForm(1, oppId)[0];
    oldAppForm.Application_Amount__c = 123;
    oldAppForm.Id = appForms[0].Id;

    // Mock the Repo Methods
    appFormProductRepoMock.mock(
      'getCommercialAppFormsWithAggregatedAmount',
      new List<Map<String, Object>>{ result }
    );
    Test.startTest();

    CommercialAppFormActions.setTotalAmountOnOpp(
      appForms,
      new Map<Id, ApplicationForm>{ appForms[0].Id => oldAppForm }
    );
    Test.stopTest();
    List<Opportunity> opps = (List<Opportunity>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.isFalse(
      opps.isEmpty(),
      'There should be some opps that are updated'
    );
  }
}
