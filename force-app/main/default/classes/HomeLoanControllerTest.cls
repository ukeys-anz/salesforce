/**
 *
 * @author Vidhya Raghavan
 * @since January 2023
 * @description Test class for {@link HomeLoanController)
 */

@isTest
public inherited sharing class HomeLoanControllerTest {
  static Lib_MockProvider farRepoMock;
  static Lib_MockProvider homeLoanAPIRepoMock;
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );
  private static final Id FAKER_FINACC_ID = Lib_FakeIdGenerator.getMockId(
    FinServ__FinancialAccount__c.getSObjectType()
  );

  static void registerMocks() {
    farRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class);
    homeLoanAPIRepoMock = Lib_MockProvider.forType(HomeLoanAPIRepository.class);
  }

  static OffsetAccountModel mockLinkedOffsetAccount = OffsetAccountModel.parse(
    Service.getStaticResource('mock_linkedOffsetAccount')
  );

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

  /**
   * @description Test Success scenarios for Get List Offset
   */
  @isTest
  static void testGetListOffset() {
    String ocvId = '11111231';
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    registerMocks();
    farRepoMock.mock(
      'getFinAccountList',
      new List<FinServ__FinancialAccount__c>{ getFinancialAccount }
    );
    homeLoanAPIRepoMock.mock('getOffsetAccounts', mockLinkedOffsetAccount);
    Test.startTest();
    OffsetAccountModel response = HomeLoanController.getListOffset(
      ocvId,
      null,
      recordId
    );
    Test.stopTest();
    Assert.isNotNull(response, 'Success Response');
    Assert.areEqual(
      'accounts/111111113',
      response.loanOffsets[0].offsetAccounts[0],
      'Should get the Offset for the loan account'
    );
  }

  /**
   * @description Test Server Error scenarios for Get List Offset
   */
  @isTest
  static void testGetListOffsetException() {
    String ocvId = '11111231';
    String loanAccNumber = '1234';
    try {
      HttpCalloutResponse errorResponse = new HttpCalloutResponse();
      errorResponse.successful = false;
      errorResponse.statusCode = 500;
      errorResponse.error = new CalloutException('callout failed');
      registerMocks();

      homeLoanAPIRepoMock.mockException(
        'getOffsetAccounts',
        new HomeLoanAPIRepository.ServerErrorException(
          errorResponse,
          'getOffsetAccounts'
        )
      );

      Test.startTest();
      HomeLoanController.getListOffset(ocvId, loanAccNumber, FAKER_FINACC_ID);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  /**
   * @description Test Error scenarios for Get List Offset with Null response
   */
  @isTest
  static void testGetListOffsetNullResponse() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = '1234';

    HttpCalloutResponse emptyResponse = new HttpCalloutResponse();
    emptyResponse.statusCode = 200;
    emptyResponse.successful = true;
    emptyResponse.body = '{"loanOffsets": []}';

    OffsetAccountModel offsetModel = OffsetAccountModel.parse(
      emptyResponse.body
    );
    registerMocks();
    homeLoanAPIRepoMock.mock('getOffsetAccounts', offsetModel);

    Test.startTest();
    OffsetAccountModel response = HomeLoanController.getListOffset(
      ocvId,
      loanAccNumber,
      recordId
    );
    Test.stopTest();
    Assert.isNull(response, 'No linked offset details available');
  }

  /**
   * @description Test Error scenarios for Get List Offset with Not Found error
   */
  @isTest
  static void testGetListOffsetNotFoundException() {
    String ocvId = '11111231';
    String loanAccNumber = '1234';

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException(
      '{"code": "ERROR","additionalInfo": {"reason": "HTTP:NOT_FOUND","category": "TECHNICAL"}}'
    );
    errorResponse.body = null;
    errorResponse.successful = false;
    errorResponse.statusCode = 404;

    registerMocks();
    homeLoanAPIRepoMock.mockException(
      'getOffsetAccounts',
      new HomeLoanAPIRepository.UserErrorException(
        errorResponse,
        'get Offset Accounts'
      )
    );

    Test.startTest();
    OffsetAccountModel response = HomeLoanController.getListOffset(
      ocvId,
      loanAccNumber,
      FAKER_FINACC_ID
    );
    Test.stopTest();
    Assert.isNull(response, 'Should return null response');
  }

  /**
   * @description Static method to return FinServ__FinancialAccount__c
   */
  static FinServ__FinancialAccount__c getFinancialAccount {
    get {
      return new FinServ__FinancialAccount__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__FinancialAccount__c.SObjectType
        ),
        FinServ__FinancialAccountNumber__c = '391450876'
      );
    }
  }
}
