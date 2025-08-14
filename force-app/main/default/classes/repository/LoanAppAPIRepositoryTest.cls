/**
 * @author Ashwin Mohan
 * @since May 2025
 * @description test class for LoanAppAPIRepository
 */
@isTest
public class LoanAppAPIRepositoryTest {
  static Lib_MockProvider loanAppServiceMock;

  static void registerMocks() {
    loanAppServiceMock = Lib_MockProvider.forType(LoanappService.class);
  }
  @isTest
  static void testanzPlusLoanAppCalloutSuccess() {
    Test.startTest();
    String response = new LoanAppAPIRepository()
      .anzPlusLoanAppCallout(new ANZPlusLoanAppModel(null, null));
    Test.stopTest();
    Assert.isTrue(
      response.contains('applicationId'),
      'Application Id is not received'
    );
  }

  @isTest
  static void testanzPlusLoanAppCalloutError500() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    loanAppServiceMock.mock('getANZPlusLoanappCalloutResponse', res);
    try {
      Test.startTest();
      new LoanAppAPIRepository()
        .anzPlusLoanAppCallout(new ANZPlusLoanAppModel(null, null));
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        LoanAppAPIRepository.ServerErrorException.class,
        'Exception should be an instanceof ServerErrorException.'
      );
    }
  }

  @isTest
  static void testanzPlusLoanAppCalloutError400() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 400;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    loanAppServiceMock.mock('getANZPlusLoanappCalloutResponse', res);
    try {
      Test.startTest();
      new LoanAppAPIRepository()
        .anzPlusLoanAppCallout(new ANZPlusLoanAppModel(null, null));
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        LoanAppAPIRepository.UserErrorException.class,
        'Exception should be an instanceof UserErrorException.'
      );
    }
  }

  @isTest
  static void testUnhadledException() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 300;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    loanAppServiceMock.mock('getANZPlusLoanappCalloutResponse', res);
    try {
      Test.startTest();
      new LoanAppAPIRepository()
        .anzPlusLoanAppCallout(new ANZPlusLoanAppModel(null, null));
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        LoanAppAPIRepository.UnhandledException.class,
        'Exception should be an instanceof UnhandledException.'
      );
    }
  }
}
