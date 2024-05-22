/**
 * @author Hinduja Upadhyay
 * @since Jan 2024
 * @description Test class for TFMAUFServiceTest
 */
@isTest
public with sharing class TFMAUFServiceTest {
  private static final String SUCCESS_SEARCH_CUSTOMER =
    '{' +
    '   \"status\": { \"code\": 200, \"description\": \"SUCCESS\" },' +
    '}';

  @isTest
  static void testupdatePinStatus() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String pinRefId = 'x00Bm000008L9jfake';
    String action = 'Locked';
    Test.setMock(HttpCalloutMock.class, new MockAUFResponse());
    Test.startTest();
    TFMAUFService service = new TFMAUFService();
    HttpCalloutResponse response = service.updatePinStatus(
      staffModel,
      pinRefId,
      action
    );

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testStatus() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String status = TFMConstants.UNSUSPEND;
    Test.setMock(HttpCalloutMock.class, new MockAUFResponse());
    Test.startTest();
    TFMAUFService service = new TFMAUFService();
    HttpCalloutResponse response = service.updateStatus(staffModel, status);

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }
  @isTest
  static void testupdateMobileNumber() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String value = '40122344656';
    Test.setMock(HttpCalloutMock.class, new MockAUFResponse());
    Test.startTest();
    TFMAUFService service = new TFMAUFService();
    HttpCalloutResponse response = service.updateMobileNumber(
      staffModel,
      value
    );

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }
  @isTest
  static void testuupdateOcvid() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String value = '100035756465';
    Test.setMock(HttpCalloutMock.class, new MockAUFResponse());
    Test.startTest();
    TFMAUFService service = new TFMAUFService();
    HttpCalloutResponse response = service.updateOcvid(staffModel, value);

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testderegisterDevice() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String deviceResourceId = 'x00Bm000008L9jfake';
    Test.setMock(HttpCalloutMock.class, new MockAUFResponse());
    Test.startTest();
    TFMAUFService service = new TFMAUFService();
    HttpCalloutResponse response = service.deregisterDevice(
      staffModel,
      deviceResourceId
    );

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testResetPin() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String pin = '203040';
    Test.setMock(HttpCalloutMock.class, new MockAUFResponse());
    Test.startTest();
    TFMAUFService service = new TFMAUFService();
    HttpCalloutResponse response = service.resetPin(staffModel, pin);

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  class MockAUFResponse implements HttpCalloutMock {
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
    staffModel.idValue = 'x00Bm000008L9jfake';
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
