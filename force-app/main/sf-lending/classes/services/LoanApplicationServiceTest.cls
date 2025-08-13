/**
 * @author ramvilas
 * @date May 2025
 * @description Test class for {@link LoanApplicationService}
 */
@isTest
public class LoanApplicationServiceTest {
  static Lib_MockProvider calloutMock;

  static void registerMocks() {
    calloutMock = Lib_MockProvider.forType(Lib_HttpCallout.class);
  }

  @isTest
  static void testGetLoanApplicationSuccess() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource('mock_GetLoanApplication');
    successResponse.successful = true;
    successResponse.statusCode = 200;
    calloutMock.mock('makeRestCallout', successResponse);

    String ocvId = '1234';
    String loanAccNumber = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    LoanApplicationService service = new LoanApplicationService();
    HttpCalloutResponse response = service.getLoanApplicationDetails(
      ocvId,
      loanAccNumber
    );
    Test.stopTest();

    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isTrue(response.successful, 'Response should be successful');
    Assert.areEqual(
      200,
      response.statusCode,
      'Status code of the response should be 200'
    );
  }

  @isTest
  static void testGetLoanPreferneceFailure() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('Error');
    calloutMock.mock('makeRestCallout', errorResponse);

    String ocvId = '1234';
    String loanAccNumber = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    LoanApplicationService service = new LoanApplicationService();
    HttpCalloutResponse response = service.getLoanApplicationDetails(
      ocvId,
      loanAccNumber
    );
    Test.stopTest();
    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isFalse(response.successful, 'Response should be error');
    Assert.areEqual(
      500,
      response.statusCode,
      'Status code of the response should be 500'
    );
  }

  @isTest
  static void testCancelResidentialLoanAppSuccess() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource(
      'mock_cancelHomeLoanApplication'
    );
    successResponse.successful = true;
    successResponse.statusCode = 200;
    calloutMock.mock('makeRestCallout', successResponse);

    String ocvId = '1234';
    String loanAccNumber = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    LoanApplicationService service = new LoanApplicationService();
    HttpCalloutResponse response = service.cancelResidentialLoanApp(
      ocvId,
      loanAccNumber
    );
    Test.stopTest();

    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isTrue(response.successful, 'Response should be successful');
    Assert.areEqual(
      200,
      response.statusCode,
      'Status code of the response should be 200'
    );
  }

  @isTest
  static void testCancelResidentialLoanAppFailure() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('Error');
    calloutMock.mock('makeRestCallout', errorResponse);

    String ocvId = '1234';
    String loanAccNumber = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    LoanApplicationService service = new LoanApplicationService();
    HttpCalloutResponse response = service.cancelResidentialLoanApp(
      ocvId,
      loanAccNumber
    );
    Test.stopTest();
    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isFalse(response.successful, 'Response should be error');
    Assert.areEqual(
      500,
      response.statusCode,
      'Status code of the response should be 500'
    );
  }
}
