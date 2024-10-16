/**
 * @author Hinduja Upadhyay
 * @since Sep 2024
 * @description Test class for TFMAUFServiceTest
 */
@isTest
public with sharing class ADRServiceTest {
  private static final String SUCCESS_SEARCH_CUSTOMER =
    '{' +
    '   \"status\": { \"code\": 200, \"description\": \"SUCCESS\" },' +
    '}';

  private static final String ADR_ERROR =
    '{' +
    '   \"status\": { \"code\": 404, \"description\": \"Error\" },' +
    '}';

  @isTest
  static void testgetADRRows() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = 'staff';
    staffModel.realm = 'System';
    Test.setMock(HttpCalloutMock.class, new MockADRResponse());
    Test.startTest();
    ADRService service = new ADRService();
    HttpCalloutResponse response = service.getADRRows(staffModel);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testPerformADRAction() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = 'staff';
    staffModel.realm = 'System';
    String rspId = 'fake-8f20-445f-ac7b-b8fdb5394fb8';
    String actionToPerform = 'suspend';
    Test.setMock(HttpCalloutMock.class, new MockADRResponse());
    Test.startTest();
    ADRService service = new ADRService();
    HttpCalloutResponse response = service.performADRAction(
      staffModel,
      rspId,
      actionToPerform
    );
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testPerformADRActionError() {
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      AuthServiceTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = 'staff';
    staffModel.realm = 'System';
    String rspId = 'fake-8f20-445f-ac7b-b8fdb5394fb8';
    String actionToPerform = 'suspend';
    Test.setMock(HttpCalloutMock.class, new MockADRResponseError());
    Test.startTest();
    ADRService service = new ADRService();
    HttpCalloutResponse response = service.performADRAction(
      staffModel,
      rspId,
      actionToPerform
    );
    Test.stopTest();
    Assert.areEqual(
      404,
      response.statusCode,
      'Callout is successful,expecting status code:404'
    );
  }

  class MockADRResponse implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setBody(SUCCESS_SEARCH_CUSTOMER);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  class MockADRResponseError implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(404);
      res.setBody(ADR_ERROR);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }
}
