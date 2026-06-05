/**
 * @author Amisha Gyani
 * @since February 2026
 * @group CCRMAgent
 * @description Test class for CCRMAgentCreateProduct invocable Apex class.
 *              Verifies creation of single and multiple OpportunityLineItem (Product) records via repository pattern.
 */
@IsTest
private class CCRMAgentCreateProductTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider actionRepoMock;

  /**
   * @description Registers mock providers for DmlRepository and CCRMAgentforceActionRepository
   */
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    actionRepoMock = Lib_MockProvider.forType(
      CCRMAgentforceActionRepository.class
    );
  }

  /**
   * @testSetup
   * @description Test setup method to register mocks. No DML is performed here.
   */
  @TestSetup
  static void setupTestData() {
    registerMocks();
    dmlRepoMock.mock('doInsert', new List<Database.SaveResult>());
  }

  // Value object to avoid excessive parameter list in helper methods
  private class ProductMockIds {
    Id oppId;
    Id pricebook2Id;
    Id productId;
    Id pbeId;
    ProductMockIds(Id oppId, Id pricebook2Id, Id productId, Id pbeId) {
      this.oppId = oppId;
      this.pricebook2Id = pricebook2Id;
      this.productId = productId;
      this.pbeId = pbeId;
    }
  }

  /**
   * @description Helper to prime repository mocks for a successful Product add flow
   * @param ids ProductMockIds
   */
  private static void primeProductHappyPathMocks(ProductMockIds ids) {
    Opportunity opp = (Opportunity) JSON.deserialize(
      '{"attributes":{"type":"Opportunity"},"Id":"' +
        (String) ids.oppId +
        '","Pricebook2Id":"' +
        (String) ids.pricebook2Id +
        '"}',
      Opportunity.class
    );
    actionRepoMock.mock('getOpportunityWithPricebook', opp);

    Product2 prod = (Product2) JSON.deserialize(
      '{"attributes":{"type":"Product2"},"Id":"' +
        (String) ids.productId +
        '"}',
      Product2.class
    );
    actionRepoMock.mock('getProductByCodes', prod);

    PricebookEntry pbe = (PricebookEntry) JSON.deserialize(
      '{"attributes":{"type":"PricebookEntry"},"Id":"' +
        (String) ids.pbeId +
        '"}',
      PricebookEntry.class
    );
    actionRepoMock.mock('getPricebookEntry', pbe);
  }

  /**
   * @description Positive test: Validates creation of a single OpportunityLineItem via invocable method
   */
  @IsTest
  static void testAddSingleProduct() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id pricebook2Id = Lib_FakeIdGenerator.getMockId(Pricebook2.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id pbeId = Lib_FakeIdGenerator.getMockId(PricebookEntry.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);

    primeProductHappyPathMocks(
      new ProductMockIds(oppId, pricebook2Id, productId, pbeId)
    );

    OpportunityLineItem oli = new OpportunityLineItem(
      Id = oliId,
      OpportunityId = oppId,
      PricebookEntryId = pbeId,
      UnitPrice = 123.45,
      Expected_Settlement_Date__c = Date.today().addDays(7)
    );
    actionRepoMock.mock(
      'getOpportunityLineItemsByIds',
      new List<OpportunityLineItem>{ oli }
    );

    List<Database.SaveResult> mockResults = new List<Database.SaveResult>{
      (Database.SaveResult) JSON.deserialize(
        '{"id":"' + (String) oliId + '","success":true,"errors":[]}',
        Database.SaveResult.class
      )
    };
    dmlRepoMock.mock('doInsert', mockResults);

    // Build input
    CCRMAgentCreateProduct.ProductInput input = new CCRMAgentCreateProduct.ProductInput();
    input.opportunityId = oppId;
    input.productCode = 'PROD_CODE';
    input.subProductCode = 'SUB_CODE';
    input.amount = 200;
    input.settlementDate = Date.today().addDays(7);

    List<CCRMAgentCreateProduct.ProductInput> inputs = new List<CCRMAgentCreateProduct.ProductInput>{
      input
    };

    Test.startTest();
    List<CCRMAgentCreateProduct.ProductOutput> results = CCRMAgentCreateProduct.addProduct(
      inputs
    );
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'Exactly one output expected for single input.'
    );
  }
}
