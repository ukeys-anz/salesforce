/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description FinancialAccountControllerActionTest is the test class for FinancialAccountControllerAction class
 */
@isTest
public with sharing class FinancialAccountControllerActionTest {
  private static final Integer DEFAULT_SORT_ORDER = 999;
  static Lib_MockProvider finAccRepoMock;

  static void registerMocks() {
    finAccRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class);
  }

  @isTest
  public static void testProcessFinancialAccountsPositive() {
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
      (Boolean) mapOfProductodeAndFinAccounts[1].get('isSaving'),
      true,
      'Financial Accounts should be grouped by Product Code'
    );
  }

  @isTest
  public static void testProcessFinancialAccountsNegative() {
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

  @isTest
  public static void testSortAndFormatResponsePositive() {
    Test.startTest();
    List<Map<String, Object>> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.sortAndFormatResponse(
      mockGroupedAccounts(),
      mockProductTileSortOrderMap(),
      mockUiConfigMap()
    );
    Test.stopTest();

    Assert.areEqual(
      (Integer) mapOfProductodeAndFinAccounts[0].get('sortOrder'),
      1,
      'Saving account should be first in the grouped Accounts'
    );
    Assert.areEqual(
      (Integer) mapOfProductodeAndFinAccounts[1].get('sortOrder'),
      3,
      'Home Loan account should be second in the grouped Accounts'
    );
    Assert.areEqual(
      (Integer) mapOfProductodeAndFinAccounts[2].get('sortOrder'),
      DEFAULT_SORT_ORDER,
      'Everyday account should be third in the grouped Accounts'
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
   * @description This method helps in providing the mock response from Fabric
   * @return Fabric financial accounts
   */
  private static Map<String, List<UnifiedFinancialAccountModel.AccountList>> mockGroupedAccounts() {
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> mockgroupedFinAccount = new Map<String, List<UnifiedFinancialAccountModel.AccountList>>();
    List<UnifiedFinancialAccountModel.AccountList> finAccountList = mockFabricFinancialAccounts;
    List<UnifiedFinancialAccountModel.AccountList> savingFinAccount = new List<UnifiedFinancialAccountModel.AccountList>();
    savingFinAccount.add(finAccountList[0]);
    List<UnifiedFinancialAccountModel.AccountList> everydayFinAccount = new List<UnifiedFinancialAccountModel.AccountList>();
    everydayFinAccount.add(finAccountList[1]);
    List<UnifiedFinancialAccountModel.AccountList> homeLoanFinAccount = new List<UnifiedFinancialAccountModel.AccountList>();
    homeLoanFinAccount.add(finAccountList[2]);

    mockgroupedFinAccount.put('SAVING01', savingFinAccount);
    mockgroupedFinAccount.put('TRANSACT01', everydayFinAccount);
    mockgroupedFinAccount.put('HOMELOAN1', homeLoanFinAccount);
    return mockgroupedFinAccount;
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
      Section_Header_Title__c = 'Loan',
      Sort_Order__c = 1,
      Is_Active__c = true,
      Ownership_Type__c = 'Single'
    );

    mockMetaData.add(dummyRecord1);

    FinancialAccountUIConfiguration__mdt dummyRecord2 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'SAVING01',
      Account_Type__c = 'Savings',
      Balance_Title__c = 'Total Saved',
      Section_Header_Title__c = 'Savings',
      Sort_Order__c = 3,
      Ownership_Type__c = 'Multi-Party',
      Is_Active__c = true
    );

    mockMetaData.add(dummyRecord2);

    FinancialAccountUIConfiguration__mdt dummyRecord3 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'SAVING01',
      Account_Type__c = 'Savings',
      Balance_Title__c = 'Total Saved',
      Section_Header_Title__c = 'Savings',
      Sort_Order__c = 2,
      Ownership_Type__c = 'Single',
      Is_Active__c = true
    );
    mockMetaData.add(dummyRecord3);

    return mockMetaData;
  }

  private static Map<String, Integer> mockProductTileSortOrderMap() {
    return new Map<String, Integer>{ 'HOMELOAN1' => 3, 'SAVING01' => 1 };
  }

  private static Map<String, FinancialAccountUIConfiguration__mdt> mockUiConfigMap() {
    Map<String, FinancialAccountUIConfiguration__mdt> productCodeToFinAccMap = new Map<String, FinancialAccountUIConfiguration__mdt>();
    for (
      FinancialAccountUIConfiguration__mdt finUIConfig : mockfinAccountUiConfig()
    ) {
      {
        productCodeToFinAccMap.put(finUIConfig.Product_Code__c, finUIConfig);
      }
    }
    return productCodeToFinAccMap;
  }
}
