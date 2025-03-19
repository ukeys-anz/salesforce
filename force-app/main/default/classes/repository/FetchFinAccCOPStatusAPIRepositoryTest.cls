/**
 * @author Shivam Swaraj
 * @date March 2025
 * @description Test class for {@link FetchFinAccCOPStatusAPIRepository}
 * @group Repository
 */
@isTest
public with sharing class FetchFinAccCOPStatusAPIRepositoryTest {
  static Lib_MockProvider userMock;

  static void registerMocks() {
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
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
        'View_Transaction_History',
        'Product_Read_Only'
      }
    );
  }

  @IsTest
  static void testgetAccountCoPdetailsValidResponse() {
    registerMocks();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = true;
    response.statusCode = 200;
    response.body = ConfirmationOfPayeeServiceMock.GET_ACCOUNT_COP_DETAILS;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(ConfirmationOfPayeeService.class)
      .mock('getAccountCoPdetails', response);
    Exception ex = null;
    try {
      AccountCoPStatusRequestModel requestList = new AccountCoPStatusRequestModel();
      new FetchFinAccCOPStatusAPIRepository()
        .getAccountCoPdetails(requestList, '123456');
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testgetAccountCoPdetailsInvalidResponseServerError() {
    registerMocks();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 500;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(ConfirmationOfPayeeService.class)
      .mock('getAccountCoPdetails', response);
    Exception ex;
    try {
      AccountCoPStatusRequestModel requestList = new AccountCoPStatusRequestModel();
      new FetchFinAccCOPStatusAPIRepository()
        .getAccountCoPdetails(requestList, '123456');
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof FetchFinAccCOPStatusAPIRepository.ServerErrorException,
      'Server Exception should be thrown.'
    );
  }

  @IsTest
  static void testgetAccountCoPdetailsInvalidResponseAccessError() {
    registerMocks();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 401;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(ConfirmationOfPayeeService.class)
      .mock('getAccountCoPdetails', response);
    Exception ex;
    try {
      AccountCoPStatusRequestModel requestList = new AccountCoPStatusRequestModel();
      new FetchFinAccCOPStatusAPIRepository()
        .getAccountCoPdetails(requestList, '123456');
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof FetchFinAccCOPStatusAPIRepository.AccessErrorException,
      'Access Exception should be thrown.'
    );
  }

  @IsTest
  static void testgetAccountCoPdetailsResponseUnhandledError() {
    registerMocks();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 404;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(ConfirmationOfPayeeService.class)
      .mock('getAccountCoPdetails', response);
    Exception ex;
    try {
      AccountCoPStatusRequestModel requestList = new AccountCoPStatusRequestModel();
      new FetchFinAccCOPStatusAPIRepository()
        .getAccountCoPdetails(requestList, '123456');
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof FetchFinAccCOPStatusAPIRepository.UnhandledException,
      'Unhandled Exception should be thrown.'
    );
  }
}
