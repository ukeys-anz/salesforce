/**
 * @author       : Karen Valeriano
 * @since        : Dec 2025
 * @description  : Test class for @link CommercialOpportunityController
 **/
@isTest
private class CommercialOpportunityControllerTest {
  static Lib_MockProvider repoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider apiRepoMock;

  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(CommercialOpportunityRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    apiRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityAPIRepository.class
    );
  }
  static Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

  static Opportunity mockOpp = new Opportunity(Id = oppId);
  static List<OpportunityLineItem> mockOppLineItems = new List<OpportunityLineItem>{
    new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
      OpportunityId = oppId,
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType)
    )
  };
  static List<Id> mockRelatedEntityIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(
      FinServ__AccountAccountRelation__c.SObjectType
    )
  };

  @isTest
  static void testGetOppLineItems() {
    registerMocks();
    repoMock.mock('getOppProductsForOpportunity', mockOppLineItems);

    Test.startTest();
    List<OpportunityLineItem> result = CommercialOpportunityController.getOppLineItems(
      oppId
    );
    Test.stopTest();

    Assert.isFalse(
      repoMock.getHistories('getOppProductsForOpportunity').isEmpty(),
      'getOppProductsForOpportunity should have been called'
    );
    Assert.areEqual(
      mockOppLineItems,
      result,
      'Returned OpportunityLineItems should match the mock data'
    );
  }

  @isTest
  static void testPublishCaseToPega() {
    registerMocks();

    PegaCaseResponseModel mockResponse = new PegaCaseResponseModel();
    mockResponse.pyID = 'PEGA-CASE-123';
    mockResponse.nextPageID = 'NextPage';

    // Mock repository calls
    repoMock.mock('getOpportunity', new List<Opportunity>{ mockOpp });
    repoMock.mock('getOppProductsForOpportunity', mockOppLineItems);

    List<FinServ__AccountAccountRelation__c> mockRelatedEntities = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = mockRelatedEntityIds[0],
        FinServ__Account__c = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
      )
    };
    repoMock.mock('getRelatedEntities', mockRelatedEntities);

    // Mock Api repository
    apiRepoMock.mock('publishCaseToPega', mockResponse);

    Database.SaveResult saveResult = TestUtil.getMockSaveResult(
      '{"success":true}'
    );
    // Mock DML repository
    dmlRepoMock.mock('doUpdate', saveResult);

    Test.startTest();
    CommercialOpportunityController.publishCaseToPega(
      oppId,
      mockRelatedEntityIds,
      'test notes'
    );
    Test.stopTest();

    // Verify repository method calls
    Assert.isFalse(
      repoMock.getHistories('getOpportunity').isEmpty(),
      'getOpportunity should have been called'
    );
    Assert.isFalse(
      repoMock.getHistories('getOppProductsForOpportunity').isEmpty(),
      'getOppProductsForOpportunity should have been called'
    );
    Assert.isFalse(
      repoMock.getHistories('getRelatedEntities').isEmpty(),
      'getRelatedEntities should have been called'
    );
    Assert.isFalse(
      apiRepoMock.getHistories('publishCaseToPega').isEmpty(),
      'publishCaseToPega should have been called on API repository'
    );
    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been called to update opportunity with Pega case ID'
    );

    // Verify records retrieved from calling repositories
    Set<Id> opps = (Set<Id>) repoMock.getHistory('getOpportunity')
      .getParam('oppIds');

    Assert.isTrue(
      opps.contains(oppId),
      'Opportunity ID passed to getOpportunity should be included'
    );

    Set<Id> oppLineItemIds = (Set<Id>) repoMock.getHistory(
        'getOppProductsForOpportunity'
      )
      .getParam('oppIds');

    Assert.isTrue(
      oppLineItemIds.contains(oppId),
      'Opportunity ID passed to getOppProductsForOpportunity should be included'
    );

    Set<Id> relatedEntityIds = (Set<Id>) repoMock.getHistory(
        'getRelatedEntities'
      )
      .getParam('entityIds');

    Assert.isTrue(
      relatedEntityIds.containsAll(mockRelatedEntityIds),
      'All related entity IDs should be passed to getRelatedEntities'
    );

    // Verify opportunity was updated with Pega case ID
    Opportunity updatedOpp = (Opportunity) dmlRepoMock.getHistory('doUpdate')
      .getParam('record');
    Assert.areEqual(oppId, updatedOpp.Id, 'Opportunity ID should match');
    Assert.areEqual(
      'PEGA-CASE-123',
      updatedOpp.Pega_Case_Unique_Identifier__c,
      'Pega Case ID should be set correctly on the opportunity'
    );
  }

  @isTest
  static void testPublishCaseToPegaWithException() {
    registerMocks();

    // Mock repository to throw an exception
    apiRepoMock.mock('publishCaseToPega', new CalloutException('Error'));
    Exception ex;

    Test.startTest();
    try {
      CommercialOpportunityController.publishCaseToPega(
        oppId,
        mockRelatedEntityIds,
        'test notes'
      );
      Assert.fail('Expected AuraHandledException to be thrown');
    } catch (AuraHandledException e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof AuraHandledException,
      'Exception should be of type AuraHandledException'
    );
    Test.stopTest();
  }
}
