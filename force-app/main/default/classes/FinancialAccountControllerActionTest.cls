/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description FinancialAccountControllerActionTest is the test class for FinancialAccountControllerAction class
 */
@isTest
public with sharing class FinancialAccountControllerActionTest {
  @isTest
  public static void testProcessFinancialAccountsPositive() {
    Test.startTest();
    List<UnifiedFinancialAccountModel> groupedFinAccountList = FinancialAccountControllerAction.processFinancialAccounts(
      mockFabricFinancialAccounts
    );
    Test.stopTest();

    Assert.areEqual(
      groupedFinAccountList[0].isSaving,
      true,
      'Financial Accounts should be grouped by Product Code'
    );
  }

  @isTest
  public static void testProcessFinancialAccountsNegative() {
    Test.startTest();
    List<UnifiedFinancialAccountModel> groupedFinAccountList = FinancialAccountControllerAction.processFinancialAccounts(
      new List<UnifiedFinancialAccountModel.AccountList>()
    );
    Test.stopTest();

    Assert.areEqual(
      groupedFinAccountList.size(),
      0,
      'Financial Accounts are grouped and sorted'
    );
  }

  @isTest
  public static void testGroupAccountsPositive() {
    Test.startTest();
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.groupAccounts(
      mockFabricFinancialAccounts
    );
    Test.stopTest();

    Assert.areEqual(
      mapOfProductodeAndFinAccounts.containsKey('SAVING01'),
      true,
      'Financial Accounts should be grouped by SAVING01 Product Code'
    );
  }

  @isTest
  public static void testGroupAccountsNegative() {
    Test.startTest();
    Map<String, List<UnifiedFinancialAccountModel.AccountList>> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.groupAccounts(
      mockFabricFinancialAccounts
    );
    Test.stopTest();

    Assert.areEqual(
      mapOfProductodeAndFinAccounts.containsKey('SAVING02'),
      false,
      'Financial Accounts should not be grouped by SAVING02 Product Code'
    );
  }

  @isTest
  public static void testPrepareFinalUIResponsePositive() {
    Test.startTest();
    List<UnifiedFinancialAccountModel> mapOfProductodeAndFinAccounts = FinancialAccountControllerAction.prepareFinalUIResponse(
      mockGroupedAccounts()
    );
    Test.stopTest();

    Assert.areEqual(
      mapOfProductodeAndFinAccounts[0].isSaving,
      true,
      'Saving account should be set to true in the grouped Accounts'
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
}
