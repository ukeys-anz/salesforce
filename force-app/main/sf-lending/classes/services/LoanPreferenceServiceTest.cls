/**
 * @author Pooja Kirtishahi
 * @date Nov 2024
 * @description Test class for {@link LoanPreferenceService}
 */

@isTest
public with sharing class LoanPreferenceServiceTest {
  static Lib_MockProvider calloutMock;

  static void registerMocks() {
    calloutMock = Lib_MockProvider.forType(Lib_HttpCallout.class);
  }

  static Account getAccount {
    get {
      return new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Name = 'Test Loan Account',
        OCV_Id__c = '1234'
      );
    }
  }

  static ResidentialLoanApplication getRLA {
    get {
      return new ResidentialLoanApplication(
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.SObjectType
        ),
        Name = 'Test Loan Application',
        Property_Use__c = 'LOAN_PRODUCT_TYPE_INVESTOR',
        Account = getAccount
      );
    }
  }

  static LoanApplicationFinancial getLAF {
    get {
      return new LoanApplicationFinancial(
        Id = Lib_FakeIdGenerator.getMockId(
          LoanApplicationFinancial.SObjectType
        ),
        Name = 'Test Loan Application Financial',
        LoanExclFinMortInsAmt = 11000,
        Loan_Term_in_Months__c = 24,
        Loan_Repayment_Frequency__c = 'REPAYMENT_FREQUENCY_UNSPECIFIED',
        LoanApplication = getRLA
      );
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
  static void testGetLoanPrefDetailsSuccess() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource('mock_getLoanPreference');
    successResponse.successful = true;
    successResponse.statusCode = 200;
    calloutMock.mock('makeRestCallout', successResponse);

    String ocvId = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    LoanPreferenceService service = new LoanPreferenceService();
    HttpCalloutResponse response = service.getLoanPrefDetails(
      getLoanPreferenceRequestModel,
      ocvId
    );
    Test.stopTest();

    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isTrue(response.successful, 'Response should be successful');
    Assert.areEqual(
      JSON.serialize(getLoanPreferenceRequestModel),
      (String) calloutMock.getHistory('makeRestCallout')
        .getParam('requestBody'),
      'Request body should be serialized request'
    );
  }

  @isTest
  static void testGetLoanPrefDetailsFailure() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('Error');
    calloutMock.mock('makeRestCallout', errorResponse);

    String ocvId = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    LoanPreferenceService service = new LoanPreferenceService();
    HttpCalloutResponse response = service.getLoanPrefDetails(
      getLoanPreferenceRequestModel,
      ocvId
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
  static void testUpdateLoanPrefDetailsSuccess() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource(
      'mock_updateLoanPreference'
    );
    successResponse.successful = true;
    successResponse.statusCode = 200;
    calloutMock.mock('makeRestCallout', successResponse);

    String ocvId = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );
    List<Object> urlParams = new List<Object>{
      '13241571',
      '7479fe3d-f0b8-4739-a4cd-7fb334bf3451'
    };
    Test.startTest();
    LoanPreferenceService service = new LoanPreferenceService();
    HttpCalloutResponse response = service.updateLoanPreferenceDetails(
      ocvId,
      urlParams,
      getUpdateLoanpreferenceRequestModel
    );
    Test.stopTest();

    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isTrue(response.successful, 'Response should be successful');
    Assert.isTrue(
      response.body.contains('preferences'),
      'Response should have preferences'
    );
  }

  @isTest
  static void testUpdateLoanPrefDetailsFailure() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('Error');
    calloutMock.mock('makeRestCallout', errorResponse);

    String ocvId = '1234';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );
    List<Object> urlParams = new List<Object>{
      '13241571',
      '7479fe3d-f0b8-4739-a4cd-7fb334bf3451'
    };
    Test.startTest();
    LoanPreferenceService service = new LoanPreferenceService();
    HttpCalloutResponse response = service.updateLoanPreferenceDetails(
      ocvId,
      urlParams,
      getUpdateLoanpreferenceRequestModel
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
