/**
 * @author Hitesh
 * @since July 2025
 * @description test class for FinancialSummaryAPIRepository
 */
@isTest
private class FinancialSummaryAPIRepositoryTest {
  static Lib_MockProvider finSumServiceMock;

  static void registerMocks() {
    finSumServiceMock = Lib_MockProvider.forType(FinancialSummaryService.class);
  }

  @isTest
  static void testGetFinancialSummaryResponse() {
    String status = '';
    Test.setMock(
      HttpCalloutMock.class,
      new FinancialSummaryServiceMock.GetTotalCustomerBalanceMock()
    );
    Test.startTest();
    FinancialSummaryAPIRepository finSumApiRepo = new FinancialSummaryAPIRepository();
    HttpCalloutResponse response = finSumApiRepo.getFinancialSummaryResponse(
      Label.Financial_Account_Endpoint + 'summaries',
      '',
      false
    );
    status = FinancialSummaryController.getFinancialSummaryDetails(response);
    Test.stopTest();
    Assert.areEqual(
      status,
      FinancialSummaryController.MULE_RESPONSE,
      'Errored out while calling the Total Balance API'
    );
  }

  @isTest
  static void testGetFinancialSummaryResponseError500() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    finSumServiceMock.mock('getFinancialSummaryResponse', res);
    try {
      Test.startTest();
      new FinancialSummaryAPIRepository()
        .getFinancialSummaryResponse('', '', false);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        FinancialSummaryAPIRepository.ServerErrorException.class,
        'Exception should be an instanceof ServerErrorException.'
      );
    }
  }

  @isTest
  static void testgetFinancialSummaryResponseError400() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 400;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    finSumServiceMock.mock('getFinancialSummaryResponse', res);
    try {
      Test.startTest();
      new FinancialSummaryAPIRepository()
        .getFinancialSummaryResponse('', '', false);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        FinancialSummaryAPIRepository.UserErrorException.class,
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
    finSumServiceMock.mock('getFinancialSummaryResponse', res);

    try {
      Test.startTest();
      new FinancialSummaryAPIRepository()
        .getFinancialSummaryResponse('', '', false);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        FinancialSummaryAPIRepository.UnhandledException.class,
        'Exception should be an instanceof UnhandledException.'
      );
    }
  }
}
