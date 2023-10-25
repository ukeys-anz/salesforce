/**
 * @author Arpit
 * @since July 2023
 * @description PayToControllerTest is provide unit test coverage for PayToController.
 */
@isTest
private class PayToControllerTest {
  private static Faker faker;
  /**
   * @description Setup data for test classes
   */
  @testSetup
  public static void setup() {
    faker = new Faker('AU');

    List<Account> applicants = new List<Account>();
    applicants.add(getTestAccount('Sara', 'khan', '1000990280'));
    insert applicants;
  }

  private static Account getTestAccount(
    string name,
    String lastname,
    String ocvId
  ) {
    return new Account(
      FirstName = name,
      LastName = lastname,
      OCV_ID__c = ocvId,
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonMobilePhone = '0401' + faker.randomInteger(6)
    );
  }

  @isTest
  static void testGetMandateList() {
    Test.startTest();
    Account acc = [SELECT Id, OCV_Id__c FROM Account LIMIT 1];
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    PayToController ctrl = new PayToController();

    inputMap.put('ocvId', acc.OCV_Id__c);
    inputMap.put('status', 'MANDATE_STATUS_CODE_ACTIVE');
    inputMap.put('pageNumber', '1');
    Boolean isInvoked = (Boolean) ctrl.call(
      'getMandateList',
      new Map<String, Object>{
        'input' => inputMap,
        'output' => outMap,
        'options' => options
      }
    );
    Map<String, Object> payload = (Map<String, Object>) outMap.get('result');
    Test.stopTest();
    Assert.isFalse((Boolean) payload.get('hasError'), 'Invalid Response');
    Assert.areNotEqual(payload, null, 'Empty JSON');
    Assert.areEqual(
      ((List<Object>) payload.get('mandates')).size(),
      3,
      'Should return 3 record'
    );
  }

  @isTest
  static void testGetMandateListError() {
    Test.startTest();
    Account acc = [SELECT Id, OCV_Id__c FROM Account LIMIT 1];
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    PayToController ctrl = new PayToController();

    inputMap.put('status', 'MANDATE_STATUS_CODE_ACTIVE');
    inputMap.put('pageNumber', '1');
    Boolean isInvoked = (Boolean) ctrl.call(
      'getMandateList',
      new Map<String, Object>{
        'input' => inputMap,
        'output' => outMap,
        'options' => options
      }
    );
    Map<String, Object> payload = (Map<String, Object>) outMap.get('result');
    Test.stopTest();
    Assert.isTrue((Boolean) payload.get('hasError'), 'Invalid Response');
  }

  @isTest
  static void testPaytoServiceGetMandateList() {
    Test.setMock(HttpCalloutMock.class, new MockGetMandateCallout());
    Account acc = [SELECT Id, OCV_Id__c FROM Account LIMIT 1];
    PayToService serv = new PayToService();
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      acc.OCV_Id__c,
      AuthServiceTest.IDTESTVALUE
    );
    Test.startTest();
    HttpCalloutResponse res = serv.getMandateList(acc.OCV_Id__c, 1, 1);
    Test.stopTest();
    Assert.areEqual(res.statusCode, 200, 'api call unsucessfully');
  }

  /**
   * @description Mock get mandate api callout
   */
  public class MockGetMandateCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      string jsonBody = Service.getStaticResource('mock_MandateList');
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(jsonBody);
      return res;
    }
  }

  @isTest
  static void testChangeMandateStatus() {
    Test.startTest();
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    PayToController ctrl = new PayToController();

    inputMap.put('mandateId', 'test');

    Boolean isInvoked = (Boolean) ctrl.call(
      'changeMandateStatus',
      new Map<String, Object>{
        'input' => inputMap,
        'output' => outMap,
        'options' => options
      }
    );
    Map<String, Object> payload = (Map<String, Object>) outMap.get('result');
    Test.stopTest();
    Assert.areNotEqual(
      (String) payload.get('status'),
      'failed',
      'Invalid Response'
    );
    Assert.areNotEqual(payload, null, 'Empty JSON');
  }

  @isTest
  static void testPaytoServiceCancelMandate() {
    Test.setMock(HttpCalloutMock.class, new MockCancelMandateCallout());
    Account acc = [SELECT Id, OCV_Id__c FROM Account LIMIT 1];

    PayToService serv = new PayToService();
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      acc.OCV_Id__c,
      AuthServiceTest.IDTESTVALUE
    );
    Test.startTest();
    HttpCalloutResponse res = serv.changeMandateStatus(
      'TEST_MANDATE_ID',
      acc.OCV_Id__c,
      'Cancel'
    );
    Test.stopTest();
    Assert.areEqual(res.statusCode, 200, 'api call unsucessfully');
  }

  /**
   * @description Mock cancel mandate api callout
   */
  public class MockCancelMandateCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      string jsonBody = Service.getStaticResource('mock_CancelMandate');
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(jsonBody);
      return res;
    }
  }

  @isTest
  static void testFraudxChangeStatus() {
    Test.startTest();
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    PayToController ctrl = new PayToController();

    inputMap.put('mandateId', 'test');
    inputMap.put('ocvId', '12345');
    inputMap.put('status', 'CNCL');
    inputMap.put('mandateAccountNumber', '1212122');
    inputMap.put('mandatePayId', '121212');

    Boolean isInvoked = (Boolean) ctrl.call(
      'fraudxChangeStatus',
      new Map<String, Object>{
        'input' => inputMap,
        'output' => outMap,
        'options' => options
      }
    );
    Map<String, Object> payload = (Map<String, Object>) outMap.get('result');
    Test.stopTest();
    Assert.areNotEqual(
      (String) payload.get('status'),
      'failed',
      'Invalid Response'
    );
    Assert.areNotEqual(payload, null, 'Empty JSON');
  }

  @isTest
  static void testPaytoFraudxServiceChangeStatus() {
    Test.setMock(HttpCalloutMock.class, new MockFraudxChangeStatusCallout());
    Account acc = [SELECT Id, OCV_Id__c FROM Account LIMIT 1];
    PayToFraudxService serv = new PayToFraudxService();
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      acc.OCV_Id__c,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    Map<String, String> headerProperties = new Map<String, String>{
      'userId' => '121212',
      'userIdType' => 'LANID',
      'mandateAccountIdentification' => 'ALIA',
      'mandateAccountIdentificationType' => '121212'
    };
    HttpCalloutResponse res = serv.changeMandateStatus(
      'mandates/cdcasda212sxax',
      acc.OCV_Id__c,
      'CNCL',
      headerProperties
    );
    Test.stopTest();
    Assert.areEqual(res.statusCode, 200, 'api call unsucessfully');
  }

  /**
   * @description Mock change status mandate api callout
   */
  public class MockFraudxChangeStatusCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      string jsonBody = Service.getStaticResource('mock_FraudXFailure');
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(jsonBody);
      return res;
    }
  }
}
