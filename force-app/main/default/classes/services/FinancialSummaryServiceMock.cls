/**
 * @author Hitesh
 * @since  July 2025
 * @group Platform
 * @description Mock class for FinancialSummary Service
 */
public class FinancialSummaryServiceMock extends FinancialSummaryService {
  /**
   * @description create HTTP mock response for testing
   */
  public class GetTotalCustomerBalanceMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_totalBalanceResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class GetTotalMortageLendingMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_totalMortageLending');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class GetTotalTerminalsMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_totalTerminalResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class GetTotalAssetFinanceBalanceMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(
        'mock_totalAssetBalanceResponse'
      );
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'mock-header');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
