/**
 * @author Pavan Kumar Ananta
 * @since December 2020
 * @description RequestUtils class holds the util functions for all the apex callout requests
 * @group Utils
 */
public with sharing class RequestUtils {
  private static Request reqInfo;
  /**
   * @description get the unique correlation id for each execution context
   * @return string the unique correlation id
   */
  public static String getRequestId() {
    if (reqInfo == null) {
      reqInfo = Request.getCurrent();
    }
    return reqInfo.getRequestId();
  }

  /**
   * @description Set Auth headers on HTTP Request where Forge Tokens are involved
   * @param request HttpRequest
   * @param ocvID Customer OCV ID
   * @param requestMethod HTTP request method
   */
  public static void setAuthHeaders(
    HttpRequest request,
    String ocvID,
    String requestMethod
  ) {
    setCommonRequestParams(request, requestMethod);
    String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvID);
    request.setHeader('Authorization', 'Bearer ' + serializedToken);
  }

  /**
   * @description Set common request params on HTTP Requests
   * @param request HttpRequest
   * @param requestMethod HTTP request method
   */
  public static void setCommonRequestParams(
    HttpRequest request,
    String requestMethod
  ) {
    request.setMethod(requestMethod);
    request.setHeader('client_id', '{!$Credential.Username}');
    request.setHeader('client_secret', '{!$Credential.Password}');
    //Todo: This needs to be replaced with uniquely generated id based on what is accepted by forge
    //request.setHeader('x-correlation-id', RequestUtils.getRequestId());
  }

  /**
   * @description Make HTTP request and process the response
   * @param request HttpRequest
   * @param processName name of the process which failed
   * @param functionName function name where the error occured
   * @param errorIdentifier error identifier
   * @param usedInLWC is usen in a LWC component
   * @return String response body
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static String processRequest(
    HttpRequest request,
    String processName,
    String functionName,
    String errorIdentifier,
    Boolean usedInLWC
  ) {
    String responseBody;
    HTTPResponse response = null;
    try {
      Http http = new Http();
      response = http.send(request);
      if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
        responseBody = response.getBody();
      } else {
        throw new CalloutException(response.getBody());
      }
    } catch (Exception e) {
      Boolean logResult = lib_systemLog.logAPIError(
        processName,
        functionName,
        e.getMessage(),
        e.getTypeName(),
        null,
        response != null ? response.getBody() : null,
        request.getEndpoint(),
        request.getMethod(),
        response.getStatusCode()
      );

      if (usedInLWC) {
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
    }

    return responseBody;
  }
}
