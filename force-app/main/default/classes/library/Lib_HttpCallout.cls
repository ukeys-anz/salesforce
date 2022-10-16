/**
 * @group Library
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Lib_HttpCallout is a callout handler class which handles all the callouts to external apis such as SOAP services or REST services.
 * For now this class only has REST service implementation as we are currently not consuming SOAP or any other types of services
 * @group Library
 */
public with sharing class Lib_HttpCallout {
  /**
   * @param endpoint API endpoint to make the request against
   * @param method which HTTP method to use
   * @param headers request header key value pairs
   * @param requestBody HTTP request body for PUT/PATCH/POST - currently unused
   * @return `HttpCalloutResponse` response type which handles all callout responses.
   * @description handler to build and send REST requests, and handle response errors
   */
  public HttpCalloutResponse makeRestCallout(
    String endpoint,
    HTTP_METHOD method,
    Map<String, String> headers,
    String requestBody
  ) {
    HttpRequest request = new HttpRequest();
    if (String.isBlank(endpoint) || String.isBlank(method.name())) {
      HttpCalloutResponse callResponse = new HttpCalloutResponse();
      callResponse.successful = false;
      callResponse.error = new CalloutException(
        'Endpoint or Method cannot be empty for a HTTP callout'
      );
      return callResponse;
    }
    request.setTimeout(20000);
    request.setEndpoint(endpoint);
    request.setMethod(method.name().remove('HTTP_'));

    if (headers != null) {
      for (String httpHeader : headers.keySet()) {
        request.setHeader(httpHeader, headers.get(httpHeader));
      }
    }
    if (!String.isBlank(requestBody)) {
      request.setBody(requestBody);
    }

    return performCallout(request);
  }

  /**
   * @param request http request with all properties set
   * @return `HttpCalloutResponse` response type which handles all callout responses.
   * @description with a prebuilt request, actions the callout
   */
  private HttpCalloutResponse performCallout(HttpRequest request) {
    HttpCalloutResponse callResponse = new HttpCalloutResponse();
    HTTPResponse response = null;
    lib_systemLog log = new lib_systemLog('Lib_HttpCallout', 'performCallout');
    //Log start of transaction
    log.addMessageWithRequestResponse(
      null,
      null,
      Lib_SystemLog.Severity.INFO,
      request.getEndpoint(),
      request.getMethod(),
      null,
      null,
      null
    );
    try {
      Http http = new Http();
      response = http.send(request);
      if (response == null) {
        callResponse.successful = false;
        callResponse.error = new CalloutException('Response is null');
        return callResponse;
      }
      callResponse.statusCode = response.getStatusCode() != null
        ? response.getStatusCode()
        : -1;
      callResponse.status = response.getStatus() != null
        ? response.getStatus()
        : '';
      if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
        callResponse.successful = true;
        callResponse.body = response.getBody() != null
          ? response.getBody()
          : '';
      } else {
        callResponse.successful = false;
        callResponse.error = new CalloutException(response.getBody());
      }

      //Log successful transaction
      log.addMessageWithRequestResponse(
        null,
        null,
        Lib_SystemLog.Severity.INFO,
        request.getEndpoint(),
        request.getMethod(),
        response.getStatusCode(),
        null,
        null
      );
    } catch (Exception e) {
      //Log failure
      log.addMessageWithRequestResponse(
        '',
        e.getMessage(),
        lib_systemLog.Severity.ERROR,
        request.getEndpoint(),
        request.getMethod(),
        response?.getStatusCode(),
        '',
        ''
      );
      callResponse.successful = false;
      callResponse.error = e;
    }
    log.publishEvent();
    return callResponse;
  }
}
