/**
 * @author Anuj Jain
 * @since March 2024
 * @description Service class for Data IN functionality
 * @group Service
 */
public with sharing virtual class TFMDataINService extends Service {
  /**
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description get data in Consent list
   */
  public virtual HttpCalloutResponse getDataINConsentsListAPI(
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    TFMSearchCustomerService obj = new TFMSearchCustomerService();
    headers = obj.setCommonHeadersInMap(staffModel);
    headers.put(TFMConstants.CONTENTTYPE, TFMConstants.APPLICATIONJSON);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();

    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_DataINConsentList_API,
      HTTP_METHOD.HTTP_POST,
      headers,
      '{"page_size": 1000}'
    );
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param consentIdValue consentId Value
   * @return HttpCalloutResponse response
   * @description get data in Consent list
   */
  public virtual HttpCalloutResponse getDataINAccountListAPI(
    StaffTokenRequestModel staffModel,
    String consentIdValue
  ) {
    Map<String, String> headers = new Map<String, String>();
    TFMSearchCustomerService obj = new TFMSearchCustomerService();
    headers = obj.setCommonHeadersInMap(staffModel);
    ExportConsentWrapper jsonBody = new ExportConsentWrapper();
    jsonBody.consents.add(consentIdValue);
    headers.put(TFMConstants.CONTENTTYPE, TFMConstants.APPLICATIONJSON);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_DataINAccountList_API,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(jsonBody)
    );
    return response;
  }

  /**
   * @param methodName passing method name for resuing same method for Data IN export
   * @param consentId consentId from the consent
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description get data in Consent list
   */
  public virtual HttpCalloutResponse exportConsent(
    String methodName,
    String consentId,
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    TFMSearchCustomerService obj = new TFMSearchCustomerService();
    headers = obj.setCommonHeadersInMap(staffModel);
    headers.put(TFMConstants.CONTENTTYPE, TFMConstants.APPLICATIONJSON);

    ExportConsentWrapper jsonBody = new ExportConsentWrapper();
    jsonBody.consents.add(consentId);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      methodName == TFMConstants.EXPORTCONSENTREPORT
        ? System.Label.MS_ExportConsentDataIN_API
        : System.Label.MS_ExportDataSharingCollectionDataIN_API,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(jsonBody)
    );
    return response;
  }

  /**
   * @param consentId consentId of the record
   * @param staffModel model to call staffJWT api
   * @return HttpCalloutResponse response
   * @description it will hit the api to stop consent
   */
  public virtual HttpCalloutResponse revokeConsent(
    String consentId,
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    TFMSearchCustomerService obj = new TFMSearchCustomerService();
    Datetime currentDatetime = Datetime.now();
    String requestTime = currentDatetime.format(
      TFMConstants.REQUESTTIMEDATEFORMAT
    );
    headers = obj.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    headers.put(TFMConstants.CONTENTTYPE, TFMConstants.APPLICATIONJSON);
    RevokeConsentWrapper jsonBody = new RevokeConsentWrapper(
      TFMConstants.CONSENTSSLASH + consentId,
      requestTime
    );
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_RevokeConsentDataIN_API,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(jsonBody)
    );
    return response;
  }

  /**
   * @description This is wrapper class for RevokeConsentWrapper
   * @name RevokeConsentWrapper
   * @author Shivraj Kadam
   */
  @SuppressWarnings(
    'PMD.FieldNamingConventions, PMD.FormalParameterNamingConventions'
  )
  public class RevokeConsentWrapper {
    public String consent;
    public String request_time;
    /**
     * @param consent consent
     * @param request_time request_time
     * @description RevokeConsentWrapper
     */
    public RevokeConsentWrapper(String consent, String request_time) {
      this.consent = consent;
      this.request_time = request_time;
    }
  }

  /**
   * @description This is wrapper class for ExportConsentWrapper
   * @name ExportConsentWrapper
   * @author Shivraj Kadam
   */
  public class ExportConsentWrapper {
    public List<String> consents = new List<String>();
  }
}
