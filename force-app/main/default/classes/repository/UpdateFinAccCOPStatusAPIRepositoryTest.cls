/**
 * @author Shivam Swaraj
 * @date March 2025
 * @description Test class for {@link FinancialAccountAPIRepository}
 * @group Repository
 */
@isTest
public with sharing class UpdateFinAccCOPStatusAPIRepositoryTest {
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
  static void testUpdateAccountCoPdetailsValidResponse() {
    registerMocks();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = true;
    response.statusCode = 200;
    response.body = ConfirmationOfPayeeServiceMock.UPDATE_ACCOUNT_COP_DETAILS;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(ConfirmationOfPayeeService.class)
      .mock('updateAccountCoPdetails', response);
    Exception ex = null;
    try {
      List<FinancialAccModelUpdateRequestCoP> requestList = createMockRequestList();
      new UpdateFinAccCOPStatusAPIRepository()
        .updateAccountCoPdetails(requestList, '123456');
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testUpdateAccountCoPdetailsInvalidResponseServerError() {
    registerMocks();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 500;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(ConfirmationOfPayeeService.class)
      .mock('updateAccountCoPdetails', response);
    Exception ex;
    try {
      List<FinancialAccModelUpdateRequestCoP> requestList = createMockRequestList();
      new UpdateFinAccCOPStatusAPIRepository()
        .updateAccountCoPdetails(requestList, '123456');
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof UpdateFinAccCOPStatusAPIRepository.ServerErrorException,
      'Server Exception should be thrown.'
    );
  }

  @IsTest
  static void testUpdateAccountCoPdetailsInvalidResponseAccessError() {
    registerMocks();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 401;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(ConfirmationOfPayeeService.class)
      .mock('updateAccountCoPdetails', response);
    Exception ex;
    try {
      List<FinancialAccModelUpdateRequestCoP> requestList = createMockRequestList();
      new UpdateFinAccCOPStatusAPIRepository()
        .updateAccountCoPdetails(requestList, '123456');
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof UpdateFinAccCOPStatusAPIRepository.AccessErrorException,
      'Access Exception should be thrown.'
    );
  }

  @IsTest
  static void testUpdateAccountCoPdetailsResponseUnhandledError() {
    registerMocks();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 404;
    response.error = new CalloutException('Error');
    Lib_MockProvider.forType(ConfirmationOfPayeeService.class)
      .mock('updateAccountCoPdetails', response);
    Exception ex;
    try {
      List<FinancialAccModelUpdateRequestCoP> requestList = createMockRequestList();
      new UpdateFinAccCOPStatusAPIRepository()
        .updateAccountCoPdetails(requestList, '123456');
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof UpdateFinAccCOPStatusAPIRepository.UnhandledException,
      'Unhandled Exception should be thrown.'
    );
  }

  private static List<FinancialAccModelUpdateRequestCoP> createMockRequestList() {
    List<FinancialAccModelUpdateRequestCoP> requestList = new List<FinancialAccModelUpdateRequestCoP>();
    FinancialAccModelUpdateRequestCoP request = new FinancialAccModelUpdateRequestCoP();
    request.accountCoPStatus = 'OPT-IN';
    request.accountIdentification = '1234560987654';
    requestList.add(request);
    return requestList;
  }
}
