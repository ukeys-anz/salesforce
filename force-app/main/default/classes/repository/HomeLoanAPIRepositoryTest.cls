/**
 * @author Vidhya Raghavan
 * @date December 2022
 * @description Test class for {@link HomeLoanAPIRepository}
 * @group repository
 */

@isTest
public inherited sharing class HomeLoanAPIRepositoryTest {
  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'BoH_Read_Only' });
  }
  @isTest
  static void homeLoanAccountValidResponse() {
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Test.startTest();
      HomeLoanAPIRepository hLoan = new HomeLoanAPIRepository();
      HomeLoanModel model = hLoan.getHomeLoanAccounts('2222', null);

      Test.stopTest();

      System.assertEquals(
        1,
        model.accounts.size(),
        'No home loan found with ocvId'
      );
      System.assertEquals(
        '222222222',
        model.accounts[0].account_number,
        'Account number is corresponding to OCVId'
      );
    }
  }

  @isTest
  static void testGetOffsetAccountsSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    Test.startTest();
    HomeLoanAPIRepository offsetapi = new HomeLoanAPIRepository();
    OffsetAccountModel responseModel = offsetapi.getOffsetAccounts(
      ocvId,
      loanAccNumber,
      recordId
    );
    Test.stopTest();

    Assert.areEqual(
      loanAccNumber,
      responseModel.loan_offsets[0].loan_account,
      'Should get the Offset for the loan account'
    );
    // Check if the data is stored in cache
    OffsetAccountModel cachedData = (OffsetAccountModel) DataPartitionUtil.getDataFromCache(
      recordId
    );
    Assert.areEqual(
      loanAccNumber,
      cachedData.loan_offsets[0].loan_account,
      'Should get the Offset for the loan account'
    );
  }

  @isTest
  static void testGetOffsetAccountsCache() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = '8321158';
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
    HomeLoanAPIRepository offsetapi = new HomeLoanAPIRepository();
    OffsetAccountModel response = offsetapi.getOffsetAccounts(
      ocvId,
      loanAccNumber,
      recordId
    );
    Test.stopTest();

    Assert.areEqual(
      loanAccNumber,
      response.loan_offsets[0].loan_account,
      'Should get the Offset for the loan account from Cache'
    );
  }

  @isTest
  static void testGetOffsetAccountsException() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    // Setting response for exception
    HttpCalloutResponse res = getResponseWithNoBody();
    Service finAccountService = ServiceProvider.getService(
      FinancialAccountService.class
    );
    finAccountService.setCalloutResponse(res);

    Exception resultException;
    Test.startTest();
    try {
      HomeLoanAPIRepository offsetapi = new HomeLoanAPIRepository();
      offsetapi.getOffsetAccounts(ocvId, loanAccNumber, recordId);
    } catch (Exception exp) {
      resultException = exp;
    }
    Test.stopTest();

    Assert.areEqual(
      'Attempt to de-reference a null object',
      resultException.getMessage(),
      'Should throw null pointer exception'
    );
  }

  @isTest
  static void testGetOffsetAccountsCalloutException() {
    Id recordId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String ocvId = '11111231';
    String loanAccNumber = 'abcd';

    // Setting response for exception
    HttpCalloutResponse res = getInvalidResponse();
    Service finAccountService = ServiceProvider.getService(
      FinancialAccountService.class
    );
    finAccountService.setCalloutResponse(res);

    Exception resultException;
    Test.startTest();
    try {
      HomeLoanAPIRepository offsetapi = new HomeLoanAPIRepository();
      offsetapi.getOffsetAccounts(ocvId, loanAccNumber, recordId);
    } catch (Exception exp) {
      resultException = exp;
    }
    Test.stopTest();

    Assert.areEqual(
      'Invalid Account Number',
      resultException.getMessage(),
      'Should throw invalid account number exception'
    );
  }

  private static HttpCalloutResponse getResponseWithNoBody() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 200;
    response.successful = true;
    response.body = null;
    return response;
  }

  private static HttpCalloutResponse getInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Invalid Account Number');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
