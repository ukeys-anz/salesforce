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
    Test.startTest();
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.groupByProductCode(
      mockFabricFinancialAccounts
    );
    Test.stopTest();

    Assert.isTrue(
      mapOfProductodeAndFinAccounts.get('SAVING01').size() > 0,
      'Financial Accounts should be grouped by Product Code'
    );
  }

  @isTest
  public static void testGroupByProductCodeNegative() {
    Test.startTest();
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> mapOfProductCodeAndFinAccounts = FinancialAccountControllerAction.groupByProductCode(
      new List<UnifiedFinancialAccountModel.AccountList>()
    );
    Test.stopTest();

    Assert.isTrue(
      mapOfProductCodeAndFinAccounts.size() == 0,
      'Financial Accounts should not be grouped'
    );
  }

  @isTest
  public static void testProcessMetadataAndBuildResponsePositive() {
    registerMocks();
    finAccRepoMock.mock('fetchMetadataForProductCodes', mockMetadataRecords());

    finAccRepoMock.mock(
      'mapProductCodeToFinAccounDetails',
      mockMetadataRecords()
    );

    Test.startTest();
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.groupByProductCode(
      mockFabricFinancialAccounts
    );
    Map<String, Object> processedFinancialAccounts = FinancialAccountControllerAction.processFinAccountUIConfiAndBuildResponse(
      mapOfProductodeAndFinAccounts
    );
    Test.stopTest();

    Assert.isNotNull(
      processedFinancialAccounts.get('groupedAccounts'),
      'The financial Accounts are grouped under groupedAccounts'
    );
  }

  @isTest
  public static void testBuildSortedGroupsPositive() {
    Test.startTest();
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.groupByProductCode(
      mockFabricFinancialAccounts
    );
    List<Map<String, Object>> processedFinancialAccounts = FinancialAccountControllerAction.buildSortedGroups(
      mapOfProductodeAndFinAccounts,
      mockProductTileSortOrderMap(),
      mockProductOwnershipOrderMap(),
      mockMetadataRecords()
    );
    Test.stopTest();

    Assert.areEqual(
      processedFinancialAccounts[0].get('sortOrder'),
      1,
      'The financial Accounts with sort order 1 should be at top'
    );
  }

  @isTest
  public static void testBuildSortedGroupsNegative() {
    Test.startTest();
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.groupByProductCode(
      mockFabricFinancialAccounts
    );
    List<Map<String, Object>> processedFinancialAccounts = FinancialAccountControllerAction.buildSortedGroups(
      mapOfProductodeAndFinAccounts,
      mockProductTileSortOrderMap(),
      mockProductOwnershipOrderMap(),
      mockMetadataRecords()
    );
    Test.stopTest();

    Assert.areEqual(
      processedFinancialAccounts[1].get('sortOrder'),
      999,
      'The financial Accounts with no metadata defined should have sortorder as 999'
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
  private static Map<String, FinancialAccountUIConfiguration__mdt> mockMetadataRecords() {
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

    Map<String, FinancialAccountUIConfiguration__mdt> productCodeToFinAccMap = new Map<String, FinancialAccountUIConfiguration__mdt>();
    for (FinancialAccountUIConfiguration__mdt finUIConfig : mockMetaData) {
      String key = finUIConfig?.Product_Code__c;
      if (!productCodeToFinAccMap.containsKey(key)) {
        productCodeToFinAccMap.put(key, finUIConfig);
      }
    }
    return productCodeToFinAccMap;
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
