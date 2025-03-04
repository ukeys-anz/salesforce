/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description FinancialAccountControllerTest is the test class for UnifiedFinancialAccountController class
 */
@isTest
public with sharing class FinancialAccountControllerTest {
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  static Lib_MockProvider finAccRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    finAccRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(
      new List<String>{
        'Accounts_Goals_Read_Only',
        'View_Card_Details',
        'View_Transaction_History'
      }
    );
  }

  @isTest
  public static void testGetFinancialAccountFabricPositive() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      registerMocks();
      finAccRepoMock.mock('getFinAccountList', createMockFinancialAccount());

      finAccRepoMock.mock(
        'fetchFinancialAccountUIConfigInfo',
        mockfinAccountUiConfig()
      );

      Test.startTest();
      Map<String, Object> processedfinancialAccounts = FinancialAccountController.getFinancialAccountFabric(
        '12345',
        null
      );
      Test.stopTest();

      Assert.isNotNull(
        processedfinancialAccounts.get('groupedAccounts'),
        'Financial Accounts are grouped and sorted'
      );
    }
  }

  @isTest
  public static void testGetFinancialAccountInstancePositive() {
    FinServ__FinancialAccount__c mockfinAccountFromDatabase = createMockFinancialAccount()[0];
    Test.startTest();
    UnifiedFinancialAccountModel.AccountList finAccountRecord = FinancialAccountController.getFinancialAccountInstance(
      mockFabricFinancialAccounts[0],
      mockfinAccountFromDatabase,
      mockProductCodeOwnershipToFinAccount()
    );
    Test.stopTest();

    Assert.areEqual(
      finAccountRecord.finserv_ownership,
      'Single',
      'Ownership should be updated with the database financial Account'
    );
  }

  @isTest
  public static void testGetFinancialAccountInstanceNegative() {
    Test.startTest();
    UnifiedFinancialAccountModel.AccountList finAccountRecord = FinancialAccountController.getFinancialAccountInstance(
      mockFabricFinancialAccounts[0],
      null,
      mockProductCodeOwnershipToFinAccount()
    );
    Test.stopTest();

    Assert.isNull(finAccountRecord.Id, 'Id node should be null');
  }

  @isTest
  public static void testGetFinancialAccountInstanceToUpdatePositive() {
    FinServ__FinancialAccount__c mockfinAccountFromDatabase = createMockFinancialAccount()[0];
    Id finAccId = mockfinAccountFromDatabase.id;

    Test.startTest();
    FinServ__FinancialAccount__c finAccountToUpdate = FinancialAccountController.getFinancialAccountInstanceToUpdate(
      mockFabricFinancialAccounts[0],
      mockfinAccountFromDatabase
    );
    Test.stopTest();

    Assert.areEqual(
      finAccountToUpdate.Id,
      finAccId,
      'Id node should be updated with the database financial Account Id'
    );
  }

  @isTest
  public static void testGetFinancialAccountInstanceToUpdateNegative() {
    FinServ__FinancialAccount__c mockfinAccountFromDatabase = createMockFinancialAccount()[0];

    Test.startTest();
    FinServ__FinancialAccount__c finAccountToUpdate = FinancialAccountController.getFinancialAccountInstanceToUpdate(
      mockFabricFinancialAccounts[2],
      mockfinAccountFromDatabase
    );
    Test.stopTest();

    Assert.isNull(
      finAccountToUpdate.FinServ__CloseDate__c,
      'Close date node should be null'
    );
  }

  @isTest
  public static void testFilterOutNonHomeLoanAccountsPositive() {
    registerMocks();

    finAccRepoMock.mock(
      'fetchFinancialAccountUIConfigInfo',
      mockfinAccountUiConfig()
    );

    Test.startTest();
    List<UnifiedFinancialAccountModel.AccountList> homeloanAccountList = FinancialAccountController.filterOutNonHomeLoanAccounts(
      mockFabricFinancialAccounts
    );
    Test.stopTest();

    Assert.isTrue(
      homeloanAccountList.size() > 0,
      'Home Loan Financial Accounts are filtered'
    );
  }

  @isTest
  public static void testGetFinancialAccountDBPositive() {
    registerMocks();

    finAccRepoMock.mock(
      'getAllAccountNumberPerOwner',
      mockFinancialAccountRoles()
    );

    finAccRepoMock.mock('getFinacialAccounts', createMockFinancialAccount());

    finAccRepoMock.mock(
      'fetchFinancialAccountUIConfigInfo',
      mockfinAccountUiConfig()
    );

    Test.startTest();
    Map<String, Object> processedfinancialAccountsDB = FinancialAccountController.getFinancialAccountDB(
      '12345',
      FAKER_ACCOUNT_ID
    );
    Test.stopTest();

    Assert.isTrue(
      processedfinancialAccountsDB.size() > 0,
      'Financial Accounts are grouped and sorted based on Database data'
    );
  }

  @isTest
  public static void testGetFinancialAccountDBNegative() {
    registerMocks();

    finAccRepoMock.mock(
      'getAllAccountNumberPerOwner',
      mockFinancialAccountRoles()
    );

    finAccRepoMock.mock(
      'getFinacialAccounts',
      new List<FinServ__FinancialAccount__c>()
    );

    finAccRepoMock.mock(
      'fetchFinancialAccountUIConfigInfo',
      mockfinAccountUiConfig()
    );

    Test.startTest();
    Map<String, Object> processedfinancialAccountsDB = FinancialAccountController.getFinancialAccountDB(
      '12345',
      FAKER_ACCOUNT_ID
    );
    Test.stopTest();

    Assert.areEqual(
      0,
      processedfinancialAccountsDB.size(),
      'No Financial accounts are received'
    );
  }

  @isTest
  public static void testFetchAllFinancialAccountsDBPositive() {
    registerMocks();
    finAccRepoMock.mock(
      'getAllAccountNumberPerOwner',
      mockFinancialAccountRoles()
    );

    finAccRepoMock.mock('getFinacialAccounts', createMockFinancialAccount());

    finAccRepoMock.mock(
      'fetchFinancialAccountUIConfigInfo',
      mockfinAccountUiConfig()
    );

    Test.startTest();
    List<UnifiedFinancialAccountModel.AccountList> convertedFinancialAccountsToJson = FinancialAccountController.fetchAllFinancialAccountsDB(
      FAKER_ACCOUNT_ID
    );
    Test.stopTest();

    Assert.areEqual(
      convertedFinancialAccountsToJson[0].finserv_ownership,
      'Single',
      'Financial account ownership is updated on the json node finserv_ownership'
    );
  }

  @isTest
  public static void testFetchAllFinancialAccountsDBNegative() {
    registerMocks();
    finAccRepoMock.mock(
      'getAllAccountNumberPerOwner',
      mockFinancialAccountRoles()
    );

    finAccRepoMock.mock(
      'getFinacialAccounts',
      new List<FinServ__FinancialAccount__c>()
    );

    finAccRepoMock.mock(
      'fetchFinancialAccountUIConfigInfo',
      mockfinAccountUiConfig()
    );

    Test.startTest();
    List<UnifiedFinancialAccountModel.AccountList> convertedFinancialAccountsToJson = FinancialAccountController.fetchAllFinancialAccountsDB(
      FAKER_ACCOUNT_ID
    );
    Test.stopTest();

    Assert.areEqual(
      0,
      convertedFinancialAccountsToJson.size(),
      'No Financial accounts are received'
    );
  }

  @isTest
  public static void testFetchOCVIdFromAccount() {
    Test.startTest();
    String ocvId = FinancialAccountController.fetchOCVIdFromAccount(
      FAKER_ACCOUNT_ID
    );
    Test.stopTest();
    Assert.isNull(
      ocvId,
      'Ocv Id should be null as we are passing fake record Id'
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

  private static List<FinancialAccountUIConfiguration__mdt> mockfinAccountUiConfig() {
    List<FinancialAccountUIConfiguration__mdt> mockMetaData = new List<FinancialAccountUIConfiguration__mdt>();
    FinancialAccountUIConfiguration__mdt dummyRecord1 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'HOMELOAN1',
      Account_Type__c = 'Loan',
      Balance_Title__c = 'Loan Balance',
      Section_Header_Title__c = 'Loan',
      Sort_Order__c = 1,
      Ownership_Type__c = 'Single',
      Show_Goals__c = false
    );
    mockMetaData.add(dummyRecord1);

    FinancialAccountUIConfiguration__mdt dummyRecord2 = new FinancialAccountUIConfiguration__mdt(
      Product_Code__c = 'SAVING01',
      Account_Type__c = 'Savings',
      Balance_Title__c = 'Total Saved',
      Section_Header_Title__c = 'Savings',
      Sort_Order__c = 2,
      Ownership_Type__c = 'Single',
      Show_Goals__c = true
    );
    mockMetaData.add(dummyRecord2);

    return mockMetaData;
  }

  private static Map<String, FinancialAccountUIConfiguration__mdt> mockProductCodeOwnershipToFinAccount() {
    Map<String, FinancialAccountUIConfiguration__mdt> productCodeOwnershipToFinAccMap = new Map<String, FinancialAccountUIConfiguration__mdt>();
    for (
      FinancialAccountUIConfiguration__mdt finUIConfig : mockfinAccountUiConfig()
    ) {
      String key =
        finUIConfig.Product_Code__c +
        '-' +
        finUIConfig.Ownership_Type__c;
      if (!productCodeOwnershipToFinAccMap.containsKey(key)) {
        productCodeOwnershipToFinAccMap.put(key, finUIConfig);
      }
    }
    return productCodeOwnershipToFinAccMap;
  }

  private static List<FinServ__FinancialAccount__c> createMockFinancialAccount() {
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Product2 product = new Product2(
      Id = productId,
      Name = 'Test Product',
      ANZ_Product_Code__c = 'SAVING01'
    );
    Account testAccount = TestDataFactory.createPersonAccount('1111', false);
    testAccount.Id = FAKER_ACCOUNT_ID;
    List<FinServ__FinancialAccount__c> financialAccountsList = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c finAccount1 = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.SAVINGS_ACCOUNT_RT_ID,
      FAKER_ACCOUNT_ID,
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

  private static List<FinServ__FinancialAccountRole__c> mockFinancialAccountRoles() {
    List<FinServ__FinancialAccountRole__c> finAccountRoleList = new List<FinServ__FinancialAccountRole__c>();

    FinServ__FinancialAccountRole__c finAccountRole = new FinServ__FinancialAccountRole__c();
    finAccountRole.FinServ__RelatedAccount__c = FAKER_ACCOUNT_ID;
    finAccountRole.FinServ__Active__c = true;
    finAccountRoleList.add(finAccountRole);

    return finAccountRoleList;
  }
}
