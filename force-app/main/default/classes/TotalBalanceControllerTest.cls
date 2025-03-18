/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TotalBalanceControllerTest is the test class to cover tests for {@link TotalBalanceController}
 */
@isTest
public with sharing class TotalBalanceControllerTest {
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  static Lib_MockProvider userMock;
  static Lib_MockProvider finAccRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
    finAccRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class)
      .mock('getAllAccountNumberPerOwner', mockFinancialAccountRoles())
      .mock('getAllSavingsAccountNumberPerOwner', mockFinancialAccountRoles())
      .mock('getTotalBalance', mockAggregateResult());
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  /**
   * @description setup is to setup test data
   */
  @testSetup
  static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'Accounts_Goals_Read_Only' });
  }

  /**
   * @description testProductNameRetrieval is to test products for all accounts is retrieved successfully
   */
  @isTest
  public static void testProductNameRetrievalPositive() {
    registerMocks();
    Test.startTest();

    TotalBalanceController.FinancialSummaryWrapper result = TotalBalanceController.getTotalBalance(
      FAKER_ACCOUNT_ID
    );

    Test.stopTest();

    List<String> actualAggregateResult = (List<String>) result.productNames;
    Assert.isTrue(
      actualAggregateResult.contains('ANZ Plus Saver'),
      'Product Name fetched should be matching with the expected result'
    );
  }

  /**
   * @description testProductNameRetrieval is to test np products is retrieved when no valid accounts present
   */
  @isTest
  public static void testProductNameRetrievalNegative() {
    registerMocks();

    finAccRepoMock.mock(
      'getAllAccountNumberPerOwner',
      new List<FinServ__FinancialAccountRole__c>()
    );

    Test.startTest();

    TotalBalanceController.FinancialSummaryWrapper result = TotalBalanceController.getTotalBalance(
      FAKER_ACCOUNT_ID
    );

    Test.stopTest();

    List<String> actualAggregateResult = (List<String>) result.productNames;
    Assert.isTrue(
      actualAggregateResult.isEmpty(),
      'Product Name fetched should not be Matching with the expected result'
    );
  }

  /**
   * @description testProductNameRetrieval is to test np products is retrieved when no valid accounts present
   */
  @isTest
  public static void testSavingsProductNameRetrievalPositive() {
    registerMocks();

    Test.startTest();
    TotalBalanceController.FinancialSummaryWrapper result = TotalBalanceController.getTotalSaved(
      FAKER_ACCOUNT_ID
    );
    Test.stopTest();

    List<String> actualAggregateResult = (List<String>) result.productNames;
    Assert.isTrue(
      actualAggregateResult.contains('ANZ Plus Saver'),
      'Product Name fetched should be matching with the expected result'
    );
  }

  /**
   * @description testProductNameRetrieval is to test np products is retrieved when no valid accounts present
   */
  @isTest
  public static void testSavingsProductNameRetrievalNegative() {
    registerMocks();

    finAccRepoMock.mock(
      'getAllSavingsAccountNumberPerOwner',
      new List<FinServ__FinancialAccountRole__c>()
    );

    Test.startTest();

    TotalBalanceController.FinancialSummaryWrapper result = TotalBalanceController.getTotalSaved(
      FAKER_ACCOUNT_ID
    );

    Test.stopTest();

    List<String> actualAggregateResult = (List<String>) result.productNames;
    Assert.isTrue(
      actualAggregateResult.isEmpty(),
      'Product Name fetched should not be Matching with the expected result'
    );
  }

  private static List<FinServ__FinancialAccountRole__c> mockFinancialAccountRoles() {
    Id productId1 = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Product2 product1 = new Product2(
      Id = productId1,
      Name = 'ANZ Plus Saver',
      ANZ_Product_Code__c = 'SAVING01'
    );

    FinServ__FinancialAccount__c finAccount1 = TestDataFactory.createFinancialAccountRecord(
      RTFinancialAccount.savingAccount,
      FAKER_ACCOUNT_ID,
      false
    );
    FinServ__FinancialAccount__c finAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      finAccount1,
      new Map<String, Object>{ 'Ownership__c' => 'Single' }
    );
    finAccount.FinServ__ProductName__r = product1;
    finAccount.FinServ__FinancialAccountNumber__c = '111111111';
    finAccount.Marketing_Code__c = 'SAVING01';
    finAccount.FinServ__Balance__c = 400.00;
    finAccount.FinServ__Status__c = 'Active';

    List<FinServ__FinancialAccountRole__c> finAccountRoleList = new List<FinServ__FinancialAccountRole__c>();

    FinServ__FinancialAccountRole__c finAccountRole = new FinServ__FinancialAccountRole__c();
    finAccountRole.FinServ__FinancialAccount__c = finAccount1.Id;
    finAccountRole.FinServ__RelatedAccount__c = FAKER_ACCOUNT_ID;
    finAccountRole.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.SObjectType
    );

    FinServ__FinancialAccountRole__c finAccountRoleRecord = (FinServ__FinancialAccountRole__c) TestUtil.setFields(
      finAccountRole,
      new Map<String, Object>{
        'Account_Number__c' => '111111111',
        'Product_Name_Display__c' => 'ANZ Plus Saver'
      }
    );

    finAccountRoleList.add(finAccountRoleRecord);
    return finAccountRoleList;
  }

  private static AggregateResult mockAggregateResult() {
    String jsonAggr = '[{"totalBalance":400}]';
    List<AggregateResult> mockResult = (List<AggregateResult>) JSON.deserialize(
      jsonAggr,
      List<AggregateResult>.class
    );
    return mockResult[0];
  }
}
