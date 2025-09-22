/**
 * @author ramvilas
 * @date May 2025
 * @description Test class for {@link LoanApplicationAPIRepository}
 */
@isTest
public class LoanApplicationAPIRepositoryTest {
  static Lib_MockProvider loanAppServiceMock;
  static void registerMocks() {
    loanAppServiceMock = Lib_MockProvider.forType(LoanApplicationService.class);
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
    loanAppServiceMock.mock('cancelResidentialLoanApp', successResponse);

    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    Test.startTest();
    LoanApplicationAPIRepository appService = new LoanApplicationAPIRepository();
    HttpCalloutResponse response = appService.cancelResidentialLoanApp(
      loanAccNumber,
      ocvId
    );
    Test.stopTest();
    Assert.isNotNull(response, 'Response is incorrect');
    Assert.isTrue(
      response.successful,
      'Residential Loan Application should be cancelled'
    );
  }

  @isTest
  static void testCancelResidentialLoanAppServerError() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    loanAppServiceMock.mock('cancelResidentialLoanApp', errorResponse);

    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    try {
      Test.startTest();
      LoanApplicationAPIRepository loanApi = new LoanApplicationAPIRepository();
      loanApi.cancelResidentialLoanApp(ocvId, loanAccNumber);
      Test.stopTest();
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        LoanApplicationAPIRepository.ServerErrorLoanApplicationException.class,
        'Exception should be thrown.'
      );
      Assert.areEqual(
        'callout failed',
        ex.getMessage(),
        'Should throw invalid details exception'
      );
    }
  }
  @isTest
  static void testCancelResidentialLoanAppUserError() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.successful = false;
    errorResponse.statusCode = 400;
    loanAppServiceMock.mock('cancelResidentialLoanApp', errorResponse);

    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    try {
      Test.startTest();
      LoanApplicationAPIRepository loanApi = new LoanApplicationAPIRepository();
      loanApi.cancelResidentialLoanApp(ocvId, loanAccNumber);
      Test.stopTest();
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        LoanApplicationAPIRepository.UserErrorLoanApplicationException.class,
        'Exception should be thrown.'
      );
      Assert.areEqual(
        'callout failed',
        ex.getMessage(),
        'Should throw invalid details exception'
      );
    }
  }
  @isTest
  static void testCancelResidentialLoanAppUnHandledError() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.successful = false;
    errorResponse.statusCode = 404;
    loanAppServiceMock.mock('cancelResidentialLoanApp', errorResponse);

    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    try {
      Test.startTest();
      LoanApplicationAPIRepository loanApi = new LoanApplicationAPIRepository();
      loanApi.cancelResidentialLoanApp(ocvId, loanAccNumber);
      Test.stopTest();
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        LoanApplicationAPIRepository.UnhandledLoanApplicationException.class,
        'Exception should be thrown.'
      );
      Assert.areEqual(
        'callout failed',
        ex.getMessage(),
        'Should throw invalid details exception'
      );
    }
  }
}
