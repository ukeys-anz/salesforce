/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TotalBalanceControllerTest is the test class to cover tests for {@link TotalBalanceController}
 */
@isTest
public with sharing class TotalBalanceControllerTest {
  static Lib_MockProvider userMock;

  static void registerMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
  }

  /**
   * @description setup is to setup test data
   */
  @testSetup
  static void setup() {
    createFinancialAccount();
  }

  /**
   * @description testBalanceRetrieval is to test total balance is retrieved successfully
   */
  @isTest
  public static void testBalanceRetrieval() {
    registerMocks();
    Account accnt = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = '1111'
      LIMIT 1
    ];
    Test.startTest();

    TotalBalanceController.FinancialSummaryWrapper result = TotalBalanceController.getTotalBalance(
      accnt.Id
    );

    Test.stopTest();

    Assert.areEqual(
      400,
      result.aggregateResult.get('totalBalance'),
      'Total Balance should be summation of both the accounts balance'
    );
  }

  /**
   * @description testBalanceRetrieval is to test total balance is retrieved successfully
   */
  @isTest
  public static void testTotalSavedRetrieval() {
    Test.startTest();
    Account accnt = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = '1111'
      LIMIT 1
    ];
    TotalBalanceController.FinancialSummaryWrapper result = TotalBalanceController.getTotalSaved(
      accnt.Id
    );

    Test.stopTest();

    Assert.areEqual(
      200,
      result.aggregateResult.get('totalBalance'),
      'Total Balance should be only the saving account balance'
    );
  }

  private static void createFinancialAccount() {
    Id productId1 = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Product2 product1 = new Product2(
      Id = productId1,
      Name = 'Test Product',
      ANZ_Product_Code__c = 'SAVING01'
    );
    Account testAccount = TestDataFactory.createPersonAccount('1111', true);

    List<FinServ__FinancialAccount__c> financialAccountsList = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c finAccount1 = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.SAVINGS_ACCOUNT_RT_ID,
      testAccount.Id,
      true
    );
    FinServ__FinancialAccount__c savingAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      finAccount1,
      new Map<String, Object>{ 'Ownership__c' => 'Single' }
    );
    savingAccount.FinServ__ProductName__r = product1;
    savingAccount.FinServ__FinancialAccountNumber__c = '111111111';
    savingAccount.FinServ__Balance__c = 200;
    savingAccount.Marketing_Code__c = 'SAVING01';
    financialAccountsList.add(savingAccount);

    FinServ__FinancialAccount__c finAccount2 = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.CHECKING_ACCOUNT_RT_ID,
      testAccount.Id,
      true
    );
    FinServ__FinancialAccount__c checkingAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      finAccount2,
      new Map<String, Object>{ 'Ownership__c' => 'Single' }
    );
    checkingAccount.FinServ__FinancialAccountNumber__c = '000000000';
    checkingAccount.FinServ__Balance__c = 200;
    checkingAccount.Marketing_Code__c = 'TRANSACT01';
    financialAccountsList.add(checkingAccount);

    update financialAccountsList;
  }
}
