/**
 * @group Library
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Lib_HttpCallout is a callout handler class which handles all the callouts to external apis such as SOAP services or REST services.
 * For now this class only has REST service implementation as we are currently not consuming SOAP or any other types of services
 * @group Library
 */
public with sharing class Lib_HttpCallout {
  private Lib_HttpCalloutConfig libConfig;

  /**
   * @description Constructor to set the default value of the Lib_HttpCalloutConfig.
   */
  public Lib_HttpCallout() {
    this.libConfig = new Lib_HttpCalloutConfig();
  }

  /**
   * @description Parametrised Constructor to use the value of the Lib_HttpCalloutConfig.
   * @param libConfig Lib_HttpCalloutConfig instance to get the value of Lib_HttpCalloutConfig attributes set from the calling method.
   */
  public Lib_HttpCallout(Lib_HttpCalloutConfig libConfig) {
    this.libConfig = libConfig;
  }

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
    RESTCalloutWrapper restWrap = new RESTCalloutWrapper();
    restWrap.endpoint = endpoint;
    restWrap.method = method;
    restWrap.headers = headers;
    restWrap.requestBody = requestBody;
    restWrap.timeout = 20000;
    return makeRestCallout(restWrap);
  }

  /**
   * @param restWrap RESTCalloutWrapper containing all callout parameters.
   * @return `HttpCalloutResponse` response type which handles all callout responses.
   * @description handler to build and send REST requests, and handle response errors
   */
  public HttpCalloutResponse makeRestCallout(RESTCalloutWrapper restWrap) {
    HttpRequest request = new HttpRequest();
    if (
      String.isBlank(restWrap.endpoint) ||
      String.isBlank(restWrap.method.name())
    ) {
      HttpCalloutResponse callResponse = new HttpCalloutResponse();
      callResponse.successful = false;
      callResponse.error = new CalloutException(
        'Endpoint or Method cannot be empty for a HTTP callout'
      );
      return callResponse;
    }
    if (
      restWrap.timeout == null ||
      restWrap.timeout < 1 ||
      restWrap.timeout > 120000
    ) {
      HttpCalloutResponse callResponse = new HttpCalloutResponse();
      callResponse.successful = false;
      callResponse.error = new CalloutException(
        'Timeout needs to be a valid value between 1 to 120000'
      );
      return callResponse;
    }
    request.setTimeout(restWrap.timeout);
    request.setEndpoint(restWrap.endpoint);
    request.setMethod(restWrap.method.name().remove('HTTP_'));

    if (restWrap.headers != null) {
      for (String httpHeader : restWrap.headers.keySet()) {
        request.setHeader(httpHeader, restWrap.headers.get(httpHeader));
      }
    }
    if (!String.isBlank(restWrap.requestBody)) {
      request.setBody(restWrap.requestBody);
    }

    return performCallout(request);
  }

  /**
   * @param request http request with all properties set
   * @return `Map<String, String>` to return the authorization header for HttpRequest.
   * @description with a prebuilt request, actions the callout
   */
  private Map<String, String> getHeaders(HttpRequest request) {
    Map<String, String> autheader = new Map<String, String>();
    autheader.put('Authorization', request.getHeader('Authorization'));
    autheader.put('x-correlation-id', request.getHeader('x-correlation-id'));
    return autheader;
  }

  /**
   * @param response http response with all properties set
   * @return `Map<String, String>` to return the authorization headers for HttpResponse.
   * @description with a prebuilt request, actions the callout
   */
  private Map<String, String> getHeaders(HTTPResponse response) {
    Map<String, String> responseheader = new Map<String, String>();
    for (String headerKey : response.getHeaderKeys()) {
      responseheader.put(headerKey, response.getHeader(headerKey));
    }
    return responseheader;
  }

  /**
   * @param request http request with all properties set
   * @return `HttpCalloutResponse` response type which handles all callout responses.
   * @description with a prebuilt request, actions the callout
   */
  private HttpCalloutResponse performCallout(HttpRequest request) {
    Logger.info(request.getEndpoint() + request.getMethod());
    Logger.debug('HttpRequest Header')
      .setPayload(JSON.serializePretty(getHeaders(request)));
    Logger.debug('HttpRequest Body').setPayload(request.getBody());
    HttpCalloutResponse callResponse = new HttpCalloutResponse();
    HTTPResponse response = null;

    try {
      Http http = new Http();

      response = http.send(request);
      Logger.debug('HttpResponse Header')
        .setPayload(JSON.serializePretty(getHeaders(response)));
      if (libConfig.logResponseBody) {
        Logger.debug('HttpResponse Body').setPayload(response.getBody());
      }
      Logger.debug('HttpResponse Status Code: ' + response.getStatusCode());
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
        callResponse.bodyAsBlob = response.getBodyAsBlob() != null
          ? response.getBodyAsBlob()
          : Blob.valueOf('');
      } else {
        callResponse.successful = false;
        callResponse.error = new CalloutException(response.getBody());
      }

      Logger.saveLog();
    } catch (Exception e) {
      Logger.error('Exception for HttpCallout', e);
      Logger.saveLog();
      callResponse.successful = false;
      callResponse.error = e;
    }

    return callResponse;
  }

  /**
   * @description Wrapper class for callout parameters.
   */
  public class RESTCalloutWrapper {
    /**
     * @description endpoint API endpoint to make the request against
     */
    public String endpoint { get; set; }
    /**
     * @description method which HTTP method to use
     */
    public HTTP_METHOD method { get; set; }
    /**
     * @description headers request header key value pairs
     */
    public Map<String, String> headers { get; set; }
    /**
     * @description requestBody HTTP request body for PUT/PATCH/POST - currently unused
     */
    public String requestBody { get; set; }
    /**
     * @description timeout connection and read timeout (maximum of 120000)
     */
    public Integer timeout { get; set; }
  }
}
