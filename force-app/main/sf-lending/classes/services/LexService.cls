/**
 * @author Peter Charalambous
 * @since June 2025
 * @description Service class for lex apis
 * @group Services
 */
public with sharing virtual class LexService extends Service {
  /**
   * @param settlementId settlementId to fetch
   * @param ocvId ocv id
   * @return `HttpCalloutResponse` the api response
   * @description returns settlement details
   */
  public virtual HttpCalloutResponse getSettlement(
    String settlementId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_Settlement + settlementId,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @param settlementId settlementId to fetch
   * @param ocvId ocv id
   * @return `HttpCalloutResponse` the api response
   * @description listLoanFacilityConfigs get the list of loan facility configs
   */
  public virtual HttpCalloutResponse listLoanFacilityConfigs(
    String settlementId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_Settlement +
        settlementId +
        '/loan/loan-facility-configs',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @param settlementId settlementId to fetch
   * @param ocvId ocv id
   * @return `HttpCalloutResponse` the api response
   * @description listAutomaticRepaymentPreferences get the list of automatic repayments
   */
  public virtual HttpCalloutResponse listAutomaticRepaymentPreferences(
    String settlementId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_Settlement +
        settlementId +
        '/loans/loan-facility-configs/-/auto-repayment-preferences',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @param requestBody body of request to send
   * @param ocvId ocv id
   * @return `HttpCalloutResponse` the api response
   * @description verify proof of insurance
   */
  public virtual HttpCalloutResponse verifyInsurance(
    String requestBody,
    String ocvId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-Type', 'application/json');

    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_Verify_Insurance,
      HTTP_METHOD.HTTP_POST,
      headers,
      requestBody
    );

    return response;
  }
  /**
   * @description returns proof of Insurance details
   * @param settlementId SettlementId to pass
   * @param ocvId OCV ID
   * @return `HttpCalloutResponse` the api response
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public virtual HttpCalloutResponse getProofOfInsurance(
    String settlementId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    //Use - to fetch all
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_Settlement +
        settlementId +
        '/loan/mortgage-contracts/-/properties/-/proof-of-insurance',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @description returns mortgageContract details
   * @param settlementId SettlementId to pass
   * @param ocvId OCV ID of the account
   * @return `HttpCalloutResponse` the api response
   *
   */
  public virtual HttpCalloutResponse getListMortgageContracts(
    String settlementId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_Settlement +
        settlementId +
        '/loan/mortgage-contracts',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @description returns Settlement Account details
   * @param settlementId SettlementId to pass
   * @param ocvId OCV ID of the account
   * @return `HttpCalloutResponse` the api response
   *
   */
  public virtual HttpCalloutResponse getSettlementAccount(
    String settlementId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_Settlement + settlementId + '/settlement-account',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }
  /**
   * @description returns List of drawdowns
   * @param settlementId SettlementId to pass
   * @param ocvId OCV ID of the account
   * @return `HttpCalloutResponse` the api response
   *
   */
  public virtual HttpCalloutResponse getListDrawdowns(
    String settlementId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_Settlement + settlementId + '/loan/drawdowns',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }
  /**
   * @description returns Drawdown details
   * @param drawdownId drawdown to fetch
   * @param ocvId OCV ID of the account
   * @return `HttpCalloutResponse` the api response
   *
   */
  public virtual HttpCalloutResponse getDrawdown(
    String drawdownId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_Settlement + '/drawdowns/' + drawdownId,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }
}
