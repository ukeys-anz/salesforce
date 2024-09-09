/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Test Class for VaultService
 */
@isTest
public with sharing class VaultServiceTest {
  @isTest
  static void testGetFullCardNumberDetails() {
    Test.setMock(HttpCalloutMock.class, new VaultServiceMockResponse());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken1111',
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    VaultService serviceInstance = new VaultService();
    DetokenizationRequestModel contextReq = new DetokenizationRequestModel();
    contextReq.value = CryptoOperationsUtilsTest.MOCK_TOKENIZED_CARD_NUMBER;
    contextReq.type = 'TOKEN_TYPE_CARD_NUMBER';
    HttpCalloutResponse response = serviceInstance.getFullCardNumberDetails(
      '1111',
      contextReq
    );
    Test.stopTest();

    Assert.areEqual(response.statuscode, 200, 'Invalid status');
  }

  class VaultServiceMockResponse implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setBody(
        JSON.serialize(CryptoOperationsUtilsTest.MOCK_GCP_RESPONSE.body)
      );
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }
}
