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

  @isTest
  static void formOppToAmountMapTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afId2 = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    List<ApplicationFormProduct> afpList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId,
        Revenue__c = 50,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.acmApplication,
          OpportunityId = oppId
        )
      ),
      new ApplicationFormProduct(
        Id = afpId,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId2,
        Revenue__c = 500,
        ApplicationForm = new ApplicationForm(
          Id = afId2,
          RecordTypeId = RTApplicationForm.ambitApplication,
          OpportunityId = oppId
        )
      )
    };

    Map<Id, Id> itemIdToOppIdMap = new Map<Id, Id>{ oliId => oppId };
    Map<Id, List<ApplicationFormProduct>> oliToAfpMap = new Map<Id, List<ApplicationFormProduct>>{
      oliId => afpList
    };
    Test.startTest();
    Map<Id, Decimal> oppToEstimatedRevenueMap = CommercialAFPActionsExtended.formOppToAmountMap(
      itemIdToOppIdMap,
      oliToAfpMap,
      ApplicationFormProduct.Revenue__c
    );
    Test.stopTest();
    Assert.areEqual(
      500,
      oppToEstimatedRevenueMap.get(oppId),
      'Estimated Revenue on opp is not 500'
    );
  }

  @isTest
  static void formOppToAmountMapNegativeTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);

    Map<Id, Id> itemIdToOppIdMap = new Map<Id, Id>{ oliId => oppId };
    Map<Id, List<ApplicationFormProduct>> oliToAfpMap = new Map<Id, List<ApplicationFormProduct>>{
      oliId => new List<ApplicationFormProduct>()
    };
    Test.startTest();
    Map<Id, Decimal> oppToEstimatedRevenueMap = CommercialAFPActionsExtended.formOppToAmountMap(
      itemIdToOppIdMap,
      oliToAfpMap,
      ApplicationFormProduct.Revenue__c
    );
    Test.stopTest();
    Assert.areEqual(
      0,
      oppToEstimatedRevenueMap.get(oppId),
      'Estimated Revenue on opp is not 0'
    );
  }
}
