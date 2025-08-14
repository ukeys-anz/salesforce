/**
 * @author Peter Charalambous
 * @since June 2025
 * @description Mock implementation of mule api service for SOP service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class LexServiceMock extends LexService {
  /**
   * @description constructor which sets default code as successful
   */

  public LexServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  @TestVisible
  private static final string SETTLEMENT_RESPONSE = getStaticResource(
    'mock_settlement'
  );

  private static final string LOAN_FACILITY_RESPONSE = getStaticResource(
    'mock_listLoanFacilityConfigs'
  );

  private static final string AUTOMATIC_REPAYMENT_RESPONSE = getStaticResource(
    'mock_automaticrepayments'
  );

  @TestVisible
  private static final string VERIFY_INSURANCE = getStaticResource(
    'mock_verifyInsurance'
  );

  @TestVisible
  private static final string MORTGAGE_CONTRACT = getStaticResource(
    'mock_listMortgageContracts'
  );

  @TestVisible
  private static final string PROOF_OF_INSURANCE = getStaticResource(
    'mock_proofOfInsurance'
  );

  @TestVisible
  private static final string SETTLEMENT_ACCOUNT = getStaticResource(
    'mock_getSettlementAccount'
  );

  @TestVisible
  private static final string LIST_DRAWDOWNS = getStaticResource(
    'mock_listDrawdowns'
  );

  @TestVisible
  private static final string DRAWDOWN_RESPONSE = getStaticResource(
    'mock_getDrawdown'
  );

  /**
   * @param settlementId settlement id to fetch
   * @param ocvId ocv id
   * @return `HttpCalloutResponse` the api response
   * @description getSettlement returns settlement details
   */
  public override HttpCalloutResponse getSettlement(
    String settlementId,
    String ocvId
  ) {
    if (!preset) {
      response.body = LexServiceMock.SETTLEMENT_RESPONSE;
    }
    return response;
  }

  /**
   * @param settlementId settlementId to fetch
   * @param ocvId ocv id
   * @return `HttpCalloutResponse` the api response
   * @description listLoanFacilityConfigs get the list of loan facility configs
   */
  public override HttpCalloutResponse listLoanFacilityConfigs(
    String settlementId,
    String ocvId
  ) {
    if (!preset) {
      response.body = LexServiceMock.LOAN_FACILITY_RESPONSE;
    }
    return response;
  }

  /**
   * @param settlementId settlementId to fetch
   * @param ocvId ocv id
   * @return `HttpCalloutResponse` the api response
   * @description listAutomaticRepaymentPreferences get the list of automatic repayments
   */
  public override HttpCalloutResponse listAutomaticRepaymentPreferences(
    String settlementId,
    String ocvId
  ) {
    if (!preset) {
      response.body = LexServiceMock.AUTOMATIC_REPAYMENT_RESPONSE;
    }
    return response;
  }

  /**
   * @param requestBody body of request to send
   * @param ocvId ocv id
   * @return `HttpCalloutResponse` the api response
   * @description verifies proof of insurance
   */
  public override HttpCalloutResponse verifyInsurance(
    String requestBody,
    String ocvId
  ) {
    if (!preset) {
      response.body = LexServiceMock.VERIFY_INSURANCE;
    }
    return response;
  }
  /**
   * @description returns proof of Insurance details Mock
   * @param settlementId SettlementId to pass
   * @param ocvId OCV ID
   * @return `HttpCalloutResponse` the api response
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public override HttpCalloutResponse getProofOfInsurance(
    String settlementId,
    String ocvId
  ) {
    response.body = LexServiceMock.PROOF_OF_INSURANCE;
    return response;
  }

  /**
   * @description returns mortgageContract details Mock
   * @param settlementId SettlementId to pass
   * @param ocvId OCV ID of the account
   * @return `HttpCalloutResponse` the api response
   *
   */
  public override HttpCalloutResponse getListMortgageContracts(
    String settlementId,
    String ocvId
  ) {
    if (!preset) {
      response.body = LexServiceMock.MORTGAGE_CONTRACT;
    }
    return response;
  }
  /**
   * @description returns Settlement Account details Mock
   * @param settlementId SettlementId to pass
   * @param ocvId OCV ID of the account
   * @return `HttpCalloutResponse` the api response
   *
   */
  public override HttpCalloutResponse getSettlementAccount(
    String settlementId,
    String ocvId
  ) {
    if (!preset) {
      response.body = LexServiceMock.SETTLEMENT_ACCOUNT;
    }
    return response;
  }

  /**
   * @description returns List Drawdowns Mock response
   * @param settlementId SettlementId to pass
   * @param ocvId OCV ID of the account
   * @return `HttpCalloutResponse` the api response
   *
   */
  public override HttpCalloutResponse getListDrawdowns(
    String settlementId,
    String ocvId
  ) {
    response.body = LexServiceMock.LIST_DRAWDOWNS;
    return response;
  }

  /**
   * @description returns List Drawdowns Mock response
   * @param drawdownId drawdown to fetch
   * @param ocvId OCV ID of the account
   * @return `HttpCalloutResponse` the api response
   *
   */
  public override HttpCalloutResponse getDrawdown(
    String drawdownId,
    String ocvId
  ) {
    response.body = LexServiceMock.DRAWDOWN_RESPONSE;
    return response;
  }
}
