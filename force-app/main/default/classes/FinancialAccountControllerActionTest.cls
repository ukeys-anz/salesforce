/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description FinancialAccountControllerActionTest is the test class for FinancialAccountControllerAction class
 */
@isTest
public with sharing class FinancialAccountControllerActionTest {
  static Lib_MockProvider finAccRepoMock;

  static void registerMocks() {
    finAccRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class);
  }

  @isTest
  public static void testGroupByProductCodePositive() {
    registerMocks();

    finAccRepoMock.mock(
      'fetchFinancialAccountUIConfigInfo',
      mockfinAccountUiConfig()
    );

    Test.startTest();
    List<Map<String, Object>> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.processFinancialAccounts(
      mockFabricFinancialAccounts
    );
    Test.stopTest();

    Assert.areEqual(
      (Boolean) mapOfProductodeAndFinAccounts[0].get('isOthers'),
      true,
      'Financial Accounts should be grouped by Product Code'
    );
  }

  @isTest
  public static void testGroupByProductCodeNegative() {
    registerMocks();

    finAccRepoMock.mock(
      'fetchFinancialAccountUIConfigInfo',
      mockfinAccountUiConfig()
    );

    Test.startTest();
    List<Map<String, Object>> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.processFinancialAccounts(
      new List<UnifiedFinancialAccountModel.AccountList>()
    );
    Test.stopTest();

    Assert.areEqual(
      mapOfProductodeAndFinAccounts.size(),
      0,
      'Financial Accounts are grouped and sorted'
    );
  }

  /**
   * @description This method helps in providing the mock response from Fabric
   * @return Fabric financial accounts
   */
  private static List<UnifiedFinancialAccountModel.AccountList> mockFabricFinancialAccounts {
    get {
      String mockFabricFinancialAccountsResponse = [
          SELECT body
          FROM StaticResource
          WHERE Name = 'mock_FinancialAccountMappingv1'
        ]
        .body.toString();
      return UnifiedFinancialAccountModel.parse(
          mockFabricFinancialAccountsResponse
        )
        .accounts;
    }
  }

  /**
   * @description helper method to create mock metadata records in map format
   * @return map of product code and FinancialAccountUIConfiguration__mdt record
   */
  private static List<FinancialAccountUIConfiguration__mdt> mockfinAccountUiConfig() {
    List<FinancialAccountUIConfiguration__mdt> mockMetaData = new List<FinancialAccountUIConfiguration__mdt>();
    FinancialAccountUIConfiguration__mdt dummyRecord1 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'HOMELOAN1',
      Account_Type__c = 'Loan',
      Balance_Title__c = 'Loan Balance',
      Product_Name__c = 'ANZ Plus fixed Rate Home Loan',
      Section_Header_Title__c = 'Loan',
      Sort_Order__c = 1,
      Ownership_Type__c = 'Single'
    );
    mockMetaData.add(dummyRecord1);

    FinancialAccountUIConfiguration__mdt dummyRecord2 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'SAVING01',
      Account_Type__c = 'Savings',
      Balance_Title__c = 'Total Saved',
      Product_Name__c = 'ANZ Save',
      Section_Header_Title__c = 'Savings',
      Sort_Order__c = 3,
      Ownership_Type__c = 'Multi-Party'
    );

    FinancialAccountUIConfiguration__mdt dummyRecord3 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'SAVING01',
      Account_Type__c = 'Savings',
      Balance_Title__c = 'Total Saved',
      Product_Name__c = 'ANZ Save',
      Section_Header_Title__c = 'Savings',
      Sort_Order__c = 2,
      Ownership_Type__c = 'Single'
    );
    mockMetaData.add(dummyRecord2);

    return mockMetaData;
  }

  private static Map<String, Integer> mockProductTileSortOrderMap() {
    return new Map<String, Integer>{ 'HOMELOAN1' => 3, 'SAVING01' => 1 };
  }

  private static Map<String, Map<String, Integer>> mockProductOwnershipOrderMap() {
    Map<String, Map<String, Integer>> productOwnershipOrderMap = new Map<String, Map<String, Integer>>();

    productOwnershipOrderMap.put(
      'HOMELOAN1',
      new Map<String, Integer>{ 'Single' => 3 }
    );
    productOwnershipOrderMap.put(
      'SAVING01',
      new Map<String, Integer>{ 'Multi-Party' => 2, 'Single' => 1 }
    );

    return productOwnershipOrderMap;
  }
}
