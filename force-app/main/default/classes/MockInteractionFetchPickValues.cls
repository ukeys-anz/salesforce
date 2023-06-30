/**
 * @author Kopal Goswami
 * @since 06/2023
 * @description MockInteractionFetchPickValues is the Mock class to cover tests for {@link DependentPicklistController,InteractionFetchPickValues}
 */
@isTest
global class MockInteractionFetchPickValues implements HttpCalloutMock {
  private String calloutResponse = '';

  public MockInteractionFetchPickValues() {
  }

  public MockInteractionFetchPickValues(String responseFromRealCallout) {
    this.calloutResponse = responseFromRealCallout;
  }
  /**
   * @description mock response for callout
   * @param req incoming request
   * @return HTTPResponse invalid response
   */
  global HTTPResponse respond(HttpRequest req) {
    HTTPResponse res = new HTTPResponse();
    String responseBody = calloutResponse;
    res.setStatusCode(200);
    res.setHeader('Content-Type', 'application/json');
    res.setBody(responseBody);
    res.setStatus('Ok');

    return res;
  }
}
