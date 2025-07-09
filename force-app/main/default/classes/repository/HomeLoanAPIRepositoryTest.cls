/**
 * @author Vidhya Raghavan
 * @date December 2022
 * @description Test class for {@link HomeLoanAPIRepository}
 * @group repository
 */

@isTest
public inherited sharing class HomeLoanAPIRepositoryTest {
  static Lib_MockProvider finAccServiceMock;
  static Lib_MockProvider homeLoanServiceMock;
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'BoH_Read_Only' });
  }

  static void registerMocks() {
    finAccServiceMock = Lib_MockProvider.forType(FinancialAccountService.class);
    homeLoanServiceMock = Lib_MockProvider.forType(HomeLoanService.class);
  }

  @isTest
  static void testGetHomeLoanAccountsSuccess() {
    String ocvId = '2222';

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource('mock_homeloanaccounts');
    successResponse.successful = true;
    successResponse.statusCode = 200;

    registerMocks();
    homeLoanServiceMock.mock('getHomeLoanAccounts', successResponse);
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      HomeLoanAPIRepository homeLoan = new HomeLoanAPIRepository();
      HomeLoanModel model = homeLoan.getHomeLoanAccounts(ocvId, null);
      Test.stopTest();

      Assert.areEqual(
        1,
        model.accounts.size(),
        'No home loan found with ocvId'
      );
      // Check if the data is stored in cache
      HomeLoanModel cachedData = (HomeLoanModel) DataPartitionUtil.getDataFromCache(
        ocvId
      );
      Assert.areEqual(
        '222222222',
        cachedData.accounts[0].account_number,
        'Account number is corresponding to OCVId'
      );
    }
  }

  @isTest
  static void testGetHomeLoanAccountsCache() {
    String ocvId = '11111231';

    HomeLoanModel mockHomeLoanAccount = HomeLoanModel.parse(
      Service.getStaticResource('mock_homeloanaccounts')
    );

    // Storing the data in cache
    DataPartitionUtil.storeDataToCache(ocvId, mockHomeLoanAccount);
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      HomeLoanAPIRepository homeLoan = new HomeLoanAPIRepository();
      HomeLoanModel model = homeLoan.getHomeLoanAccounts(ocvId, null);
      Test.stopTest();

      Assert.areEqual(
        '390899612',
        model.accounts[0].account_number,
        'Should get the home loan details from Cache'
      );
    }
  }

  @isTest
  static void testGetHomeLoanAccountsServerException() {
    String ocvId = '11111231';

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.successful = false;
    errorResponse.statusCode = 500;

    registerMocks();
    homeLoanServiceMock.mock('getHomeLoanAccounts', errorResponse);
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      try {
        Test.startTest();
        HomeLoanAPIRepository homeLoan = new HomeLoanAPIRepository();
        homeLoan.getHomeLoanAccounts(ocvId, null);
        Test.stopTest();

        Assert.fail('An Exception should be thrown');
      } catch (Exception exp) {
        Assert.isInstanceOfType(
          exp,
          HomeLoanAPIRepository.ServerErrorException.class,
          'Exception should be an instanceof HomeLoanAPIRepository.ServerErrorException.'
        );

        Assert.areEqual(
          'callout failed',
          exp.getMessage(),
          'Should throw callout failed exception'
        );
      }
    }
  }

  @isTest
  static void testGetHomeLoanAccountsUserException() {
    String ocvId = '11111231';

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.successful = false;
    errorResponse.statusCode = 400;

    registerMocks();
    homeLoanServiceMock.mock('getHomeLoanAccounts', errorResponse);
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      try {
        Test.startTest();
        HomeLoanAPIRepository homeLoan = new HomeLoanAPIRepository();
        homeLoan.getHomeLoanAccounts(ocvId, null);
        Test.stopTest();

        Assert.fail('An Exception should be thrown');
      } catch (Exception exp) {
        Assert.isInstanceOfType(
          exp,
          HomeLoanAPIRepository.UserErrorException.class,
          'Exception should be an instanceof HomeLoanAPIRepository.UserErrorException.'
        );

        Assert.areEqual(
          'callout failed',
          exp.getMessage(),
          'Should throw callout failed exception'
        );
      }
    }
  }

  @isTest
  static void testGetHomeLoanAccountsUnhandledException() {
    String ocvId = '11111231';

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.body = null;
    errorResponse.successful = false;
    errorResponse.error = new CalloutException('callout failed');

    registerMocks();
    homeLoanServiceMock.mock('getHomeLoanAccounts', errorResponse);
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      try {
        Test.startTest();
        HomeLoanAPIRepository homeLoan = new HomeLoanAPIRepository();
        homeLoan.getHomeLoanAccounts(ocvId, null);
        Test.stopTest();

        Assert.fail('An Exception should be thrown');
      } catch (Exception exp) {
        Assert.isInstanceOfType(
          exp,
          HomeLoanAPIRepository.UnhandledException.class,
          'Exception should be an instanceof HomeLoanAPIRepository.UnhandledException.'
        );
      }
    }
  }

  @isTest
  static void testGetOffsetAccountsSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = '111111111';

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource(
      'mock_linkedOffsetAccount'
    );
    successResponse.successful = true;
    successResponse.statusCode = 200;

    registerMocks();
    finAccServiceMock.mock('getOffsetAccounts', successResponse);

    Test.startTest();
    HomeLoanAPIRepository offsetApi = new HomeLoanAPIRepository();
    OffsetAccountModel responseModel = offsetApi.getOffsetAccounts(
      ocvId,
      loanAccNumber,
      recordId
    );
    Test.stopTest();

    Assert.areEqual(
      loanAccNumber,
      responseModel.loanOffsets[0].loanAccount,
      'Should get the Offset for the loan account'
    );
    // Check if the data is stored in cache
    OffsetAccountModel cachedData = (OffsetAccountModel) DataPartitionUtil.getDataFromCache(
      recordId
    );
    Assert.areEqual(
      loanAccNumber,
      cachedData.loanOffsets[0].loanAccount,
      'Should get the Offset for the loan account'
    );
  }

  @isTest
  static void testGetOffsetAccountsCache() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = '111111111';
    StaticResource mockResponse = [
      SELECT Body
      FROM StaticResource
      WHERE Name = 'mock_linkedOffsetAccount'
      WITH SECURITY_ENFORCED
    ];

    // Storing the data in cache
    String offsetStr = (mockResponse.Body.toString()).replace('accounts/', '');
    OffsetAccountModel offsetDetails = OffsetAccountModel.parse(offsetStr);
    DataPartitionUtil.storeDataToCache(recordId, offsetDetails);

    Test.startTest();
    HomeLoanAPIRepository offsetApi = new HomeLoanAPIRepository();
    OffsetAccountModel response = offsetApi.getOffsetAccounts(
      ocvId,
      loanAccNumber,
      recordId
    );
    Test.stopTest();

    Assert.areEqual(
      loanAccNumber,
      response.loanOffsets[0].loanAccount,
      'Should get the Offset for the loan account from Cache'
    );
  }

  @isTest
  static void testUserErrorGetListOffsetException() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = 'abcd';

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('Invalid Account Number');
    errorResponse.successful = false;
    errorResponse.statusCode = 400;

    registerMocks();
    finAccServiceMock.mock('getOffsetAccounts', errorResponse);

    try {
      Test.startTest();
      HomeLoanAPIRepository offsetApi = new HomeLoanAPIRepository();
      offsetApi.getOffsetAccounts(ocvId, loanAccNumber, recordId);
      Test.stopTest();

      Assert.fail('An Exception should be thrown');
    } catch (Exception exp) {
      Assert.isInstanceOfType(
        exp,
        HomeLoanAPIRepository.UserErrorException.class,
        'Exception should be an instanceof HomeLoanAPIRepository.UserErrorException.'
      );

      Assert.areEqual(
        'Invalid Account Number',
        exp.getMessage(),
        'Should throw invalid details exception'
      );
    }
  }

  @isTest
  static void testGetOffsetAccountsServerException() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = 'abcd';

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.successful = false;
    errorResponse.statusCode = 500;

    registerMocks();
    finAccServiceMock.mock('getOffsetAccounts', errorResponse);

    try {
      Test.startTest();
      HomeLoanAPIRepository offsetApi = new HomeLoanAPIRepository();
      offsetApi.getOffsetAccounts(ocvId, loanAccNumber, recordId);
      Test.stopTest();

      Assert.fail('An Exception should be thrown');
    } catch (Exception exp) {
      Assert.isInstanceOfType(
        exp,
        HomeLoanAPIRepository.ServerErrorException.class,
        'Exception should be an instanceof HomeLoanAPIRepository.ServerErrorException.'
      );

      Assert.areEqual(
        'callout failed',
        exp.getMessage(),
        'Should throw callout failed exception'
      );
    }
  }

  @isTest
  static void testGetOffsetAccountsNotFoundException() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = 'abcd';

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException(
      '{"code": "ERROR","additionalInfo": {"reason": "HTTP:NOT_FOUND","category": "TECHNICAL"}}'
    );
    errorResponse.body = null;
    errorResponse.successful = false;
    errorResponse.statusCode = 404;

    registerMocks();
    finAccServiceMock.mock('getOffsetAccounts', errorResponse);

    try {
      Test.startTest();
      HomeLoanAPIRepository offsetApi = new HomeLoanAPIRepository();
      offsetApi.getOffsetAccounts(ocvId, loanAccNumber, recordId);
      Test.stopTest();

      Assert.fail('An Exception should be thrown');
    } catch (Exception exp) {
      Assert.isInstanceOfType(
        exp,
        HomeLoanAPIRepository.UserErrorException.class,
        'Exception should be an instanceof HomeLoanAPIRepository.UserErrorException.'
      );

      Assert.isTrue(
        exp.getMessage().contains('HTTP:NOT_FOUND'),
        'Should throw not found exception'
      );
    }
  }

  @isTest
  static void testGetListOffsetUnhandledException() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = 'abcd';

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.body = null;
    errorResponse.successful = false;
    errorResponse.error = new CalloutException('callout failed');

    registerMocks();
    finAccServiceMock.mock('getOffsetAccounts', errorResponse);

    try {
      Test.startTest();
      HomeLoanAPIRepository offsetApi = new HomeLoanAPIRepository();
      offsetApi.getOffsetAccounts(ocvId, loanAccNumber, recordId);
      Test.stopTest();

      Assert.fail('An Exception should be thrown');
    } catch (Exception exp) {
      Assert.isInstanceOfType(
        exp,
        HomeLoanAPIRepository.UnhandledException.class,
        'Exception should be an instanceof HomeLoanAPIRepository.UnhandledException.'
      );
    }
  }
}