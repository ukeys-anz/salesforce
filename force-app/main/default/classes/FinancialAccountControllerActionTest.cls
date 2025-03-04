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
}
