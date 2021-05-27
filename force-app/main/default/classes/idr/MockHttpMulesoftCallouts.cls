/**
 *
 * @author Pavan Kuamr Ananta
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description MockHttpMulesoftCallouts is a CAP mock service which is used to send mock responses for
 * various test scenarios for Customer Profile Information HTTP callout.
 */
public class MockHttpMulesoftCallouts implements HttpCalloutMock {
  Exception callException = null;
  Integer statusCode = null;
  String responseBody = null;
  /**
   * @description MockHttpMulesoftCallouts constructor
   * @param statusCode
   * @param responseBody
   */
  public MockHttpMulesoftCallouts(Integer statusCode, String responseBody) {
    this.statusCode = statusCode;
    this.responseBody = responseBody;
  }
  /**
   * @description MockHttpMulesoftCallouts constructor
   * @param callException
   */
  public MockHttpMulesoftCallouts(Exception callException) {
    this.callException = callException;
  }
  /**
   * @description Mock the response to the requests from Test classes
   * @param req
   * @return `HTTPResponse`
   */
  public HTTPResponse respond(HTTPRequest req) {
    System.assertEquals('POST', req.getMethod());
    if (callException == null) {
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(responseBody);
      res.setStatusCode(statusCode);
      return res;
    } else {
      throw callException;
    }
  }
}
