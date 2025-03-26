/**
 * @author Pooja Kirtishahi
 * @date Nov 2024
 * @description Test class for {@link LoanPreferenceAPIRepository}
 */

@isTest
public with sharing class LoanPreferenceAPIRepositoryTest {
  static Lib_MockProvider loanPreferenceServiceMock;

  static void registerMocks() {
    loanPreferenceServiceMock = Lib_MockProvider.forType(
      LoanPreferenceService.class
    );
  }

  static LoanApplicationFinancial getLAF {
    get {
      LoanApplicationFinancial laf = new LoanApplicationFinancial();
      laf.Id = Lib_FakeIdGenerator.getMockId(
        LoanApplicationFinancial.SObjectType
      );
      laf.Name = 'Test Loan Application Financial';
      laf.LoanExclFinMortInsAmt = 11000;
      laf.Loan_Term_in_Months__c = 24;
      laf.Loan_Repayment_Frequency__c = 'REPAYMENT_FREQUENCY_UNSPECIFIED';
      laf.E_Tag__c = '1252617';
      laf.FinancialExtIdentifier = 'ufghdms-gsgshsjik-svshjj';
      return laf;
    }
  }

  static LoanPreferenceRequestModel getLoanPreferenceRequestModel {
    get {
      return new LoanPreferenceRequestModel(getLAF);
    }
  }

  /**
   * @description Static method to return LoanPreferenceEditModel Record
   */
  static LoanPreferenceEditModel getUpdateLoanpreferenceRequestModel {
    get {
      LoanPreferenceEditModel updateLoanData = new LoanPreferenceEditModel();
      updateLoanData.uid = '1234';
      updateLoanData.termMonths = 10;
      updateLoanData.repaymentFrequency = 'REPAYMENT_FREQUENCY_ANNUAL';
      updateLoanData.offset = true;
      updateLoanData.etag = '1732683675717';
      updateLoanData.interestRateType = 'INTEREST_RATE_TYPE_VARIABLE';
      updateLoanData.repaymentType = 'REPAYMENT_TYPE_PRINCIPAL_INTEREST';
      updateLoanData.funds = new List<LoanPreferenceEditModel.Funds>();
      LoanPreferenceEditModel.Funds fn = new LoanPreferenceEditModel.Funds();
      fn.purpose = 'test';
      fn.amount = new FabricType.FabricMoney('AUD', 2634.99);
      updateLoanData.funds.add(fn);
      return updateLoanData;
    }
  }

  @isTest
  static void testGetLoanPreferenceSuccess() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource('mock_getLoanPreference');
    successResponse.successful = true;
    successResponse.statusCode = 200;
    loanPreferenceServiceMock.mock('getLoanPrefDetails', successResponse);

    String ocvId = '1234';

    Test.startTest();
    LoanPreferenceAPIRepository loanPrefApi = new LoanPreferenceAPIRepository();
    LoanPreferenceResponseModel responseModel = loanPrefApi.getViewLoanPreference(
      getLoanPreferenceRequestModel,
      ocvId
    );
    Test.stopTest();

    Assert.areEqual(
      545,
      responseModel.interestRate,
      'Interest Rate should be as expected.'
    );
  }

  @isTest
  static void testGetLoanPreferenceException() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    loanPreferenceServiceMock.mock('getLoanPrefDetails', errorResponse);

    String ocvId = '1234';

    Exception resultException;
    Test.startTest();
    try {
      LoanPreferenceAPIRepository loanPrefApi = new LoanPreferenceAPIRepository();
      loanPrefApi.getViewLoanPreference(getLoanPreferenceRequestModel, ocvId);
    } catch (Exception exp) {
      resultException = exp;
    }
    Test.stopTest();

    Assert.isTrue(
      resultException instanceof LoanPreferenceAPIRepository.UnhandledGetLoanPreferenceException,
      'Exception should be thrown.'
    );
    Assert.areEqual(
      'callout failed',
      resultException.getMessage(),
      'Should throw invalid details exception'
    );
  }

  /**
   * @description Test case for a valid Input and valid response
   */
  @isTest
  static void testUpdateLoanPreferenceSuccess() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource(
      'mock_updateLoanPreference'
    );
    successResponse.successful = true;
    successResponse.statusCode = 200;
    loanPreferenceServiceMock.mock(
      'updateLoanPreferenceDetails',
      successResponse
    );

    String ocvId = '11111231';
    List<Object> urlParams = new List<Object>{
      '13241571',
      '7479fe3d-f0b8-4739-a4cd-7fb334bf3451'
    };

    Test.startTest();
    LoanPreferenceAPIRepository loanPrefapi = new LoanPreferenceAPIRepository();
    LoanPreferenceUpdateResponseModel responseModel = loanPrefapi.updateLoanPreference(
      ocvId,
      urlParams,
      getUpdateLoanpreferenceRequestModel
    );
    Test.stopTest();

    Assert.isTrue(responseModel.successful, 'Successful Response');
  }

  /**
   * @description Test case for a invalid Input and exception
   */
  @isTest
  static void testUpdateLoanPreferenceFailure() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException(
      '{"code": "ERROR","errorCode": 340210,"errorReason": "loan_amount outside minimum and maximum", "additionalInfo": {"reason": "HTTP:NOT_FOUND","category": "TECHNICAL"}}'
    );
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    loanPreferenceServiceMock.mock(
      'updateLoanPreferenceDetails',
      errorResponse
    );

    String ocvId = '11111231';
    List<Object> urlParams = new List<Object>{
      '13241571',
      '7479fe3d-f0b8-4739-a4cd-7fb334bf3451'
    };

    LoanPreferenceUpdateResponseModel responseModel;
    Test.startTest();
    LoanPreferenceAPIRepository loanPrefapi = new LoanPreferenceAPIRepository();
    responseModel = loanPrefapi.updateLoanPreference(
      ocvId,
      urlParams,
      getUpdateLoanpreferenceRequestModel
    );
    Test.stopTest();

    Assert.isFalse(responseModel.successful, 'Failure Response');
  }

  private static HttpCalloutResponse getInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Invalid Details');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }

  private static HttpCalloutResponse getInvalidUpdateResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 500;
    response.successful = false;
    response.error = new CalloutException(
      '{"code": "ERROR","errorCode": 340210,"errorReason": "loan_amount outside minimum and maximum", "additionalInfo": {"reason": "HTTP:NOT_FOUND","category": "TECHNICAL"}}'
    );
    return response;
  }

  private static HttpCalloutResponse getResponseWithNoBody() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 200;
    response.successful = true;
    response.body = null;
    return response;
  }
}
