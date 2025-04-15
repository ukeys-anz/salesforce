/**
 * @author Shivraj Kadam
 * @since Apr 2025
 * @description Test Class for - TrustMeService
 */
@isTest
public with sharing class TrustMeServiceTest {
  private static final String SUCCESS_MSG =
    '{' +
    '   \"status\": { \"code\": 200, \"description\": \"SUCCESS\" },' +
    '}';

  private static final String ERROR_MSG =
    '{' +
    '   \"status\": { \"code\": 404, \"description\": \"Error\" },' +
    '}';

  @isTest
  static void testUpdateCaseStatus() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockTrustMeResponse());

    TrustMeCaseUpdateModel caseUpdateDetails = new TrustMeCaseUpdateModel();
    caseUpdateDetails.evaluation_id = '1234';
    caseUpdateDetails.state = 'MANUAL_REVIEW_STATE_APPROVED';
    caseUpdateDetails.checks = null;
    caseUpdateDetails.case_type = 'TrustMe_eIDV_Case';

    Test.startTest();
    TrustMeService service = new TrustMeService();
    HttpCalloutResponse response = service.updateCaseStatus(
      staffModel,
      caseUpdateDetails
    );
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful, expecting status code:200'
    );
  }

  @isTest
  static void testUpdateCaseStatusError() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockTrustMeResponseError());

    TrustMeCaseUpdateModel caseUpdateDetails = new TrustMeCaseUpdateModel();
    caseUpdateDetails.evaluation_id = '1234';
    caseUpdateDetails.state = 'MANUAL_REVIEW_STATE_APPROVED';
    caseUpdateDetails.checks = null;
    caseUpdateDetails.case_type = 'TrustMe_eIDV_Case';

    Test.startTest();
    TrustMeService service = new TrustMeService();
    HttpCalloutResponse response = service.updateCaseStatus(
      staffModel,
      caseUpdateDetails
    );
    Test.stopTest();
    Assert.areEqual(
      404,
      response.statusCode,
      'Callout is successful, expecting status code:404'
    );
  }

  private static StaffTokenRequestModel setStaffModel() {
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
    return staffModel;
  }
  class MockTrustMeResponse implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setBody(SUCCESS_MSG);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  class MockTrustMeResponseError implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(404);
      res.setBody(ERROR_MSG);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }
}