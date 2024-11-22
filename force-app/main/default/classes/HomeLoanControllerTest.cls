/**
 *
 * @author Vidhya Raghavan
 * @since January 2023
 * @description Test class for {@link HomeLoanController)
 */

@isTest
public inherited sharing class HomeLoanControllerTest {
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );
  private static final Id FAKER_FINACC_ID = Lib_FakeIdGenerator.getMockId(
    FinServ__FinancialAccount__c.getSObjectType()
  );

  static Lib_MockProvider farRepoMock;
  static void registerMocks() {
    farRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class);
  }

  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    Faker faker = new Faker('AU');
    Account homeLoanCustomer = new Account();
    homeLoanCustomer.Name = 'Test Account';
    homeLoanCustomer.OCV_ID__c = faker.randomString(5);
    homeLoanCustomer.ANZx_Customer__c = true;
    homeLoanCustomer.External_Id__c = faker.randomString(6);
    insert homeLoanCustomer;

    List<FinServ__FinancialAccount__c> finAccounts = TestDataFactory.createFinancialAccount(
      2,
      false
    );
    for (FinServ__FinancialAccount__c finAccount : finAccounts) {
      finAccount.Name = homeLoanCustomer.Name;
      finAccount.RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID;
      finAccount.FinServ__PrimaryOwner__c = homeLoanCustomer.Id;
    }

    finAccounts[0]
      .Marketing_Code__c = GetHelpConstants.HOME_LOAN_MARKETING_CODES[0];
    finAccounts[0].FinServ__FinancialAccountNumber__c = '111111111';

    insert finAccounts;
  }

  @isTest
  static void testHomeLoanAccountRetrieve() {
    Set<String> permissionSetAssigned = TestUtil.getUserPermissionSets(
      UserInfo.getUserId()
    );
    if (!permissionSetAssigned.contains('BoH_Read_Only')) {
      TestUtil.addPermissionSets(new List<String>{ 'BoH_Read_Only' });
    }
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      HomeLoanModel response = HomeLoanController.getHomeLoanAccount(
        '2222',
        null
      );

      Test.stopTest();
      System.assertEquals(
        1,
        response.accounts.size(),
        'Home loan found with ocvId and corresponding home loan marketing code'
      );
      System.assertEquals(
        '222222222',
        response.accounts[0].account_number,
        'Account number is corresponding to OCVId'
      );
    }
  }

  @IsTest
  static void testGetLinkedHomeLoanFinancialAccountRole() {
    Account homeLoanCustomer = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account'
    ];
    Test.startTest();
    List<FinServ__FinancialAccountRole__c> finAccountRoles = HomeLoanController.getLinkedHomeLoanFinancialAccountRole(
      homeLoanCustomer.Id
    );
    FinServ__FinancialAccount__c result = [
      SELECT FinServ__FinancialAccountNumber__c
      FROM FinServ__FinancialAccount__c
      WHERE Id = :finAccountRoles[0].FinServ__FinancialAccount__c
      LIMIT 1
    ];
    Assert.areEqual(
      '111111111',
      result.FinServ__FinancialAccountNumber__c,
      'One home loan marketing code fin account should be returned'
    );
    Test.stopTest();
  }

  @IsTest
  static void testGetAccountOwners() {
    registerMocks();
    farRepoMock.mock(
      'getAccountOwnerDetails',
      createMockFinancialAccountRole()
    );
    Test.startTest();
    List<FinServ__FinancialAccountRole__c> financialAccountRoles = HomeLoanController.getAccountOwnerIds(
      FAKER_FINACC_ID
    );
    Test.stopTest();
    Assert.isFalse(
      financialAccountRoles.isEmpty(),
      'getAccountOwnerIds should have been called and return no value'
    );
    Assert.isFalse(
      farRepoMock.getHistories('getAccountOwnerDetails').isEmpty(),
      'getAccountOwnerDetails should have been called and return a value'
    );
  }

  //This method is used to cover the repositoryClass
  @IsTest
  static void testFinancialAccountRepository() {
    FinancialAccountRepository fARepository = new FinancialAccountRepository();
    Test.startTest();
    List<FinServ__FinancialAccountRole__c> financialAccountRoles = fARepository.getAccountOwnerDetails(
      FAKER_FINACC_ID
    );
    Test.stopTest();
    Assert.isTrue(
      financialAccountRoles.isEmpty(),
      'getAccountOwnerDetails should have been called and return no value'
    );
  }

  private static List<FinServ__FinancialAccountRole__c> createMockFinancialAccountRole() {
    List<FinServ__FinancialAccountRole__c> financialAccountRoles = new List<FinServ__FinancialAccountRole__c>();
    FinServ__FinancialAccountRole__c finAccountRole = new FinServ__FinancialAccountRole__c(
      FinServ__RelatedAccount__c = FAKER_ACCOUNT_ID,
      FinServ__Active__c = true,
      FinServ__FinancialAccount__c = FAKER_FINACC_ID,
      FinServ__Role__c = 'Primary Owner',
      RecordTypeId = CCRMConstants.FAR_RT_ID,
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__FinancialAccountRole__c.getSObjectType()
      )
    );
    financialAccountRoles.add(finAccountRole);
    return financialAccountRoles;
  }

  @isTest
  static void testGetListOffset() {
    Test.startTest();
    OffsetAccountModel response = HomeLoanController.getListOffset(
      '2222',
      null,
      '121212'
    );
    Test.stopTest();
    Assert.isNotNull(response, 'Success Response');
  }

  @isTest
  static void testGetListOffsetException() {
    String ocvId = '11111231';
    String loanAccNumber = 'abcd';

    Test.startTest();
    OffsetAccountModel offsetDetails = HomeLoanController.getListOffset(
      ocvId,
      loanAccNumber,
      null
    );
    Test.stopTest();

    Assert.isTrue(offsetDetails.hasError, 'recordId is missing');
  }

  @isTest
  static void testGetListOffsetNullResponse() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = '1234';

    // Setting response for empty details
    HttpCalloutResponse res = getResponseWithEmptyList();
    Service finAccountService = ServiceProvider.getService(
      FinancialAccountService.class
    );
    finAccountService.setCalloutResponse(res);

    Test.startTest();
    OffsetAccountModel response = HomeLoanController.getListOffset(
      ocvId,
      loanAccNumber,
      recordId
    );
    Test.stopTest();

    Assert.isNull(response, 'No linked offset details available');
  }

  @isTest
  static void getListOffsetNotFoundException() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = '1234';

    // Setting response for NotFound error
    HttpCalloutResponse res = getNotFoundException();
    Service finAccountService = ServiceProvider.getService(
      FinancialAccountService.class
    );
    finAccountService.setCalloutResponse(res);
    Test.startTest();
    OffsetAccountModel offsetDetails = HomeLoanController.getListOffset(
      ocvId,
      loanAccNumber,
      recordId
    );
    Test.stopTest();

    Assert.isFalse(
      offsetDetails.hasError,
      'Should handle No Offset Found Exception'
    );
  }

  private static HttpCalloutResponse getNotFoundException() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 404;
    response.successful = false;
    response.body = null;
    response.error = new CalloutException(
      '{"code": "ERROR","additionalInfo": {"reason": "HTTP:NOT_FOUND","category": "TECHNICAL"}}'
    );
    return response;
  }

  private static HttpCalloutResponse getResponseWithEmptyList() {
    String emptyBody = '{"loanOffsets": []}';
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 200;
    response.successful = true;
    response.body = emptyBody;
    return response;
  }
}
