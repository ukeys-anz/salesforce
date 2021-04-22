/**
 *
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Mock http callout for Tests
 * @group Library
 */
public class Lib_HttpMockCallout implements HttpCalloutMock {
  protected Integer code;
  protected String status;
  protected String bodyAsString;
  protected Blob bodyAsBlob;
  protected Map<String, String> responseHeaders;

  /**
   *
   * @param code
   * @param status
   * @param body
   * @param responseHeaders
   * @description  Mock constructor
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public Lib_HttpMockCallout(
    Integer code,
    String status,
    String body,
    Map<String, String> responseHeaders
  ) {
    this.code = code;
    this.status = status;
    this.bodyAsString = body;
    this.bodyAsBlob = null;
    this.responseHeaders = responseHeaders;
  }

  /**
   *
   * @param code
   * @param status
   * @param body
   * @param responseHeaders
   * @description Mock constructor
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public Lib_HttpMockCallout(
    Integer code,
    String status,
    Blob body,
    Map<String, String> responseHeaders
  ) {
    this.code = code;
    this.status = status;
    this.bodyAsBlob = body;
    this.bodyAsString = null;
    this.responseHeaders = responseHeaders;
  }
  /**
   *
   * @param req Request
   * @return `HTTPResponse` response
   * @description returns mock response based with respective parameters
   */
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse resp = new HttpResponse();
    resp.setStatusCode(code);
    resp.setStatus(status);
    if (bodyAsBlob != null) {
      resp.setBodyAsBlob(bodyAsBlob);
    } else {
      resp.setBody(bodyAsString);
    }

    if (responseHeaders != null) {
      for (String key : responseHeaders.keySet()) {
        resp.setHeader(key, responseHeaders.get(key));
      }
    }
    System.debug(LoggingLevel.debug, resp);
    return resp;
  }
}
