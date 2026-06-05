/**
 * @author       : Agentforce
 * @since        : 2026
 * @description  : Test class for CCRMAgentFetchMatchingProducts invocable Apex class
 **/
@IsTest
private class CCRMAgentFetchMatchingProductsTest {
  static Lib_MockProvider productRepoMock;

  static void registerMocks() {
    productRepoMock = Lib_MockProvider.forType(
      CCRMAgentforceActionRepository.class
    );
  }

  /**
   * @description Positive test: Validate output JSON contains matching products for a given search key
   */
  @IsTest
  static void testGetProductsPositive() {
    registerMocks();

    // Arrange: build fake Product2 results returned by repository
    List<Product2> products = new List<Product2>{
      new Product2(
        Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
        Name = 'Alpha Savings Account',
        ProductCode = 'ALPHA-SAV',
        Sub_Product_Code__c = 'SUB-ALPHA',
        Category__c = 'Deposits'
      ),
      new Product2(
        Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
        Name = 'Alpha Business Account',
        ProductCode = 'ALPHA-BUS',
        Sub_Product_Code__c = 'SUB-BUS',
        Category__c = 'Business'
      )
    };
    productRepoMock.mock('searchProducts', products);

    CCRMAgentFetchMatchingProducts.Request req = new CCRMAgentFetchMatchingProducts.Request();
    req.searchKey = 'Alpha';

    Test.startTest();
    List<CCRMAgentFetchMatchingProducts.Response> result = CCRMAgentFetchMatchingProducts.getProducts(
      new List<CCRMAgentFetchMatchingProducts.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(
      1,
      result.size(),
      'Response wrapper must return 1 item.'
    );
    System.assertNotEquals(
      null,
      result[0].promptResponse,
      'promptResponse should not be null.'
    );

    Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(
      result[0].promptResponse
    );
    List<Object> matchingProducts = (List<Object>) parsed.get(
      'matchingProducts'
    );
    System.assertEquals(
      2,
      matchingProducts.size(),
      'Should include 2 matching products.'
    );

    Map<String, Object> first = (Map<String, Object>) matchingProducts[0];
    System.assert(
      first.containsKey('productName'),
      'productName must be present.'
    );
  }

  /**
   * @description Negative test: No products found for the search key
   */
  @IsTest
  static void testGetProductsNoMatches() {
    registerMocks();

    productRepoMock.mock('searchProducts', new List<Product2>());

    CCRMAgentFetchMatchingProducts.Request req = new CCRMAgentFetchMatchingProducts.Request();
    req.searchKey = 'NoSuchKey';

    Test.startTest();
    List<CCRMAgentFetchMatchingProducts.Response> result = CCRMAgentFetchMatchingProducts.getProducts(
      new List<CCRMAgentFetchMatchingProducts.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(
      'No products found matching the search key.',
      result[0].promptResponse,
      'Should return message when no products match.'
    );
  }

  /**
   * @description Negative test: Null, empty, or blank search key input
   */
  @IsTest
  static void testGetProductsNullOrBlankInput() {
    Test.startTest();
    List<CCRMAgentFetchMatchingProducts.Response> result1 = CCRMAgentFetchMatchingProducts.getProducts(
      new List<CCRMAgentFetchMatchingProducts.Request>()
    );
    Test.stopTest();
    System.assertEquals(
      'No search key provided.',
      result1[0].promptResponse,
      'Empty input list should return message.'
    );
  }
}
