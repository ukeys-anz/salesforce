/**
 * @author Aman Gupta
 * @since February 2025
 * @description Construct header & payload for COP request
 * @group Services
 * @runTests ConfirmationOfPayeeServiceTest
 */

public with sharing virtual class ConfirmationOfPayeeService extends Service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  private static final String LANID = 'LANID';

  /**
   * @description Initiate callout to get confirmation of Payee Information.
   * @param request request for COP Details
   * @param ocvId OCV Id for Customer providing authorisation
   * @return HttpCalloutResponse from Callout for COP Details
   */
  public virtual HttpCalloutResponse getAccountCoPdetails(
    String request,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    headers.put('Content-Type', 'application/json');
    headers.put('traceparent', CommonUtil.generateTraceParent());
    HttpCalloutResponse response = CALLOUT.makeRestCallout(
      Label.MS_CONFIRMATION_OF_PAYEE_GET_ACCOUNTS,
      HTTP_METHOD.HTTP_POST,
      headers,
      request
    );
    return response;
  }

  /**
   * @description Initiate callout to update confirmation of Payee Information.
   * @param request request for COP Details
   * @param ocvId OCV Id for Customer providing authorisation
   * @return HttpCalloutResponse from Callout for COP Details
   */
  public virtual HttpCalloutResponse updateAccountCoPdetails(
    String request,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    headers.put('Content-Type', 'application/json');
    headers.put('userIdType', LANID);
    headers.put('userId', USER_INFO.getUser().Lan_Id__c);
    headers.put('traceparent', CommonUtil.generateTraceParent());
    HttpCalloutResponse response = CALLOUT.makeRestCallout(
      Label.MS_CONFIRMATION_OF_PAYEE_UPDATE_ACCOUNTS,
      HTTP_METHOD.HTTP_POST,
      headers,
      request
    );
    return response;
  }
}
