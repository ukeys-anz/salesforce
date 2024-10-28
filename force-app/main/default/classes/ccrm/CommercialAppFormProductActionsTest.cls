/**
 * @author Ayushi Gupta
 * @since 08/2024
 * @description  CommercialAppFormProductActionsTest is the test class for CommercialAppFormProductActions.
 */
@isTest
private class CommercialAppFormProductActionsTest {
  static Lib_MockProvider appFormProductRepoMock;
  static Lib_MockProvider commercialOppRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    appFormProductRepoMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
    );
    commercialOppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testSetFieldsOnRelatedOpportunity() {
    registerMocks();
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      Opportunity = new Opportunity(
        Id = oppId,
        CloseDate = DateTimeUtils.getNextWeekdayDate(1)
      )
    );
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormobj.Id,
      CCRMConstants.NEED_ANALYSIS
    );
    afpList[0].Id = appFormProdId;
    // Mock the Repo Methods
    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );

    Test.startTest();
    CommercialAppFormProductActions.setFieldsOnRelatedOpportunity(
      afpList,
      null
    );
    Test.stopTest();
    List<Opportunity> opp = (List<Opportunity>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.areEqual(
      afpList[0].close_date__c,
      opp[0].CloseDate,
      'Date populated'
    );
  }

  @isTest
  static void testfetchvalidRecordId() {
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.NEED_ANALYSIS
    );

    Test.startTest();
    Set<Id> validAppFormRecordId = CommercialAppFormProductActionsHelper.fetchvalidRecordId(
      afpList,
      null
    );
    Test.stopTest();
    Assert.areEqual(1, validAppFormRecordId.size(), 'valid records are found');
  }
  @isTest
  static void testsetOpportunityCloseDateField() {
    Id appFormProdId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      Opportunity = new Opportunity(
        Id = oppId,
        CloseDate = DateTimeUtils.getNextWeekdayDate(1)
      )
    );
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormobj.Id,
      CCRMConstants.NEED_ANALYSIS
    );
    afpList[0].Id = appFormProdId;
    Test.startTest();
    List<Opportunity> oppToUpdate = CommercialAppFormProductActionsHelper.setOpportunityCloseDateField(
      new List<ApplicationForm>{ appFormobj },
      afpList
    );
    Test.stopTest();
    Assert.areEqual(
      oppToUpdate[0].closeDate,
      afpList[0].Close_Date__c,
      'Opportunityclose date matches app form prod close date'
    );
  }

  @isTest
  static void testPopulateCloseDate() {
    registerMocks();

    //GIVEN Application Form, App form Product list, Opportunity Line Item list
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);

    ApplicationForm appFormobj = new ApplicationForm(
      Id = appFormId,
      OpportunityId = oppId,
      Opportunity = new Opportunity(
        Id = oppId,
        CloseDate = DateTimeUtils.getNextWeekdayDate(1)
      )
    );

    List<ApplicationFormProduct> appFormProductList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Stage = CCRMConstants.NEW_STAGE,
        ApplicationFormId = appFormId,
        ProductId = productId
      )
    };

    List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>{
      new OpportunityLineItem(
        opportunityId = oppId,
        Product2Id = productId,
        Expected_Settlement_Date__c = DateTimeUtils.getWeekday(
          system.today().addDays(1),
          true,
          true
        )
      )
    };

    appFormProductRepoMock.mock(
      'getApplicationForms',
      new List<ApplicationForm>{ appFormobj }
    );
    appFormProductRepoMock.mock('getOppProductRelatedToAFP', oppLineItemList);

    //WHEN populateCloseDate method get called
    Test.startTest();
    CommercialAppFormProductActions.populateCloseDate(appFormProductList);
    Test.stopTest();

    //THEN Close date on AFP should get updated
    Assert.isNotNull(
      appFormProductList[0].Close_Date__c,
      'Close date not updated on Application form product'
    );
  }
}
