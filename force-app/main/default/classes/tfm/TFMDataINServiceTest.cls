/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@isTest
public with sharing class TFMDataINServiceTest {
  private static final String SUCCESS_SEARCH_CUSTOMER =
    '{' +
    '   \"status\": { \"code\": 200, \"description\": \"SUCCESS\" },' +
    '}';

  @isTest
  static void testGetDataINConsentsListAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMDataINService service = new TFMDataINService();
    HttpCalloutResponse response = service.getDataINConsentsListAPI(staffModel);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testGetDataINAccountListAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String consentIdValue;
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMDataINService service = new TFMDataINService();
    HttpCalloutResponse response = service.getDataINAccountListAPI(
      staffModel,
      consentIdValue
    );

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testExportConsent() {
    String methodName;
    String consentId;
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMDataINService service = new TFMDataINService();
    HttpCalloutResponse response = service.exportConsent(
      methodName,
      consentId,
      staffModel
    );
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testRevokeConsent() {
    String consentId;
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMDataINService service = new TFMDataINService();
    HttpCalloutResponse response = service.revokeConsent(consentId, staffModel);
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  class MockSearchCustomerResponse implements HttpCalloutMock {
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

  private static StaffTokenRequestModel setStaffModel() {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.UUID;
    staffModel.idValue = '1122r5421';
    staffModel.anzTokenType = 'staffRqfCustomer';
    Cache.Session.put(
      'local.ForgeToken.forgeJWTToken' + staffModel.idValue,
      AuthServiceTest.IDTESTVALUEFORGE2,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    return staffModel;
  }
}
