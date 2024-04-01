/**
 * @author Hinduja Upadhyay
 * @since JAN 2024
 * @description Test class for {@link TFMSearchCustomerService}
 * @group Services
 */
@isTest
public inherited sharing class TFMSearchCustomerServiceTest {
  private static final String SUCCESS_SEARCH_CUSTOMER =
    '{' +
    '   \"status\": { \"code\": 200, \"description\": \"SUCCESS\" },' +
    '}';

  @isTest
  static void testsearchCustAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    HttpCalloutResponse response = service.searchCustAPI(staffModel);
    Test.stopTest();
    Assert.areNotEqual(
      response.body,
      null,
      'Response body should not be null.'
    );
  }

  @isTest
  static void testGetJointAccountPermissions() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    HttpCalloutResponse response = service.getJointAccountPermissions(
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
  static void testupdatedisclosureStatus() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String bsb;
    String accountNumber;
    Boolean enabled;
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    HttpCalloutResponse response = service.updatedisclosureStatus(
      bsb,
      accountNumber,
      enabled,
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
  static void testgetORModifyJointAccountNotificationAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    HttpCalloutResponse response = service.getORModifyJointAccountNotificationAPI(
      staffModel,
      '111 31353',
      false
    );
    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testgetORModifyJointAccountNotificationAPI2() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    Cache.Session.put(
      'local.ForgeToken.forgeJWTToken' + staffModel.idValue,
      AuthServiceTest.IDTESTVALUEFORGE2,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    HttpCalloutResponse response = service.getORModifyJointAccountNotificationAPI(
      staffModel,
      '',
      false
    );
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

  @isTest
  static void testgetConsentAccountList() {
    StaffTokenRequestModel staffModel = setStaffModel();
    string consentAccounts;
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    HttpCalloutResponse response = service.getConsentAccountList(
      staffModel,
      consentAccounts
    );

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testrevokeConsent() {
    StaffTokenRequestModel staffModel = setStaffModel();
    string arrangementId;
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    HttpCalloutResponse response = service.revokeConsent(
      arrangementId,
      staffModel
    );
    Test.stopTest();
    Assert.areNotEqual(
      response.status,
      '200',
      'Status should be 200 for successful revocation'
    );
  }

  @isTest
  static void testgetConsentsList() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    HttpCalloutResponse response = service.getConsentsList(staffModel);

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testgetConsentDataSharingHistory() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String consentId;
    String fromTimestamp;
    String toTimestamp;
    Test.setMock(HttpCalloutMock.class, new MockSearchCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    HttpCalloutResponse response = service.getConsentDataSharingHistory(
      consentId,
      fromTimestamp,
      toTimestamp,
      staffModel
    );

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
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
