/**
 * @author Peter Charalambous
 * @since December 2021
 * @description AccountBucketsControllerTest is the test class to cover tests for {@link AccountBucketsController}
 */
@isTest
public with sharing class AccountBucketsControllerTest {
  static Lib_MockProvider finAccRepoMock;

  static void registerMocks() {
    finAccRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class);
  }

  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'Accounts_Goals_Read_Only' });
  }
  /**
   * @description test method for getting account buckets when successful
   */
  @isTest
  public static void validResponseOnFinancialRecord() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      AccountBucketsModel response = AccountBucketsController.getAccountBuckets(
        '123',
        7,
        '',
        '111111111'
      );
      Assert.isTrue(
        response.account_buckets.size() == 7,
        'Response account buckets size should be as expected.'
      );
      Test.stopTest();
    }
  }

  /**
   * @description test method for getting account buckets when successful
   */
  @isTest
  public static void validResponseOnCustomerRecord() {
    registerMocks();
    finAccRepoMock.mock(
      'fetchFinancialAccountsByStatus',
      createMockFinancialAccount()
    );
    finAccRepoMock.mock(
      'mapProductCodeToFinAccountConfiguration',
      mockMetaDataRecord()
    );
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      AccountBucketsModel response = AccountBucketsController.getAccountBuckets(
        '123',
        7,
        '',
        ''
      );
      Assert.isTrue(
        response.account_buckets.size() == 7,
        'Response account buckets size should be as expected.'
      );
      Test.stopTest();
    }
  }

  private static List<FinServ__FinancialAccount__c> createMockFinancialAccount() {
    Id fakerAccountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType());
    Id fakerAccountRoleId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.getSObjectType()
    );
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Product2 product = new Product2(
      Id = productId,
      Name = 'Test Product',
      ANZ_Product_Code__c = 'SAVING01'
    );
    Account testAccount = TestDataFactory.createPersonAccount('1111', false);
    testAccount.Id = fakerAccountId;
    List<FinServ__FinancialAccount__c> financialAccountsList = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c finAccount1 = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.SAVINGS_ACCOUNT_RT_ID,
      fakerAccountRoleId,
      false
    );
    FinServ__FinancialAccount__c finAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      finAccount1,
      new Map<String, Object>{ 'Ownership__c' => 'Single' }
    );
    finAccount.FinServ__ProductName__r = product;
    finAccount.FinServ__FinancialAccountNumber__c = '111111111';
    financialAccountsList.add(finAccount);
    return financialAccountsList;
  }

  /**
   * @description helper method to create mock metadata records for FinancialAccountUIConfiguration__mdt
   * @return List<FinancialAccountUIConfiguration__mdt>
   */
  private static Map<String, FinancialAccountUIConfiguration__mdt> mockMetaDataRecord() {
    List<FinancialAccountUIConfiguration__mdt> mockMetaData = new List<FinancialAccountUIConfiguration__mdt>();
    FinancialAccountUIConfiguration__mdt dummyRecord1 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'SAVING01',
      Sort_Order__c = 1,
      Ownership_Type__c = 'Single',
      Show_Goals__c = true,
      Label = 'SAVING01'
    );
    mockMetaData.add(dummyRecord1);

    Map<String, FinancialAccountUIConfiguration__mdt> productCodeToFinAccMap = new Map<String, FinancialAccountUIConfiguration__mdt>();
    for (FinancialAccountUIConfiguration__mdt finUIConfig : mockMetaData) {
      String key =
        finUIConfig?.Product_Code__c +
        '-' +
        finUIConfig?.Ownership_Type__c;
      if (!productCodeToFinAccMap.containsKey(key)) {
        productCodeToFinAccMap.put(key, finUIConfig);
      }
    }
    return productCodeToFinAccMap;
  }
}
